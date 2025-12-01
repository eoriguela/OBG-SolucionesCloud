###############################
# BUCKETS S3 PARA LA APLICACIÓN Y BACKUPS
###############################

# Bucket principal donde almacenamos el archivo dump.sql utilizado para inicializar la base de datos
resource "aws_s3_bucket" "bucket" {
  bucket        = var.s3_bucket_name        # Nombre del bucket definido por variable
  force_destroy = true                      # Permite eliminar el bucket aunque contenga objetos

  tags = {
    Name = "${var.vpc_name}-dump-bucket"    # Etiqueta descriptiva
  }
}

# Bucket destinado a almacenar los archivos de la aplicación empaquetada
resource "aws_s3_bucket" "app_bucket" {
  bucket        = "${var.vpc_name}-app-bucket"  # Nombre del bucket basado en la VPC
  force_destroy = true                          # Eliminación forzada del bucket y su contenido

  tags = {
    Name = "${var.vpc_name}-app-bucket"         # Etiqueta identificadora
  }
}

########################################
# dump.sql + ZIP de la App
########################################

# Subimos el archivo dump.sql al bucket correspondiente
resource "aws_s3_object" "dump_sql" {
  bucket = aws_s3_bucket.bucket.id                    # Bucket de destino
  key    = "dump.sql"                                 # Nombre con el que se almacenará el archivo

  # Ruta relativa respecto al módulo donde se ejecuta Terraform
  source = "../app/php-ecommerce-obligatorio-2025/dump.sql"
}

# Generamos un archivo ZIP con la aplicación completa antes del despliegue
data "archive_file" "app_zip" {
  type        = "zip"                                 # Tipo de archivo generado
  source_dir  = "../app/php-ecommerce-obligatorio-2025" # Directorio de origen a comprimir
  output_path = "${path.module}/app.zip"              # Ubicación donde se generará el ZIP
}

# Subimos el ZIP al bucket designado para la aplicación
resource "aws_s3_object" "app_zip" {
  bucket = aws_s3_bucket.app_bucket.id                # Bucket destino
  key    = "app.zip"                                  # Nombre del objeto en S3
  source = data.archive_file.app_zip.output_path      # Ruta del ZIP generado

  etag = filemd5(data.archive_file.app_zip.output_path) # Asegura detección de cambios
}

#########################################################
# Bucket adicional para almacenar los respaldos de RDS
#########################################################

resource "aws_s3_bucket" "backup_bucket" {
  bucket        = "${var.vpc_name}-db-backups"        # Nombre del bucket para backups
  force_destroy = true                                # Permite eliminar aunque existan snapshots

  tags = {
    Name = "${var.vpc_name}-db-backups"               # Etiqueta identificadora
  }
}
