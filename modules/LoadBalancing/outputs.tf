output "alb_dns" {
  value = aws_lb.application_load_balancer.dns_name
}
output "alb_endpoint" {
  value = aws_lb.application_load_balancer.dns_name
}
output "alb_tg_name" {
  value = aws_lb_target_group.instance_tg.name
}
output "alb_tg_arn" {
  value = aws_lb_target_group.instance_tg.arn
}
