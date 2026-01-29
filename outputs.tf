# Outputs for NGINX + ALB + ASG infrastructure

output "load_balancer_url" {
  description = "Public ALB URL"
  value       = aws_lb.app_lb.dns_name
}

output "public_subnets" {
  description = "IDs of public subnets"
  value       = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]
}

output "private_subnets" {
  description = "IDs of private subnets"
  value       = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]
}

output "alb_security_group_id" {
  description = "Security group ID for ALB"
  value       = aws_security_group.alb_sg.id
}

output "asg_security_group_id" {
  description = "Security group ID for ASG instances"
  value       = aws_security_group.asg_sg.id
}

output "nginx_launch_template_id" {
  description = "Launch template ID for NGINX ASG"
  value       = aws_launch_template.nginx_lt.id
}
output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.app_asg.name
}

output "target_group_arn" {
  description = "ARN of the ALB Target Group"
  value       = aws_lb_target_group.app_tg.arn
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.prod_vpc.id
}

output "instance_type" {
  description = "EC2 Instance Type for ASG"
  value       = var.instance_type
}

output "my_ip" {
  description = "Your public IP for SSH access"
  value       = var.my_ip
}

# End of outputs.tf