variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet (web tier)"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet (database tier)"
  type        = string
}

variable "key_name" {
  description = "Existing EC2 Key Pair name for SSH access"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for web and database servers"
  type        = string
}

variable "db_name" {
  description = "Application database name"
  type        = string
}

variable "db_username" {
  description = "Database master username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "bucket_name" {
  description = "S3 bucket name for migration artifacts/backups"
  type        = string
}




