output "instance_public_ip" {
  value = aws_eip.web-server-eip.public_ip
}

output "website_url" {
  value = "http://${aws_eip.web-server-eip.public_ip}"
}
