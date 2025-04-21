# Role for airflow svc
resource "aws_iam_role" "builditall_mwaa_role" {
  name = "${var.project}-${var.env_prefix}-mwaa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "airflow-env.amazonaws.com"
        }
      }
    ]
  })
}

# policies for S3, EMR, and SQS to mwaa_role
resource "aws_iam_role_policy" "builditall_mwaa_policy" {
  name = "${var.project}-${var.env_prefix}-mwaa-policy"
  role = aws_iam_role.builditall_mwaa_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "S3Access"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject"
        ]
        Effect = "Allow"
        Resource = [
          aws_s3_bucket.builditall_secure_bucket.arn,
          "${aws_s3_bucket.builditall_secure_bucket.arn}/*"
        ]
      },
      {
        Sid = "EMRAccess"
        Action = [
          "elasticmapreduce:RunJobFlow",
          "elasticmapreduce:TerminateJobFlows",
          "elasticmapreduce:AddJobFlowSteps",
          "elasticmapreduce:DescribeCluster",
          "elasticmapreduce:DescribeStep",
          "elasticmapreduce:ListClusters",
          "elasticmapreduce:ListSteps",
          "elasticmapreduce:ListInstanceGroups"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid      = "AllowPassRoleForEMR"
        Action   = "iam:PassRole"
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "CloudWatchLogsAccess"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid    = "GetAccountPublicAccessBlock"
        Effect = "Allow"
        Action = [
          "s3:GetAccountPublicAccessBlock"
        ]
        Resource = "*"
      },
      {
        Sid    = "GetBucketPublicAccessBlock"
        Effect = "Allow"
        Action = [
          "s3:GetBucketPublicAccessBlock"
        ]
        Resource = aws_s3_bucket.builditall_secure_bucket.arn
      },
      {
        Sid = "SQSAccess"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ListQueues"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# sns topic policy
resource "aws_sns_topic_policy" "s3_sns_policy" {
  arn = aws_sns_topic.builditall_alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowS3Publish"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.builditall_alerts.arn
        Condition = {
          ArnLike = {
            "aws:SourceArn" = aws_s3_bucket.builditall_secure_bucket.arn
          }
        }
      }
    ]
  })
}
