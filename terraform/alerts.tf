# alerts via SNS topic + Slack Webhook team subscriptions 
resource "aws_sns_topic" "builditall_alerts" {
  name = "${var.project}-${var.env_prefix}-alerts-topic"
}

# subribe each email to the set alerts
resource "aws_sns_topic_subscription" "builditall_email_alerts" {
  for_each = toset(var.alert_email_addresses)

  topic_arn = aws_sns_topic.builditall_alerts.arn
  protocol  = "email"
  endpoint  = each.key

  depends_on = [aws_sns_topic.builditall_alerts]
}

# Alerts 
# 4xx and 5xx errors
# 4xx errors → Client-side issues (e.g., bad request, access denied, not found)
# 5xx errors → Server-side issues (e.g., internal error, service unavailable)
resource "aws_cloudwatch_metric_alarm" "builditall_s3_bucket_4xx_errors" {
  alarm_name          = "${var.project}-${var.env_prefix}-S3Bucket4xxErrors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "4xxErrors"
  namespace           = "AWS/S3"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  dimensions = {
    BucketName = aws_s3_bucket.builditall_secure_bucket.bucket
  }
  alarm_description = "BuildItAll-S3: Too many 4xx errors"
  alarm_actions     = [aws_sns_topic.builditall_alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "s3_bucket_5xx_errors" {
  alarm_name          = "S3Bucket5xxErrors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "5xxErrors"
  namespace           = "AWS/S3"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  dimensions = {
    BucketName = aws_s3_bucket.builditall_secure_bucket.bucket
  }
  alarm_description = "BuildItAll-S3: Too many 5xx errors"
  alarm_actions     = [aws_sns_topic.builditall_alerts.arn]
}

# S3 object retrevial latency alert
resource "aws_cloudwatch_metric_alarm" "builditall_s3_high_latency" {
  alarm_name          = "${var.project}-${var.env_prefix}-S3HighLatency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FirstByteLatency"
  namespace           = "AWS/S3"
  period              = 300
  statistic           = "Average"
  threshold           = 500
  dimensions = {
    BucketName = aws_s3_bucket.builditall_secure_bucket.bucket
  }
  alarm_description = "BuildItAll-S3: latency exceeds threshold (500ms)"
  alarm_actions     = [aws_sns_topic.builditall_alerts.arn]
}

# MwAA Alerts
# Task Instances Failed
resource "aws_cloudwatch_metric_alarm" "builditall_mwaa_task_instances_failed" {
  alarm_name          = "${var.project}-${var.env_prefix}-MWAATaskInstancesFailed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "TaskInstancesFailed"
  namespace           = "AWS/MWAA"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  dimensions = {
    EnvironmentName = aws_mwaa_environment.builditall_mwaa_env.name
  }
  alarm_description = "BuildItAll-MWAA: One or more Airflow task instances failed"
  alarm_actions     = [aws_sns_topic.builditall_alerts.arn]
}

# Scheduler Lag
resource "aws_cloudwatch_metric_alarm" "builditall_mwaa_scheduler_lag" {
  alarm_name          = "${var.project}-${var.env_prefix}-MWAASchedulerLag"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "SchedulerLag"
  namespace           = "AWS/MWAA"
  period              = 300
  statistic           = "Average"
  threshold           = 60 # seconds
  dimensions = {
    EnvironmentName = aws_mwaa_environment.builditall_mwaa_env.name
  }
  alarm_description = "BuildItAll-MWAA: Scheduler lag exceeds 60 seconds"
  alarm_actions     = [aws_sns_topic.builditall_alerts.arn]
}

# Web Server Latency
resource "aws_cloudwatch_metric_alarm" "builditall_mwaa_webserver_latency" {
  alarm_name          = "${var.project}-${var.env_prefix}-MWAAWebServerLatency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "WebServerLatency"
  namespace           = "AWS/MWAA"
  period              = 300
  statistic           = "Average"
  threshold           = 1000 # ms
  dimensions = {
    EnvironmentName = aws_mwaa_environment.builditall_mwaa_env.name
  }
  alarm_description = "MWAA: Web server latency exceeds 1000ms"
  alarm_actions     = [aws_sns_topic.builditall_alerts.arn]
}

# Environment Health
resource "aws_cloudwatch_metric_alarm" "builditall_mwaa_environment_health" {
  alarm_name          = "${var.project}-${var.env_prefix}-MWAAEnvironmentHealth"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "EnvironmentHealth"
  namespace           = "AWS/MWAA"
  period              = 300
  statistic           = "Average"
  threshold           = 1 # healthy = 1, unhealthy = 0
  dimensions = {
    EnvironmentName = aws_mwaa_environment.builditall_mwaa_env.name
  }
  alarm_description = "BuildItAll-MWAA: Environment health is degraded"
  alarm_actions     = [aws_sns_topic.builditall_alerts.arn]
}
