# 🚀 Terraform AWS Apache Web Server

This project provisions a fully functional Apache web server on AWS using Terraform.

It demonstrates Infrastructure as Code (IaC) skills including networking, compute, and security configuration in a custom VPC.

---

## 🏗️ Architecture

The infrastructure includes:

- Custom VPC (10.0.0.0/16)
- Public Subnet
- Internet Gateway
- Route Table with internet access
- Security Group allowing SSH, HTTP, HTTPS
- EC2 Ubuntu Instance (Apache installed via user_data)
- Elastic IP for public access

---

## 🌍 Result

After deployment, the server hosts a custom webpage:

**"Hello from Terraform!"**

Accessible via the Elastic IP output by Terraform.

---

## 🛠️ Technologies Used

- Terraform
- AWS EC2
- AWS VPC Networking
- Apache Web Server
- Cloud-init (user_data bootstrapping)

---

## ▶️ How to Deploy

### 1️⃣ Clone the repo

git clone https://github.com/YOUR_USERNAME/terraform-aws-apache-webserver.git
cd terraform-aws-apache-webserver

### 2️⃣ Initialize Terraform
terraform init

### 3️⃣ Provide your IP for SSH access
export TF_VAR_my_ip="YOUR_PUBLIC_IP/32"

### 4️⃣ Deploy
terraform apply

### 5️⃣ Access the Website
http://<Elastic-IP>

## 🧹 Cleanup
To avoid AWS charges:
terraform destroy

📚 Skills Learned
Designing AWS networking with Terraform
Managing security groups and routing
Automating server provisioning with user_data
Debugging cloud-init and connectivity issues

