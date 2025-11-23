data "template_file" "bastion_userdata" {
  template = file("${path.module}/bastion_userdata.sh.tpl")

  vars = {
    s3_bucket   = var.s3_bucket_name
    db_endpoint = aws_db_instance.ecommerce.address
    db_username = var.db_username
    db_password = var.db_password
    db_name     = var.db_name
  }
}

resource "aws_instance" "bastion" {
  ami           = var.bastion_ami
  instance_type = var.bastion_instance_type
  subnet_id     = aws_subnet.public[0].id
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.sg_bastion.id]
  iam_instance_profile = "LabInstanceProfile"

  user_data = data.template_file.bastion_userdata.rendered

  tags = {
    Name = "${var.vpc_name}-bastion"
  }
}