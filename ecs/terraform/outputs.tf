output "alb_dns" {
  value = aws_lb.ecs_flask_alb.dns_name
}