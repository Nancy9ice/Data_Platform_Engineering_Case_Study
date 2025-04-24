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
          Service = [
            "airflow.amazonaws.com",
            "airflow-env.amazonaws.com"
          ]
        }
      }
    ]
  })
}

# policies for S3, EMR, and SQS to mwaa_role
data "aws_caller_identity" "current" {}

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
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:DescribeLogStreams"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:airflow-${var.project}-${var.env_prefix}-mwaa-environment-*",
          "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:airflow-${var.project}-${var.env_prefix}-mwaa-environment-*:*"
        ]
      },
      {
        Sid = "MWAABasicPermissions"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKey*",
          "kms:Encrypt",
          "cloudwatch:PutMetricData",
          "ecs:RunTask",
          "ecs:DescribeTasks",
          "ecs:RegisterTaskDefinition",
          "ecs:DescribeTaskDefinition",
          "ecs:ListTasks"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "EC2NetworkInterfacePermissions"
        Action = [
          "ec2:DescribeNetworkInterfaces",
          "ec2:CreateNetworkInterface",
          "ec2:CreateNetworkInterfacePermission",
          "ec2:DeleteNetworkInterface",
          "ec2:DeleteNetworkInterfacePermission",
          "ec2:DescribeInstances",
          "ec2:AttachNetworkInterface"
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
