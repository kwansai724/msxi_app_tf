output "alb" {
  value = aws_lb.alb
}

output "target_group_arn" {
  value = aws_lb_target_group.target_group.arn
}

output "target_group2_arn" {
  value = aws_lb_target_group.target_group2.arn
}
