resource "aws_instance" "backup_server" {
  ami                    = var.bastion_ami
  instance_type          = var.bastion_instance_type
  subnet_id              = aws_subnet.private[0].id
  key_name               = var.key_name
  iam_instance_profile   = "LabInstanceProfile"
  vpc_security_group_ids = [aws_security_group.sg_backup.id]

  user_data = templatefile("${path.module}/backup_userdata.sh.tpl", {
    db_endpoint = aws_db_instance.ecommerce.address
    db_username = var.db_username
    db_password = var.db_password
    db_name     = var.db_name
    s3_bucket   = "${var.vpc_name}-db-backups"
  })

  tags = {
    Name = "${var.vpc_name}-backup-server"
  }
}