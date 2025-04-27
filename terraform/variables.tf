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
  type        = string
  default     = "10.0.0.0/16"
  description = "VPC CIDR for BuildItAll project"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  description = "pubic subnet CIDR for BuildItAll project"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
  description = "private subnet CIDR for BuildItAll project"
}

variable "airflow_version" {
  type        = string
  default     = "2.10.3"
  description = "version for airflow"
}

variable "s3_bucket_name" {
  type        = string
  default     = "builditall-bucket"
  description = "Bucket name for project"
}

variable "s3_dags_path" {
  type        = string
  default     = "mwaa/dags/"
  description = "DAG path in S3 for MWAA"
}

variable "pyspark_s3_path" {
  type        = string
  default     = "mwaa/pyspark/"
  description = "pyspark path in S3 for MWAA"
}

variable "plugins_s3_path" {
  type        = string
  default     = "mwaa/plugins/"
  description = "Plugins path in S3 for MWAA"
}

variable "requirements_s3_path" {
  type        = string
  default     = "mwaa/requirements.txt"
  description = "Requirements path in S3 for MWAA"
}

variable "startup_script_s3_path" {
  type        = string
  default     = "mwaa/startup.sh"
  description = "Startiup script to setup airflow env"
}

variable "spark_raw_data_path" {
  type        = string
  default     = "builditall/raw_data/"
  description = "Path for spark raw data"
}

variable "spark_log_data_path" {
  type        = string
  default     = "builditall/logs/"
  description = "Path for spark logs data"
}

variable "spark_processed_data_path" {
  type        = string
  default     = "builditall/processed_data/"
  description = "Path for spark processed data"
}


variable "alert_email_addresses" {
  description = "email addresses to send alerts to"
  type        = list(string)
  default     = ["bestnyah7@gmail.com"]
}
