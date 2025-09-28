# Automated Infrastructure as Code (IaC) with Terraform & Ansible

[![Infrastructure Deployment Pipeline](https://github.com/username/repo-name/actions/workflows/deploy.yml/badge.svg)](https://github.com/username/repo-name/actions/workflows/deploy.yml)

This project demonstrates a complete Infrastructure as Code (IaC) solution that automates AWS infrastructure provisioning using **Terraform** and configuration management using **Ansible**, all orchestrated through **GitHub Actions** CI/CD pipeline.

## 🏗️ Architecture Overview

The project creates and configures:
- **AWS EC2 instance** with dynamic security group configuration
- **Dockerized Nginx** web server automatically deployed
- **Dynamic Ansible inventory** generated from Terraform outputs
- **GitHub Actions pipeline** for automated deployment

## 📂 Project Structure

```
Automate_Iac/
├── .github/
│   └── workflows/
│       └── deploy.yml           # GitHub Actions CI/CD pipeline
├── terraform/
│   ├── ansible/
│   │   ├── inventory.tpl        # Ansible inventory template
│   │   ├── playbook.yml         # Ansible playbook for Nginx deployment
│   │   └── terraform.tfstate    # Terraform state (auto-generated)
│   ├── instance.tf              # EC2 instance configuration
│   ├── provider.tf              # AWS provider configuration
│   ├── security_grp.tf          # Security group with dynamic rules
│   ├── terraform.tfvars         # Variable values
│   └── variable.tf              # Variable definitions
├── .gitignore                   # Git ignore rules
└── README.md                    # This file
```

## 🚀 Features

### Terraform Infrastructure
- **Dynamic Security Groups**: Configurable port access using variables
- **Automated Inventory Generation**: Creates Ansible inventory from EC2 outputs
- **Modular Configuration**: Clean separation of resources and variables
- **State Management**: Proper Terraform state handling

### Ansible Configuration Management
- **Docker Installation**: Automated Docker setup on EC2 instances
- **Nginx Deployment**: Containerized Nginx web server
- **Dynamic Inventory**: Auto-generated from Terraform outputs
- **Idempotent Playbooks**: Reliable and repeatable deployments

### CI/CD Pipeline
- **GitHub Actions Integration**: Fully automated deployment workflow
- **Multi-stage Pipeline**: Separate Terraform and Ansible jobs
- **Secret Management**: Secure handling of AWS credentials and SSH keys
- **Artifact Management**: Inventory file sharing between pipeline stages

## ⚙️ Configuration

### Infrastructure Variables

The project uses an object-type variable for clean configuration:

```hcl
instance_config = {
  Ports         = [22, 80, 8000]                    # Security group ports
  image_id      = "ami-00bb6a80f01f03502"           # Ubuntu AMI (ap-south-1)
  instance_type = "t2.micro"                        # EC2 instance type
  key_address   = "/Users/prabal/Downloads/developer.pem"  # SSH key path
}
```

### Security Group Rules

Dynamic ingress rules are created for each port in the `Ports` variable:

| Port | Purpose |
|------|---------|
| 22   | SSH access |
| 80   | HTTP (Nginx) |
| 8000 | Application port |

## 🛠️ Local Development Setup

### Prerequisites

1. **Terraform** (>= 1.0)
2. **Ansible** (>= 2.9) 
3. **AWS CLI** configured with credentials
4. **SSH Key Pair** named "developer" in AWS
5. **Git** for version control

### Local Deployment

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd Automate_Iac
   ```

2. **Configure variables** in `terraform/terraform.tfvars`:
   ```hcl
   instance_config = {
     Ports         = [22, 80, 8000]
     image_id      = "ami-00bb6a80f01f03502"  # Update for your region
     instance_type = "t2.micro"
     key_address   = "/path/to/your/key.pem"
   }
   ```

3. **Deploy infrastructure**:
   ```bash
   cd terraform
   terraform init
   terraform plan
   terraform apply
   ```

4. **Run Ansible configuration**:
   ```bash
   cd ansible
   ansible-playbook -i inventory.ini playbook.yml
   ```

## 🚀 GitHub Actions Deployment

### Required Secrets

Configure these secrets in your GitHub repository:

| Secret | Description |
|--------|-------------|
| `GIT_REPO_ACCESS_KEY` | AWS Access Key ID |
| `GIT_REPO_SECRET_KEY` | AWS Secret Access Key |
| `AWS_SSH_KEY` | Contents of your SSH private key |

### Pipeline Workflow

The automated pipeline consists of two jobs:

#### 1. Terraform Job
- Provisions AWS infrastructure
- Generates dynamic Ansible inventory
- Uploads inventory as artifact

#### 2. Ansible Job  
- Downloads inventory from previous job
- Installs Docker and Nginx on EC2 instance
- Configures web server

### Manual Deployment

Trigger deployment manually via GitHub Actions:
1. Navigate to your repository
2. Go to **Actions** tab
3. Select **Infrastructure Deployment Pipeline**
4. Click **Run workflow**

## 🔧 Technical Details

### Dynamic Security Group Configuration

The security group uses Terraform's `dynamic` blocks for flexible port configuration:

```hcl
dynamic "ingress" {
  for_each = var.instance_config.Ports
  iterator = port
  content {
    from_port   = port.value
    to_port     = port.value
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### Automated Inventory Generation

Terraform creates Ansible inventory dynamically:

```hcl
resource "local_file" "inventory" {
  content  = <<EOT
[aws_instance]
${aws_instance.my_instance[0].public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${var.instance_config.key_address} ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOT  
  filename = "${path.module}/ansible/inventory.ini"
}
```

### Containerized Application Deployment

The Ansible playbook deploys Nginx using Docker:

```yaml
- name: Run Nginx Container
  docker_container:
    name: nginx_web
    image: nginx
    ports:
      - "80:80"
    state: started
```

## 🌐 Accessing Your Application

After deployment, access your services:

- **Nginx Web Server**: `http://<ec2-public-ip>`
- **SSH Access**: `ssh -i /path/to/key.pem ubuntu@<ec2-public-ip>`

## 🔍 Troubleshooting

### Common Issues

1. **Terraform Issues**:
   ```bash
   # Check AWS credentials
   aws sts get-caller-identity
   
   # Verify AMI availability in region
   aws ec2 describe-images --image-ids ami-00bb6a80f01f03502
   ```

2. **Ansible Issues**:
   ```bash
   # Test connectivity
   ansible -i terraform/ansible/inventory.ini all -m ping
   
   # Check SSH key permissions
   chmod 600 /path/to/your/key.pem
   ```

3. **GitHub Actions Issues**:
   - Verify all required secrets are configured
   - Check workflow logs for specific error messages
   - Ensure AWS permissions include EC2, VPC, and SecurityGroup actions

### Debugging Commands

```bash
# Check Terraform state
terraform show

# Validate Terraform configuration
terraform validate

# Test Ansible playbook syntax
ansible-playbook --syntax-check playbook.yml

# Check Docker container status
docker ps -a
```

## 📊 Resource Costs

Estimated AWS costs (us-east-1 pricing):
- **t2.micro instance**: ~$8.50/month
- **EBS storage**: ~$1/month for 8GB
- **Data transfer**: Varies by usage

> **Note**: Use AWS Cost Calculator for accurate estimates in your region.

## 🧹 Cleanup

### Local Cleanup
```bash
cd terraform
terraform destroy
```

### CI/CD Cleanup
Currently, the pipeline doesn't include automated cleanup. Consider adding a destruction workflow for temporary environments.

## 🔒 Security Considerations

- **SSH Access**: Currently allows SSH from anywhere (0.0.0.0/0)
- **HTTP Access**: Web server accessible globally
- **Key Management**: SSH keys handled securely in CI/CD
- **State Files**: Contains sensitive information - use remote state for production

### Production Hardening

1. Restrict security group CIDR blocks
2. Use remote Terraform state with encryption
3. Implement proper IAM roles and policies
4. Enable AWS CloudTrail for audit logging
5. Use AWS Systems Manager for key management

## 🚦 Next Steps

- [ ] Add remote Terraform state (S3 + DynamoDB)
- [ ] Implement multi-environment support (dev/staging/prod)
- [ ] Add monitoring and logging (CloudWatch)
- [ ] Implement Blue/Green deployment strategy
- [ ] Add automated testing (Terratest, Molecule)
- [ ] Set up destruction workflow for temporary environments

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is for educational/demonstration purposes. Use at your own risk in production environments.

## 📚 Additional Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [Ansible Documentation](https://docs.ansible.com)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2)