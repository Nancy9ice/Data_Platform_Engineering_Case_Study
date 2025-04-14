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
