# Generamos el user_data para la instancia Bastion utilizando una plantilla ubicada en el módulo actual.
# En este bloque definimos las variables que se inyectarán en el script,
# permitiendo establecer la conexión con S3 y con la base de datos en RDS.
data "template_file" "bastion_userdata" {
  template = file("${path.module}/bastion_userdata.sh.tpl")   # Archivo de plantilla para user_data

  vars = {
    s3_bucket   = var.s3_bucket_name                          # Nombre del bucket S3 desde el cual descargaremos el dump
    db_endpoint = aws_db_instance.ecommerce.address           # Endpoint del RDS para conectividad
    db_username = var.db_username                             # Usuario de la base de datos
    db_password = var.db_password                             # Contraseña de acceso
    db_name     = var.db_name                                 # Nombre de la base a restaurar
  }
}

# Recurso EC2 que utilizamos como Bastion Host.
# Esta instancia nos permite acceder a la infraestructura interna y ejecutar procesos de inicialización.
resource "aws_instance" "bastion" {
  ami           = var.bastion_ami                             # AMI utilizada para el bastion
  instance_type = var.bastion_instance_type                   # Tipo de instancia definido por variable
  subnet_id     = aws_subnet.public[0].id                     # Ubicación en la primera subred pública
  key_name      = var.key_name                                # Par de claves para acceso SSH

  vpc_security_group_ids = [aws_security_group.sg_bastion.id] # Grupo de seguridad asignado al Bastion
  iam_instance_profile   = "LabInstanceProfile"               # Perfil IAM con permisos para S3, RDS y otros servicios

  user_data = data.template_file.bastion_userdata.rendered    # Script de inicialización desde la plantilla

  tags = {
    Name = "${var.vpc_name}-bastion"                          # Etiqueta para identificar la instancia
  }
}
