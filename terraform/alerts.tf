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
  alarm_description = "Too many 4xx errors"
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
  alarm_description = "Too many 5xx errors"
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
  alarm_description = "S3 latency exceeds threshold (500ms)"
  alarm_actions     = [aws_sns_topic.builditall_alerts.arn]
}

