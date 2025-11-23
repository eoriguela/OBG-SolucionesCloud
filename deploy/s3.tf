resource "aws_s3_bucket" "bucket" {
   bucket = var.s3_bucket_name
   force_destroy = true

  tags = {
    Name = "${var.vpc_name}-dump-bucket"
  }
}

resource "aws_s3_object" "dump_sql" {
  bucket = aws_s3_bucket.bucket.id
  key    = "dump.sql"

  # Ruta relativa desde el módulo "deploy"
  source = "/home/sysadmin/OBG-SolucionesCloud/app/php-ecommerce-obligatorio-2025/dump.sql"

}