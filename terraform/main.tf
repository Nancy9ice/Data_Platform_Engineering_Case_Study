# create random id for bucket namimg to ensure 
# global bucket uniqueness
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# s3 bucket 
resource "aws_s3_bucket" "builditall_secure_bucket" {
  bucket        = "${var.project}-${var.env_prefix}-bucket-${random_id.bucket_suffix.hex}"
  force_destroy = false

  tags = {
    Name        = "${var.project}-${var.env_prefix}-bucket"
    Project     = var.project
    Terraform   = "true"
    Environment = var.env_prefix
  }
}

# Enable versioning for the bucket to maintain object versions.
# Versioning ensures that even if an object is accidentally 
# deleted or overwritten, you can retrieve a previous version.
resource "aws_s3_bucket_versioning" "builditall_bucket_versioning" {
  bucket = aws_s3_bucket.builditall_secure_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# use server-side encryption by default for all objects stored in the bucket if necessary.
# Encryption is important because it protects sensitive data from unauthorized access, 
# ensures privacy, and helps meet regulatory compliance requirements.
resource "aws_s3_bucket_server_side_encryption_configuration" "buiditall_bucket_sse" {
  bucket = aws_s3_bucket.builditall_secure_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block all public access to the bucket
resource "aws_s3_bucket_public_access_block" "builditall_bucket_block" {
  bucket = aws_s3_bucket.builditall_secure_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_metric" "builditall_request_metrics" {
  bucket = aws_s3_bucket.builditall_secure_bucket.bucket
  name   = "EntireBucket"

  filter {
    prefix = ""
  }
}

# dags, pugins folder and requirments for mwaa
resource "aws_s3_object" "mwaa_dags_folder" {
  bucket  = aws_s3_bucket.builditall_secure_bucket.bucket
  key     = var.s3_dags_path
  content = ""
}

resource "aws_s3_object" "mwaa_plugins_folder" {
  bucket  = aws_s3_bucket.builditall_secure_bucket.bucket
  key     = var.plugins_s3_path
  content = ""
}

resource "aws_s3_object" "mwaa_requirements_file" {
  bucket  = aws_s3_bucket.builditall_secure_bucket.bucket
  key     = var.requirements_s3_path
  content = "pandas"
}

# more folders for data processing
resource "aws_s3_object" "spark_raw_folder" {
  bucket  = aws_s3_bucket.builditall_secure_bucket.bucket
  key     = var.spark_raw_data_path
  content = ""
}

resource "aws_s3_object" "spark_logs_folder" {
  bucket  = aws_s3_bucket.builditall_secure_bucket.bucket
  key     = var.spark_log_data_path
  content = ""
}

resource "aws_s3_object" "spark_processed_folder" {
  bucket  = aws_s3_bucket.builditall_secure_bucket.bucket
  key     = var.spark_processed_data_path
  content = ""
}


##### MWAA #####
resource "aws_mwaa_environment" "builditall_mwaa_env" {
  name               = "${var.project}-${var.env_prefix}-mwaa-environment"
  airflow_version    = var.airflow_version
  execution_role_arn = aws_iam_role.builditall_mwaa_role.arn
  network_configuration {
    security_group_ids = [aws_security_group.web_sg.id]
    subnet_ids         = module.vpc.private_subnets
  }

  source_bucket_arn = aws_s3_bucket.builditall_secure_bucket.arn

  dag_s3_path          = var.s3_dags_path
  plugins_s3_path      = var.plugins_s3_path
  requirements_s3_path = var.requirements_s3_path

  # airflow configs
  webserver_access_mode = "PUBLIC_ONLY"
  schedulers            = 3
  airflow_configuration_options = {
    "core.default_task_retries"     = 5
    "core.parallelism"              = 10
    "celery.worker_autoscale"       = "10,10"
    "webserver.default_ui_timezone" = "Europe/Stockholm"
  }

  logging_configuration {
    dag_processing_logs {
      log_level = "DEBUG"
      enabled   = true
    }
    scheduler_logs {
      log_level = "INFO"
      enabled   = true
    }
    task_logs {
      log_level = "WARNING"
      enabled   = true
    }
    webserver_logs {
      log_level = "ERROR"
      enabled   = true
    }
    worker_logs {
      enabled   = true
      log_level = "CRITICAL"
    }
  }

  depends_on = [
    aws_s3_bucket.builditall_secure_bucket,
    aws_s3_object.mwaa_dags_folder,
    aws_s3_object.mwaa_plugins_folder,
    aws_s3_object.mwaa_requirements_file,
    # module.vpc.nat_gateway_ids,
    # module.vpc.private_subnets
  ]

  tags = {
    Name        = "${var.project}-${var.env_prefix}-mwaa-env"
    Project     = var.project
    Terraform   = "true"
    Environment = var.env_prefix
  }
}
