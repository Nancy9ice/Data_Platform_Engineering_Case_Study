resource "aws_cloudwatch_dashboard" "builditall_dashboard" {
  dashboard_name = "${var.project}-${var.env_prefix}-MonitoringDashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        height = 5,
        width  = 2,
        y      = 0,
        x      = 0,
        type   = "metric",
        properties = {
          metrics = [
            ["AWS/S3", "BucketSizeBytes", "BucketName", "builditall-prod-bucket-7efa8d0a", "StorageType", "StandardStorage"]
          ],
          period = 86400,
          region = "eu-north-1",
          stat   = "Average",
          title  = "Total Bucket Size (Bytes)",
          view   = "singleValue"
        }
      },
      {
        height = 5,
        width  = 2,
        y      = 0,
        x      = 2,
        type   = "metric",
        properties = {
          metrics = [
            ["AWS/S3", "NumberOfObjects", "BucketName", "builditall-prod-bucket-7efa8d0a", "StorageType", "AllStorageTypes"]
          ],
          period = 86400,
          region = "eu-north-1",
          stat   = "Average",
          title  = "Total Number of Objects",
          view   = "singleValue"
        }
      },
      {
        height = 5,
        width  = 2,
        y      = 0,
        x      = 4,
        type   = "metric",
        properties = {
          metrics = [
            ["AWS/S3", "DeleteRequests", "BucketName", "builditall-prod-bucket-7efa8d0a", "FilterId", "EntireBucket", { region = "eu-north-1" }]
          ],
          period = 300,
          region = "eu-north-1",
          stat   = "Sum",
          title  = "S3 DELETE Requests",
          view   = "singleValue"
        }
      },
      {
        height = 5,
        width  = 2,
        y      = 0,
        x      = 6,
        type   = "metric",
        properties = {
          metrics = [
            ["AWS/S3", "PostRequests", "BucketName", "builditall-prod-bucket-7efa8d0a", "FilterId", "EntireBucket", { region = "eu-north-1" }]
          ],
          period = 300,
          region = "eu-north-1",
          stat   = "Sum",
          title  = "S3 POST Requests",
          view   = "singleValue"
        }
      },
      {
        height = 6,
        width  = 4,
        y      = 5,
        x      = 0,
        type   = "metric",
        properties = {
          metrics = [
            ["AWS/S3", "4xxErrors", "BucketName", "builditall-prod-bucket-7efa8d0a", "FilterId", "EntireBucket", { region = "eu-north-1" }]
          ],
          period = 300,
          region = "eu-north-1",
          stat   = "Sum",
          title  = "S3 4xx Errors",
          view   = "gauge",
          yAxis = {
            left = {
              min = 0,
              max = 100
            }
          }
        }
      },
      {
        height = 6,
        width  = 4,
        y      = 5,
        x      = 4,
        type   = "metric",
        properties = {
          metrics = [
            ["AWS/S3", "5xxErrors", "BucketName", "builditall-prod-bucket-7efa8d0a", "FilterId", "EntireBucket", { region = "eu-north-1" }]
          ],
          period = 300,
          region = "eu-north-1",
          stat   = "Sum",
          title  = "S3 5xx Errors",
          view   = "gauge",
          yAxis = {
            left = {
              min = 0,
              max = 100
            }
          }
        }
      },
      {
        height = 5,
        width  = 8,
        y      = 12,
        x      = 8,
        type   = "metric",
        properties = {
          metrics = [
            ["AWS/S3", "BytesUploaded", "BucketName", "builditall-prod-bucket-7efa8d0a", "FilterId", "EntireBucket", { region = "eu-north-1" }]
          ],
          period = 300,
          region = "eu-north-1",
          stat   = "Sum",
          title  = "S3 Bytes Uploaded",
          view   = "timeSeries"
        }
      },
      {
        height = 6,
        width  = 8,
        y      = 11,
        x      = 0,
        type   = "metric",
        properties = {
          metrics = [
            ["AWS/S3", "BytesDownloaded", "BucketName", "builditall-prod-bucket-7efa8d0a", "FilterId", "EntireBucket", { region = "eu-north-1" }]
          ],
          period = 300,
          region = "eu-north-1",
          stat   = "Sum",
          title  = "S3 Bytes Downloaded",
          view   = "timeSeries"
        }
      },
      {
        height = 6,
        width  = 8,
        y      = 6,
        x      = 8,
        type   = "metric",
        properties = {
          metrics = [
            ["AWS/S3", "FirstByteLatency", "BucketName", "builditall-prod-bucket-7efa8d0a", "FilterId", "EntireBucket", { region = "eu-north-1" }],
            [".", "TotalRequestLatency", ".", ".", ".", ".", { region = "eu-north-1" }]
          ],
          period = 300,
          region = "eu-north-1",
          stat   = "Average",
          title  = "S3 Total Request Latency (ms)",
          view   = "timeSeries"
        }
      },
      {
        height = 6,
        width  = 3,
        y      = 0,
        x      = 21,
        type   = "metric",
        properties = {
          metrics = [
            ["AWS/MWAA", "DAGsRunning", "EnvironmentName", "builditall-prod-mwaa-environment", { region = "eu-north-1" }]
          ],
          period = 300,
          region = "eu-north-1",
          stat   = "Average",
          title  = "Airflow DAGs Running",
          view   = "singleValue"
        }
      },
      {
        height = 6,
        width  = 3,
        y      = 0,
        x      = 12,
        type   = "metric",
        properties = {
          metrics = [
            ["AWS/MWAA", "TaskInstancesSucceeded", "EnvironmentName", "builditall-prod-mwaa-environment"]
          ],
          period = 300,
          region = "eu-north-1",
          stat   = "Sum",
          title  = "Airflow Task Instances Succeeded",
          view   = "singleValue"
        }
      },
      {
        height = 6,
        width  = 3,
        y      = 0,
        x      = 15,
        type   = "metric",
        properties = {
          metrics = [
            ["AWS/MWAA", "TaskInstancesFailed", "EnvironmentName", "builditall-prod-mwaa-environment", { region = "eu-north-1" }]
          ],
          period = 300,
          region = "eu-north-1",
          stat   = "Sum",
          title  = "Airflow Task Instances Failed",
          view   = "singleValue"
        }
      },
      {
        height = 6,
        width  = 4,
        y      = 0,
        x      = 8,
        type   = "metric",
        properties = {
          metrics = [
            ["AWS/MWAA", "SchedulerLag", "EnvironmentName", "builditall-prod-mwaa-environment", { region = "eu-north-1" }]
          ],
          period = 300,
          region = "eu-north-1",
          stat   = "Average",
          title  = "Airflow Scheduler Lag",
          view   = "gauge",
          yAxis = {
            left = {
              min = 0,
              max = 1000
            }
          }
        }
      },
      {
        height = 6,
        width  = 3,
        y      = 0,
        x      = 18,
        type   = "metric",
        properties = {
          metrics = [
            ["AWS/MWAA", "SchedulerTasks", "EnvironmentName", "builditall-prod-mwaa-environment", { region = "eu-north-1" }]
          ],
          period = 300,
          region = "eu-north-1",
          stat   = "Sum",
          title  = "Airflow Scheduler Tasks",
          view   = "singleValue"
        }
      },
      {
        height = 6,
        width  = 8,
        y      = 6,
        x      = 16,
        type   = "metric",
        properties = {
          metrics = [
            ["AWS/MWAA", "WebServerLatency", "EnvironmentName", "builditall-prod-mwaa-environment", { region = "eu-north-1" }]
          ],
          period = 300,
          region = "eu-north-1",
          stat   = "Average",
          title  = "Airflow Web Server Latency",
          view   = "timeSeries"
        }
      }
    ]
  })
}
