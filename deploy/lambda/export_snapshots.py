import boto3
import os
import json
from datetime import datetime

rds = boto3.client("rds")
s3 = boto3.client("s3")

def lambda_handler(event, context):
    db_identifier = os.environ["DB_IDENTIFIER"]
    bucket = os.environ["BUCKET_NAME"]

    # traer snapshots automáticos
    snapshots = rds.describe_db_snapshots(
        DBInstanceIdentifier=db_identifier,
        SnapshotType="automated"
    )["DBSnapshots"]

    if not snapshots:
        return {"msg": "No hay snapshots"}

    # ordenar por fecha
    snapshots.sort(key=lambda x: x["SnapshotCreateTime"], reverse=True)
    latest = snapshots[0]

    filename = f"backup-info-{datetime.utcnow().isoformat()}.json"

    s3.put_object(
        Bucket=bucket,
        Key=filename,
        Body=json.dumps(latest, default=str).encode("utf-8")
    )

    return {"msg": "Backup guardado", "file": filename}
