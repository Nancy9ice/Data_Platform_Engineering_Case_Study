# Output for the VPC ID
output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "The ID of the VPC"
}

# Output for the public subnets
output "public_subnet_ids" {
  value       = module.vpc.public_subnets
  description = "The IDs of the public subnets"
}

# Output for the private subnets
output "private_subnet_ids" {
  value       = module.vpc.private_subnets
  description = "The IDs of the private subnets"
}

# Output for the security group ID
output "security_group_id" {
  value       = aws_security_group.web_sg.id
  description = "The ID of the web security group"
}

# Output for the S3 bucket name
output "s3_bucket_name" {
  value       = aws_s3_bucket.builditall_secure_bucket.bucket
  description = "The name of the S3 bucket"
}

# Output for the S3 bucket versioning status
output "s3_bucket_versioning_status" {
  value       = aws_s3_bucket_versioning.builditall_bucket_versioning.versioning_configuration[0].status
  description = "The versioning status of the S3 bucket"
}

# # output for airflow env
# output "mwaa_environment_name" {
#   description = "The name of the MWAA environment"
#   value       = aws_mwaa_environment.builditall_mwaa_env.name
# }

# # mwaa airflow env arn
# output "mwaa_environment_arn" {
#   description = "The ARN of the MWAA environment"
#   value       = aws_mwaa_environment.builditall_mwaa_env.arn
# }

# # airflow mwaa url
# output "mwaa_webserver_url" {
#   description = "The web UI URL of the MWAA environment"
#   value       = aws_mwaa_environment.builditall_mwaa_env.webserver_url
# }

# # exe role arn for airflow mwaa
# output "mwaa_execution_role_arn" {
#   description = "The ARN of the MWAA IAM role"
#   value       = aws_iam_role.builditall_mwaa_role.arn
# }

# sns topic arn
output "sns_alerts_topic_arn" {
  description = "ARN of the SNS topic used for BuildItAll alerts"
  value       = aws_sns_topic.builditall_alerts.arn
}

# topic name
output "sns_alerts_topic_name" {
  description = "Name of the SNS topic for alerts"
  value       = aws_sns_topic.builditall_alerts.name
}

# dashboard link
output "cloudwatch_dashboard_url" {
  description = "Console URL for the Builditall CloudWatch Dashboard"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.builditall_dashboard.dashboard_name}"
}
