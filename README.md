# AWS WordPress Migration with Terraform and Ansible

A hands-on cloud migration project that moves a legacy WordPress application and MySQL database into AWS. The infrastructure is provisioned with Terraform and the WordPress EC2 host is configured with Ansible.

## Project goals

- Recreate a legacy WordPress environment in AWS using Infrastructure as Code.
- Separate the application and database tiers using VPC networking and security groups.
- Run WordPress on Amazon EC2 and MySQL on Amazon RDS.
- Use Amazon S3 as migration staging/storage with public access blocked.
- Automate host configuration with Ansible.
- Add basic CloudWatch alarms for EC2 CPU and RDS free storage.

## Architecture implemented

```text
Internet
   |
Internet Gateway
   |
Public Subnet (us-east-1a)
   |
EC2: Apache + PHP + WordPress
   |
Security-group-to-security-group MySQL access (3306)
   |
RDS MySQL (publicly_accessible = false)

S3 migration bucket <--- EC2 IAM role (read-only)
CloudWatch ---------> EC2 CPU / RDS free-storage alarms
```

The original learning implementation creates one public subnet and one private subnet in separate Availability Zones. The RDS subnet group references both of those subnets. See **Production improvements** below for how I would redesign the database network for a production workload.

## AWS services and tools

**AWS:** VPC, EC2, RDS MySQL, S3, IAM, Security Groups, CloudWatch  
**Infrastructure as Code:** Terraform  
**Configuration management:** Ansible  
**Application:** WordPress, Apache, PHP

## Repository structure

```text
.
├── terraform/
│   ├── provider.tf
│   ├── variables.tf
│   ├── networking.tf
│   ├── security.tf
│   ├── ec2.tf
│   ├── rds.tf
│   ├── s3.tf
│   ├── iam.tf
│   ├── cloudwatch.tf
│   ├── outputs.tf
│   └── terraform.tfvars.example
├── ansible/
│   ├── inventory.ini.example
│   ├── playbook.yml
│   ├── secrets.yml.example
│   └── wp-config.php.j2
├── docs/
│   └── screenshots/
├── .gitignore
└── README.md
```

## How the migration works

1. Terraform creates the VPC, public/private subnets, Internet Gateway, routing and security groups.
2. Terraform provisions the WordPress EC2 instance and a private-facing RDS MySQL instance.
3. Terraform creates an S3 bucket with public access blocked and gives the EC2 instance an IAM role with S3 read access.
4. Ansible connects to the EC2 host, installs Apache/PHP/MySQL client tooling, downloads WordPress and renders `wp-config.php` from a template.
5. WordPress connects to RDS over port 3306. The RDS security group accepts MySQL traffic from the EC2 security group rather than from the public internet.
6. CloudWatch alarms monitor high EC2 CPU utilization and low RDS free storage.

## Run locally

### Prerequisites

- AWS account and configured AWS CLI credentials
- Terraform
- Ansible
- An existing EC2 key pair

### 1. Configure Terraform variables

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your own values. The file is intentionally ignored by Git because it may contain sensitive data.

### 2. Provision the AWS infrastructure

```bash
terraform init
terraform plan
terraform apply
```

Terraform outputs the EC2 public IP and RDS endpoint.

### 3. Configure Ansible

```bash
cd ../ansible
cp inventory.ini.example inventory.ini
cp secrets.yml.example secrets.yml
```

Update `inventory.ini` with the EC2 public IP and local path to your private key. Update `secrets.yml` with your database values and RDS endpoint. Both files are excluded from Git.

### 4. Configure WordPress

```bash
ansible-playbook -i inventory.ini playbook.yml
```

## Security decisions in the project

- RDS is configured with `publicly_accessible = false`.
- MySQL ingress is restricted to the EC2 security group.
- S3 public access is blocked.
- EC2 receives S3 read permissions through an IAM instance profile rather than static AWS credentials on the server.
- Database credentials, private keys, Terraform state and local inventory are excluded from this public repository.

## Production improvements

This repository preserves the core architecture of the hands-on project rather than presenting it as production-ready. For a production deployment, I would:

- Put the database tier entirely in private subnets across at least two Availability Zones.
- Place the application behind an Application Load Balancer and run EC2 instances in private application subnets.
- Replace broad SSH exposure with AWS Systems Manager Session Manager or tightly restricted administrative access.
- Store database credentials in AWS Secrets Manager or Systems Manager Parameter Store instead of local variable files.
- Enable RDS Multi-AZ, backups, encryption and a deletion-protection/final-snapshot strategy appropriate to the workload.
- Add HTTPS with ACM, Route 53/DNS integration and stronger application-level hardening.
- Use more granular IAM permissions instead of the AWS-managed S3 read-only policy where possible.
- Add remote, encrypted Terraform state with locking and CI validation.

## What I learned

This project helped me connect several cloud-engineering concepts in one workflow: network segmentation, security-group relationships, IAM roles, infrastructure provisioning, configuration automation, application-to-database connectivity, migration staging and basic monitoring. It also highlighted the difference between a working learning environment and the additional controls required for production workloads.

## Notes

This repository is a sanitized portfolio version of a hands-on learning project. Account-specific endpoints, IP addresses, private keys, passwords, Terraform state and other generated/sensitive artifacts are intentionally excluded.
