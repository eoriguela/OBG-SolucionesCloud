import os
import json
import boto3
import traceback
from datetime import datetime, timezone

rds = boto3.client("rds")
s3  = boto3.client("s3")

# Valores esperados desde environment variables (Terraform los inyecta)
DB_IDENTIFIER = os.environ.get("DB_IDENTIFIER", "ecommerce-db")
EXPORT_BUCKET = os.environ.get("EXPORT_BUCKET", "obligatorio-dump-bucket")
EXPORT_ROLE_ARN = os.environ.get("EXPORT_ROLE_ARN")  # ARN del role que permita export (si existe)
AWS_REGION = os.environ.get("AWS_REGION", "us-east-1")
KMS_KEY_ID = os.environ.get("KMS_KEY_ID", "alias/aws/s3")

def put_metadata_to_s3(snapshot):
    """Guarda metadata JSON del snapshot en S3 (fallback si no se puede exportar)."""
    key = f"rds-backups/metadata-{snapshot['DBSnapshotIdentifier']}-{datetime.utcnow().strftime('%Y%m%dT%H%M%SZ')}.json"
    body = json.dumps(snapshot, default=str).encode("utf-8")
    s3.put_object(Bucket=EXPORT_BUCKET, Key=key, Body=body)
    return key

def try_start_export(snapshot_arn, snapshot_id):
    """Intenta iniciar start_export_task. Lanza excepción si falla."""
    export_id = f"export-{snapshot_id}-{int(datetime.now(timezone.utc).timestamp())}"
    resp = rds.start_export_task(
        ExportTaskIdentifier=export_id,
        SourceArn=snapshot_arn,
        S3BucketName=EXPORT_BUCKET,
        IamRoleArn=EXPORT_ROLE_ARN,
        KmsKeyId=KMS_KEY_ID
    )
    return resp

def lambda_handler(event, context):
    try:
        # 1) Listar snapshots automáticos (últimos 7 días implícitos por RDS retention)
        snaps = rds.describe_db_snapshots(DBInstanceIdentifier=DB_IDENTIFIER, SnapshotType="automated")["DBSnapshots"]
        if not snaps:
            return {"status": "no_snapshots"}

        # ordenar por fecha y escoger el más reciente
        snaps_sorted = sorted(snaps, key=lambda x: x["SnapshotCreateTime"], reverse=True)
        latest = snaps_sorted[0]
        snap_arn = latest["DBSnapshotArn"]
        snap_id = latest["DBSnapshotIdentifier"]

        # 2) Intentar export real (si se configuró EXPORT_ROLE_ARN)
        if EXPORT_ROLE_ARN:
            try:
                resp = try_start_export(snap_arn, snap_id)
                return {"status": "export_started", "task": resp}
            except Exception as e:
                # si falla por permisos o por ExportTaskAlreadyExists, lo registramos y caemos a fallback
                err = str(e)
                print("start_export_task failed:", err)
                print(traceback.format_exc())

        # 3) Fallback: subir metadata JSON al bucket (funciona con LabInstanceProfile)
        key = put_metadata_to_s3(latest)
        return {"status": "metadata_saved", "s3_key": key}

    except Exception as e:
        print("Unhandled error:", str(e))
        print(traceback.format_exc())
        return {"status": "error", "error": str(e)}
