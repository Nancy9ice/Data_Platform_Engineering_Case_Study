# create random id for bucket namimg to ensure 
# global bucket uniqueness
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# "${var.project}-${var.env_prefix}-
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

# use server-side encryption by default for all objects stored in the bucket if necessary?
# resource "aws_s3_bucket_server_side_encryption_configuration" "buiditall_bucket_sse" {
#   bucket = aws_s3_bucket.secure_bucket.id

#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }

# Block all public access to the bucket
resource "aws_s3_bucket_public_access_block" "builditall_bucket_block" {
  bucket = aws_s3_bucket.builditall_secure_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


##### MWAA #####
