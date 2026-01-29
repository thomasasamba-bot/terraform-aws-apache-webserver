# 🚀 Terraform AWS NGINX ASG + ALB Web Server

This project provisions a **scalable NGINX web server environment** on AWS using **Terraform**. 
It demonstrates real-world **Infrastructure as Code (IaC)** practices including custom networking, security configuration, auto-scaling, load balancing and automated server provisioning without manual intervention.

---

## 🏗️ Terraform driven Architecture Overview

The infrastructure deployed via Terraform includes:

- **Custom VPC** – 10.0.0.0/16
- **Public Subnet** in multiple Availability Zones (for ALB)
- **Private Subnet** in multiple Availability Zones (for ASG instances)
- **Internet Gateway** for outbound traffic to the internet
- **Route Table** for proper network routing
- **Security Group** allowing:
  - ALB Security Group – allows HTTP (80) and HTTPS (443) from the internet
  - ASG Instances Security Group – allows HTTP from ALB and SSH from admin IP
- **Launch Template** to provision EC2 instances with NGINX
- **Auto Scaling Group (ASG)** to manage EC2 instances
- **Application Load Balancer (ALB)** to distribute traffic across ASG instances
- **Target Group** for ALB to route traffic to ASG instances

---
## High-level Terraform Architecture Diagram:
![Architecture Diagram](https://raw.githubusercontent.com/thomasasamba-bot/terraform-aws-apache-webserver/main/architecture-diagram.png)

Everything above is fully defined and managed via Terraform, demonstrating IaC principles.
---

## 🌍 Result

Once deployed, Terraform provisions:
- NGINX web server instances running in private subnets
- Fully functional Application Load Balancer with public access
- Auto Scaling to maintain desired instance count
The page served displays:

```
Hello from Terraform via NGINX ASG!
```

Terraform outputs the **ALB URL** for easy access

---

## 🛠️ Key Terraform Concepts Demonstrated

| Concept | Description |
|------|---------|
| Terraform | Infrastructure as Code |
| Providers | ProvidersConfigures AWS as the target cloud platform |
| Resources | Defines VPC, subnets, EC2 instances, security groups, ALB, ASG |
| Variables | Parameterizes inputs like SSH IP or instance types |
| Outputs | Exposes ALB URL and other useful info |
| User Data | Automates server setup (NGINX) on instance boot |
| Modules | Infrastructure can be modularized for reuse |
| Dependencies | Terraform ensures resources are created in the correct order |

---

## 📁 Project Structure

```
terraform-aws-nginx-asg-alb/
│
├── main.tf          # Core infrastructure resources (VPC, ALB, ASG, Launch Template)
├── variables.tf     # Input variables
├── provider.tf      # AWS provider configuration
├── outputs.tf       # Output values (ALB URL, Subnet IDs, Security Group IDs)
├── README.md        # Project documentation
└── .gitignore       # Files excluded from Git

```

---

## ▶️ How to Deploy

### 1️⃣ Clone Repository
```bash
git clone https://github.com/thomasasamba-bot/terraform-aws-nginx-asg-alb.git
cd terraform-aws-nginx-asg-alb
```

### 2️⃣ Initialize Terraform
```bash
terraform init
```

### 3️⃣ Provide Your Public IP for SSH Access
```bash
export TF_VAR_my_ip="YOUR_PUBLIC_IP/32"
```

Example:
```bash
export TF_VAR_my_ip="41.90.162.115/32"
```

### 4️⃣ Deploy Infrastructure
```bash
terraform apply
```

Type `yes` when prompted.

---

## 🌐 Access the NGINX Server

After deployment, Terraform will output:

```
load_balancer_url = http://<ALB-DNS-NAME>
```

Paste the URL into your browser to see the hosted NGINX page.

---

## 🔐 Security Notes

- SSH access is restricted to a single admin IP address
- ALB handles public traffic; EC2 instances remain in private subnets
- No credentials or private keys are stored in the repository
- Infrastructure changes are fully managed by Terraform – no manual steps

---

## 🧹 Destroy Infrastructure - Cleanup (Avoid AWS Charges)

```bash
terraform destroy --auto-approve
```

---

## 📚 Key Learning Outcomes

This project demonstrates ability to:

- Building **AWS infrastructure fully via Terraform**
- Automating server setup using user_data
- Implementing **Auto Scaling and Load Balancing**
- Managing **networking and security** with Terraform resources
- Following **IaC best practices** for reproducible deployments

---


## 👤 Author

**Thomas**  
Cloud & DevOps Engineer ☁️🚀  
