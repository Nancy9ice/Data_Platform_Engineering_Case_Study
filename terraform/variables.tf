variable "env_prefix" {
  type        = string
  default     = "prod"
  description = "env prefix to track all resources used"
}

variable "project" {
  type        = string
  default     = "builditall"
  description = "project name to track all resources used"
}


variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-north-1"
}

variable "aws_access_key_id" {
  type        = string
  description = "AWS account Access Key"
  sensitive   = true
}

variable "aws_secret_access_key" {
  type        = string
  description = "AWS account Access Key"
  sensitive   = true
}

variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "VPC CIDR for BuildItAll project"
}

variable "public_subnet_cidrs" {
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  description = "pubic subnet CIDR for BuildItAll project"
}

variable "private_subnet_cidrs" {
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
  description = "private subnet CIDR for BuildItAll project"
}


