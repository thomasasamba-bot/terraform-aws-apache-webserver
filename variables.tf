variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile"
  default     = "terraform"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "my_ip" {
  description = "Your public IP for SSH access"
  type        = string
}
