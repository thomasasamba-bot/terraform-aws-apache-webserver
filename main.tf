terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  profile = "terraform"
}

# Terraform resource syntax example
#resource "<provider>_resource_type" "resource_name" {
#  # resource configuration parameters
#  key = "value"
#  key2 = "value2" 
#}

# 1. Create a VPC
resource "aws_vpc" "prod-vpc" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "production"
  }
}

# 2. Create an Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.prod-vpc.id
}

# 3. Create a custom route table
resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "production-route-table"
  }
}

# 4. Create a public subnet
resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.prod-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  
  tags = {
    Name = "prod-subnet"
  }
  
}

# 5. Associate the route table with the subnet
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.prod-route-table.id
}

# 6. Create a security group to allow port 22, 80, and 443
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow web inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.prod-vpc.id

  ingress {
    description      = "Allow SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["41.90.162.115/32"] // Replace with your IP address
  }

  ingress {
    description      = "Allow HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Allow HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1" # semantically equivalent to all ports
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web_traffic"
  }
}

# 8. Assign the Elastic IP to the EC2 instance
resource "aws_eip" "web-server-eip" {
  domain     = "vpc"
  instance   = aws_instance.web-server-instance.id
  depends_on = [aws_internet_gateway.igw]
}

# 9. Create Ubuntu server  and install/enable Apache
resource "aws_instance" "web-server-instance" {
  ami               = "ami-0b6c6ebed2801a5cb"
  instance_type     = "t3.micro"
  availability_zone = aws_subnet.subnet1.availability_zone
  key_name          = "MyPythonAppKey"
  
  # Use the modern approach instead of deprecated network_interface block
  subnet_id                   = aws_subnet.subnet1.id
  vpc_security_group_ids      = [aws_security_group.allow_web.id]
  private_ip                  = "10.0.1.10"
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install apache2 -y
    sudo systemctl start apache2
    sudo systemctl enable apache2
    sudo bash -c 'echo "<h1>Hello from Terraform!</h1>" > /var/www/html/index.html'
  EOF

  tags = {
    Name = "web-server-instance"
  }
}