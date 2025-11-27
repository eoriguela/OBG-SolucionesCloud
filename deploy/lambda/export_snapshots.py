import boto3
import datetime

rds = boto3.client('rds')
s3_bucket = "${var.vpc_name}-rds-snapshots"

def lambda_handler(event, context):
    today = datetime.datetime.utcnow().strftime("%Y-%m-%d")

    snapshots = rds.describe_db_snapshots(
        DBInstanceIdentifier="ecommerce-db",
        SnapshotType="automated"
    )["DBSnapshots"]

    snapshots = sorted(snapshots, key=lambda x: x["SnapshotCreateTime"], reverse=True)

    latest = snapshots[0]["DBSnapshotIdentifier"]

    export_id = f"export-{latest}-{today}"

    response = rds.start_export_task(
        ExportTaskIdentifier=export_id,
        SourceArn=f"arn:aws:rds:us-east-1:${account_id}:db:ecommerce-db",
        S3BucketName=s3_bucket,
        IamRoleArn=f"arn:aws:iam::{account_id}:role/LabInstanceProfile",
        KmsKeyId="alias/aws/s3"
    )

    return {"status": "OK", "export": export_id}
