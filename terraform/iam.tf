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
          Service = "airflow.amazonaws.com"
        }
      }
    ]
  })
}

# policies for S3 and EMR to mwaa_role
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
          "${aws_s3_bucket.builditall_secure_bucket.arn}",
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
      }
    ]
  })
}
