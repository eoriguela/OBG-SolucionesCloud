###############################################
# 1. Bucket donde se guardarán los backups
###############################################

resource "aws_s3_bucket" "snapshot_export" {
  bucket = "${var.vpc_name}-rds-snapshots"

  tags = {
    Name = "${var.vpc_name}-rds-snapshots"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "snapshot_export" {
  bucket = aws_s3_bucket.snapshot_export.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

###############################################
# 2. Lambda que exporta el snapshot automáticamente
###############################################
# Obtiene el ID de la cuenta AWS actual
data "aws_caller_identity" "current" {}

resource "aws_lambda_function" "export_rds_backup" {
  function_name = "${var.vpc_name}-export-rds-backup"

  role = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  timeout       = 60

  filename      = "${path.module}/lambda_export.zip"
}

###############################################
# 3. Generación del ZIP automáticamente
###############################################

data "archive_file" "lambda_export_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_export.py"
  output_path = "${path.module}/lambda_export.zip"
}

resource "aws_lambda_function" "lambda_with_zip" {
  function_name = "${var.vpc_name}-export-rds-backup"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  timeout       = 60
  role          = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabInstanceProfile"

  filename      = data.archive_file.lambda_export_zip.output_path
  depends_on    = [data.archive_file.lambda_export_zip]
}

###############################################
# 4. EventBridge: ejecutar la Lambda cada día
###############################################

resource "aws_cloudwatch_event_rule" "daily_snapshot_export" {
  name        = "${var.vpc_name}-snapshot-export"
  description = "Ejecuta Lambda todos los días a las 03:00"
  schedule_expression = "cron(0 3 * * ? *)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.daily_snapshot_export.name
  target_id = "export-rds-snapshots"
  arn       = aws_lambda_function.lambda_with_zip.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_with_zip.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_snapshot_export.arn
}

###############################################
# 5. Código Python (lambda_export.py)
###############################################

# Se añade automáticamente al ZIP con archive_file
# Guardá este archivo como lambda_export.py en el mismo módulo

