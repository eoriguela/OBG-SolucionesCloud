resource "aws_s3_bucket" "bucket" {
   bucket = var.s3_bucket_name
   force_destroy = true

  tags = {
    Name = "${var.vpc_name}-dump-bucket"
  }
}

resource "aws_s3_bucket" "app_bucket" {
  bucket        = "${var.vpc_name}-app-bucket"
  force_destroy = true

  tags = {
    Name = "${var.vpc_name}-app-bucket"
  }
}

resource "aws_s3_object" "dump_sql" {
  bucket = aws_s3_bucket.bucket.id
  key    = "dump.sql"

  # Ruta relativa desde el módulo "deploy"
  source = "/root/OBG-SolucionesCloud/app/php-ecommerce-obligatorio-2025/dump.sql"

}

# Zipea la App completa
data "archive_file" "app_zip" {
  type        = "zip"
  source_dir  = "/root/OBG-SolucionesCloud/app/php-ecommerce-obligatorio-2025"
  output_path = "${path.module}/app.zip"
}
# Sube el zip al bucket
resource "aws_s3_object" "app_zip" {
  bucket = aws_s3_bucket.app_bucket.id
  key    = "app.zip"
  source = data.archive_file.app_zip.output_path

  etag = filemd5(data.archive_file.app_zip.output_path)
}