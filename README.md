# 🚀 Terraform AWS Apache Web Server (Production-Style Networking)

This project provisions a fully functional Apache web server on AWS using **Terraform**.  
It demonstrates real-world **Infrastructure as Code (IaC)** practices including custom networking, security configuration, and automated server provisioning.

---

## 🏗️ Architecture Overview

The infrastructure deployed includes:

- **Custom VPC** – 10.0.0.0/16
- **Public Subnet** in a specific Availability Zone
- **Internet Gateway** for public internet access
- **Route Table** with default route to the internet
- **Security Group** allowing:
  - SSH (restricted to my IP)
  - HTTP (80)
  - HTTPS (443)
- **EC2 Ubuntu Instance**
- **Elastic IP** for consistent public access
- **Apache Web Server** installed automatically using `user_data`

---

## 🌍 Result

After deployment, the EC2 instance hosts a web page accessible via browser:

```
Hello from Terraform!
```

Terraform outputs the public IP to access the site.

---

## 🛠️ Technologies Used

| Tool | Purpose |
|------|---------|
| Terraform | Infrastructure as Code |
| AWS EC2 | Virtual Server |
| AWS VPC | Networking |
| AWS Security Groups | Firewall Rules |
| Apache2 | Web Server |
| Cloud-init | Instance bootstrapping |

---

## 📁 Project Structure

```
terraform-aws-apache-webserver/
│
├── main.tf          # Core infrastructure resources
├── variables.tf     # Input variables
├── provider.tf      # AWS provider configuration
├── outputs.tf       # Output values (Elastic IP, URL)
├── README.md        # Project documentation
└── .gitignore       # Files excluded from Git
```

---

## ▶️ How to Deploy

### 1️⃣ Clone Repository
```bash
git clone https://github.com/thomasasamba-bot/terraform-aws-apache-webserver.git
cd terraform-aws-apache-webserver
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

## 🌐 Access the Web Server

After deployment, Terraform will output:

```
website_url = http://<Elastic-IP>
```

Paste that into your browser to see the hosted page.

---

## 🔐 Security Notes

- SSH access is restricted to a single IP address
- Security group allows only necessary web traffic
- No credentials or private keys are stored in the repository

---

## 🧹 Destroy Infrastructure (Avoid Charges)

```bash
terraform destroy
```

---

## 📚 Key Learning Outcomes

This project demonstrates ability to:

- Design AWS networking from scratch
- Configure secure access controls
- Automate server setup using cloud-init
- Manage infrastructure lifecycle with Terraform
- Troubleshoot real-world cloud provisioning issues

---


## 👤 Author

**Thomas**  
Cloud & DevOps Engineer ☁️🚀  
