#### TARGET GROUP Load Balancer ####

resource "aws_lb_target_group" "tg_app" {
  name        = "${var.vpc_name}-app-tg"
  port        = 8080
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id

  health_check {
    path                = "/"
    port                = "8080"
    protocol            = "HTTP"
    unhealthy_threshold = 3
    healthy_threshold   = 3
    interval            = 20
    timeout             = 5
  }
}



#### APPLICATION LOAD BALANCER ####
### Apunta al Target Group creado arriba ###

resource "aws_lb" "alb" {
  name               = "${var.vpc_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_lb.id]
  subnets            = aws_subnet.public[*].id

  tags = {
    Name = "${var.vpc_name}-alb"
  }
}


resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_app.arn
  }
}



