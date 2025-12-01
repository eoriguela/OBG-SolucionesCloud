#### TARGET GROUP Load Balancer ####

resource "aws_lb_target_group" "tg_app" {
  name        = "${var.vpc_name}-app-tg"   # Nombre del Target Group, basado en el nombre de la VPC
  port        = 80                         # Puerto al que el LB enviará tráfico
  protocol    = "HTTP"                     # Protocolo utilizado para enrutar tráfico
  target_type = "instance"                 # Los targets serán instancias EC2
  vpc_id      = aws_vpc.main.id            # VPC donde se crea el Target Group

  health_check {
    path                = "/"              # Endpoint para chequeo de salud
    port                = "80"             # Puerto para health checks
    protocol            = "HTTP"           # Protocolo de los health checks
    unhealthy_threshold = 3                # Intentos fallidos antes de marcar unhealthy
    healthy_threshold   = 3                # Intentos exitosos para marcar healthy
    interval            = 20               # Cada cuánto hacer health checks (segundos)
    timeout             = 5                # Tiempo máximo para esperar la respuesta
  }
}



#### APPLICATION LOAD BALANCER ####
### Apunta al Target Group creado arriba ###

resource "aws_lb" "alb" {
  name               = "${var.vpc_name}-alb"    # Nombre del Application Load Balancer
  internal           = false                    # false = ALB público
  load_balancer_type = "application"            # Tipo de Load Balancer
  security_groups    = [aws_security_group.sg_lb.id]  # SG asociado al ALB
  subnets            = aws_subnet.public[*].id        # Se despliega en subnets públicas

  tags = {
    Name = "${var.vpc_name}-alb"               # Tag identificatorio
  }
}


resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.alb.arn           # Listener asociado al ALB creado arriba
  port              = 80                       # Puerto donde escucha el ALB
  protocol          = "HTTP"                   # Protocolo

  default_action {
    type             = "forward"               # Acción por defecto: reenviar tráfico
    target_group_arn = aws_lb_target_group.tg_app.arn   # Hacia el Target Group definido antes
  }
}
