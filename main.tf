terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# -------------------------------
# 1️⃣ VPC
# -------------------------------
resource "aws_vpc" "prod_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "production-vpc"
  }
}

# -------------------------------
# 2️⃣ Public Subnets (for ALB)
# -------------------------------
resource "aws_subnet" "public_subnet1" {
  vpc_id            = aws_vpc.prod_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = { Name = "public-subnet-az1" }
}

resource "aws_subnet" "public_subnet2" {
  vpc_id            = aws_vpc.prod_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = { Name = "public-subnet-az2" }
}

# -------------------------------
# 3️⃣ Private Subnets (for ASG instances)
# -------------------------------
resource "aws_subnet" "private_subnet1" {
  vpc_id            = aws_vpc.prod_vpc.id
  cidr_block        = "10.0.101.0/24"
  availability_zone = "us-east-1a"

  tags = { Name = "private-subnet-az1" }
}

resource "aws_subnet" "private_subnet2" {
  vpc_id            = aws_vpc.prod_vpc.id
  cidr_block        = "10.0.102.0/24"
  availability_zone = "us-east-1b"

  tags = { Name = "private-subnet-az2" }
}

# -------------------------------
# 4️⃣ Internet Gateway & Route Table
# -------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.prod_vpc.id

  tags = { Name = "prod-igw" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.prod_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "public-rt" }
}

resource "aws_route_table_association" "public1_assoc" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public2_assoc" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public_rt.id
}

# -------------------------------
# 5️⃣ Security Groups
# -------------------------------

# ALB SG (HTTP/HTTPS)
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP/HTTPS traffic from internet"
  vpc_id      = aws_vpc.prod_vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "alb-sg" }
}

# ASG Instances SG (HTTP from ALB + SSH from admin IP)
resource "aws_security_group" "asg_sg" {
  name        = "asg-sg"
  description = "Allow HTTP from ALB and SSH from admin IP"
  vpc_id      = aws_vpc.prod_vpc.id

  ingress {
    description      = "HTTP from ALB"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups  = [aws_security_group.alb_sg.id]
  }

  ingress {
    description = "SSH from admin"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["41.90.162.115/32"] # Replace with your IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "asg-sg" }
}

# -------------------------------
# 6️⃣ Launch Template
# -------------------------------
resource "aws_launch_template" "nginx_lt" {
  name_prefix   = "nginx-lt"
  image_id      = "ami-0b6c6ebed2801a5cb"
  instance_type = "t3.micro"
  key_name      = "MyPythonAppKey"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.asg_sg.id]
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    apt update -y
    apt install nginx -y
    systemctl enable nginx
    systemctl start nginx
    echo "<h1>Hello from Terraform via NGINX ASG!</h1>" > /var/www/html/index.nginx-debian.html
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "nginx-asg-instance"
    }
  }
}

# -------------------------------
# 7️⃣ Application Load Balancer
# -------------------------------
resource "aws_lb" "app_lb" {
  name               = "app-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]

  tags = { Name = "app-load-balancer" }
}

resource "aws_lb_target_group" "app_tg" {
  name     = "app-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.prod_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# -------------------------------
# 8️⃣ Auto Scaling Group
# -------------------------------
resource "aws_autoscaling_group" "app_asg" {
  desired_capacity    = 2
  min_size            = 2
  max_size            = 4
  vpc_zone_identifier = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]

  launch_template {
    id      = aws_launch_template.nginx_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app_tg.arn]

  tag {
    key                 = "Name"
    value               = "nginx-asg-instance"
    propagate_at_launch = true
  }
}
# End of main.tf