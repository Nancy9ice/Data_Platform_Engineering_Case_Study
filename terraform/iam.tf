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
        Sid    = "S3Access"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          aws_s3_bucket.builditall_secure_bucket.arn,
          "${aws_s3_bucket.builditall_secure_bucket.arn}/*"
        ]
      },
      {
        Sid    = "EMRAccess"
        Effect = "Allow"
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
        Resource = "*"
      },
      {
        Sid      = "AllowPassRoleForEMR"
        Effect   = "Allow"
        Action   = "iam:PassRole"
        Resource = "*"
      },
      {
        Sid    = "CloudWatchLogsAccess"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = [
          "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:airflow-${var.project}-${var.env_prefix}-mwaa-environment-*",
          "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:airflow-${var.project}-${var.env_prefix}-mwaa-environment-*:*"
        ]
      },
      {
        Sid    = "MWAABasicPermissions"
        Effect = "Allow"
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
        Resource = "*"
      },
      {
        Sid    = "EC2InstancePermissions"
        Effect = "Allow"
        Action = [
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "ec2:DescribeInstances",
          "ec2:DescribeKeyPairs",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcs",
          "ec2:CreateSecurityGroup",
          "ec2:AuthorizeSecurityGroupIngress"
        ]
        Resource = "*"
      },
      {
        Sid      = "GetAccountPublicAccessBlock"
        Effect   = "Allow"
        Action   = "s3:GetAccountPublicAccessBlock"
        Resource = "*"
      },
      {
        Sid      = "GetBucketPublicAccessBlock"
        Effect   = "Allow"
        Action   = "s3:GetBucketPublicAccessBlock"
        Resource = aws_s3_bucket.builditall_secure_bucket.arn
      },
      {
        Sid    = "SQSAccessLimited"
        Effect = "Allow"
        Action = [
          "sqs:ChangeMessageVisibility",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl",
          "sqs:ReceiveMessage",
          "sqs:SendMessage"
        ]
        Resource = "arn:aws:sqs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:airflow-celery-*"
      },
      {
        Sid    = "KMSSQSAccess"
        Effect = "Allow"
        Action = [
          "kms:GenerateDataKey*",
          "kms:Decrypt",
          "kms:Encrypt"
        ]
        Resource = "*"
        Condition = {
          "StringEquals" = {
            "kms:ViaService" = "sqs.${var.aws_region}.amazonaws.com"
          }
        }
      },
      {
        Sid    = "SecretsManagerAccess"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "*"
      },
      {
        Sid    = "S3StartupScriptAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "${aws_s3_bucket.builditall_secure_bucket.arn}/${var.startup_script_s3_path}",
          "${aws_s3_bucket.builditall_secure_bucket.arn}/${var.requirements_s3_path}"
        ]
      },
      {
        Sid      = "PublishAirflowMetrics"
        Effect   = "Allow"
        Action   = "airflow:PublishMetrics"
        Resource = "arn:aws:airflow:${var.aws_region}:${data.aws_caller_identity.current.account_id}:environment/${var.project}-${var.env_prefix}-mwaa-environment"
      },
      {
        Sid    = "SESSendEmailPermissions"
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
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


# spark default roles 
resource "aws_iam_role" "emr_service_role" {
  name = "EMR_DefaultRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "elasticmapreduce.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach EMR service role policy
resource "aws_iam_role_policy_attachment" "emr_service_role_attachment" {
  role       = aws_iam_role.emr_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEMRServicePolicy_v2"
}


resource "aws_iam_role" "emr_ec2_role" {
  name = "EMR_EC2_DefaultRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach EMR EC2 role policy
resource "aws_iam_role_policy_attachment" "emr_ec2_role_attachment" {
  role       = aws_iam_role.emr_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role"
}