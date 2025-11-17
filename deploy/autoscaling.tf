resource "aws_launch_template" "app_lt" {
  name_prefix   = "${var.vpc_name}-app-lt"
  image_id      = var.app_ami
  instance_type = var.instance_type

  key_name = var.key_name

  network_interfaces {
    security_groups = [aws_security_group.sg_app.id]
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "asg_app" {
  name                = "${var.vpc_name}-asg-app"
  desired_capacity    = 1
  max_size            = 3
  min_size            = 1

  # SUBREDES PUBLICAS 
  
  vpc_zone_identifier = aws_subnet.public[*].id

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  # Conexión con el Target Group del ALB creado
  target_group_arns = [
    aws_lb_target_group.tg_app.arn
  ]

  tag {
    key                 = "Name"
    value               = "${var.vpc_name}-app"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
