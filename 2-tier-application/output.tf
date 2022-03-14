output "vpc_id" {
  value = data.aws_vpc.default.id
}
output "security_group_id" {
  value = module.security_group.security_group_id

}

output "private_subnet" {
  value = data.aws_subnets.private_subnets.ids

}

output "db_subnet_group" {
  value = aws_db_subnet_group.db_subnet_group.id

}

output "database_endpoint" {
  value = aws_db_instance.database.endpoint
}

output "auto_scaling_group_id" {
  value = aws_autoscaling_group.bindu1.id
}
output "target_group_id" {
  value = aws_lb_target_group.tg_4000.id
}
output "application_url" {
  value = "http://${aws_lb.bindu.dns_name}:${aws_lb_target_group.tg_4000.port}"
}