resource "aws_cloudwatch_dashboard" "builditall_dashboard" {
  dashboard_name = "${var.project}-${var.env_prefix}-MonitoringDashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric", x = 0, y = 0, width = 3, height = 6,
        properties = {
          title = "Total Bucket Size (Bytes)",
          view  = "singleValue",
          metrics = [
            ["AWS/S3", "BucketSizeBytes", "BucketName", aws_s3_bucket.builditall_secure_bucket.bucket, "StorageType", "StandardStorage"]
          ],
          period = 86400,
          stat   = "Average",
          region = var.aws_region
        }
      },

      {
        type = "metric", x = 3, y = 0, width = 3, height = 6,
        properties = {
          title = "Total Number of Objects",
          view  = "singleValue",
          metrics = [
            ["AWS/S3", "NumberOfObjects", "BucketName", aws_s3_bucket.builditall_secure_bucket.bucket, "StorageType", "AllStorageTypes"]
          ],
          period = 86400,
          stat   = "Average",
          region = var.aws_region
        }
      },

      {
        type = "metric", x = 6, y = 0, width = 3, height = 6,
        properties = {
          title = "DELETE Requests",
          view  = "singleValue",
          metrics = [
            ["AWS/S3", "DeleteRequests", "BucketName", aws_s3_bucket.builditall_secure_bucket.bucket, "FilterId", "EntireBucket"]
          ],
          period = 300,
          stat   = "Sum",
          region = var.aws_region
        }
      },

      {
        type = "metric", x = 9, y = 0, width = 3, height = 6,
        properties = {
          title = "POST Requests",
          view  = "singleValue",
          metrics = [
            ["AWS/S3", "PostRequests", "BucketName", aws_s3_bucket.builditall_secure_bucket.bucket, "FilterId", "EntireBucket"]
          ],
          period = 300,
          stat   = "Sum",
          region = var.aws_region
        }
      },

      {
        type = "metric", x = 0, y = 6, width = 6, height = 6,
        properties = {
          title = "4xx Errors",
          view  = "gauge",
          metrics = [
            ["AWS/S3", "4xxErrors", "BucketName", aws_s3_bucket.builditall_secure_bucket.bucket, "FilterId", "EntireBucket"]
          ],
          period = 300,
          stat   = "Sum",
          region = var.aws_region,
          yAxis = {
            left = {
              min = 0,
              max = 100
            }
          }
        }
      },

      {
        type = "metric", x = 6, y = 6, width = 6, height = 6,
        properties = {
          title = "5xx Errors",
          view  = "gauge",
          metrics = [
            ["AWS/S3", "5xxErrors", "BucketName", aws_s3_bucket.builditall_secure_bucket.bucket, "FilterId", "EntireBucket"]
          ],
          period = 300,
          stat   = "Sum",
          region = var.aws_region,
          yAxis = {
            left = {
              min = 0,
              max = 100
            }
          }
        }
      },

      {
        type = "metric", x = 12, y = 6, width = 12, height = 6,
        properties = {
          title = "Bytes Uploaded",
          view  = "timeSeries",
          metrics = [
            ["AWS/S3", "BytesUploaded", "BucketName", aws_s3_bucket.builditall_secure_bucket.bucket, "FilterId", "EntireBucket"]
          ],
          period = 300,
          stat   = "Sum",
          region = var.aws_region
        }
      },

      {
        type = "metric", x = 0, y = 12, width = 12, height = 6,
        properties = {
          title = "Bytes Downloaded",
          view  = "timeSeries",
          metrics = [
            ["AWS/S3", "BytesDownloaded", "BucketName", aws_s3_bucket.builditall_secure_bucket.bucket, "FilterId", "EntireBucket"]
          ],
          period = 300,
          stat   = "Sum",
          region = var.aws_region
        }
      },

      {
        type = "metric", x = 12, y = 12, width = 12, height = 6,
        properties = {
          title = "Total Request Latency (ms)",
          view  = "timeSeries",
          metrics = [
            ["AWS/S3", "FirstByteLatency", "BucketName", aws_s3_bucket.builditall_secure_bucket.bucket, "FilterId", "EntireBucket"],
            ["AWS/S3", "TotalRequestLatency", "BucketName", aws_s3_bucket.builditall_secure_bucket.bucket, "FilterId", "EntireBucket"]
          ],
          period = 300,
          stat   = "Average",
          region = var.aws_region
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket.builditall_secure_bucket]
}
