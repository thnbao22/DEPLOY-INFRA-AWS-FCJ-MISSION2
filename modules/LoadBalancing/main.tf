# Define Load Balancer resources
resource "aws_lb" "application_load_balancer" {
  name                = "ALB-Web-Server"
  internal            = false
  load_balancer_type  = "application"
  security_groups     = [ var.alb_security_group_id ]
  subnets             = [ var.public_subnet_1_id, var.public_subnet_2_id ]
}
# Target Group 
resource "aws_lb_target_group" "instance_tg" {
  name      = "ASG-Web-Server-Target-Group"
  port      = var.port
  protocol  = var.protocol
  vpc_id    = var.one_tier_vpc_id
}

# Listener
resource "aws_lb_listener" "application_load_balancer_listener" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = var.port
  protocol          = var.protocol
  default_action {
    type              = "forward"
    target_group_arn  = aws_lb_target_group.instance_tg.arn
  }
}