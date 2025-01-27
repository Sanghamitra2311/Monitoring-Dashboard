# resource "google_monitoring_dashboard" "dashboard" {
#     dashboard_json = <<EOF
# {
#     "displayName": "Storage dashboard",
#     "gridLayout": {
#         "columns": 2,
#         "widgets": [
#             {
#                 "title": "Bucket Size Alert",
#                 "xyChart": {
#                     "dataSets": [{
#                         "timeSeriesQuery": {
#                             "timeSeriesFilter": {
#                                 "filter": "metric.type=\"storage.googleapis.com/storage/total_bytes\"",
#                                 "aggregation": {
#                                     "perSeriesAligner": "ALIGN_RATE"
#                                 }
#                             },
#                             "unitOverride": "1"
#                         },
#                         "plotType": "LINE"
#                     }],
#                     "timeshiftDuration": "0s",
#                     "yAxis": {
#                         "label": "y1Axis",
#                         "scale": "LINEAR"
#                     }
#                 }
#             },
#             {
#                 "title": "Object deletion alert",
#                 "xyChart": {
#                     "dataSets": [{
#                         "timeSeriesQuery": {
#                             "timeSeriesFilter": {
#                                 "filter": "metric.type=\"storage.googleapis.com/storage/v2/deleted_bytes\"",
#                                 "aggregation": {
#                                     "perSeriesAligner": "ALIGN_RATE"
#                                 }
#                             },
#                             "unitOverride": "1"
#                         },
#                         "plotType": "STACKED_BAR"
#                     }],
#                     "timeshiftDuration": "0s",
#                     "yAxis": {
#                         "label": "y1Axis",
#                         "scale": "LINEAR"
#                     }
#                 }
#             }
#         ]
#     }
# }
# EOF
# }
# resource "google_monitoring_alert_policy" "object_deletion_alert" {
#     display_name = "Object Deletion Alert"

#   conditions {
#     display_name = "Object Deletion Alert"

#     condition_threshold {
#       filter          = "metric.type=\"storage.googleapis.com/storage/v2/deleted_bytes\" AND resource.type=\"gcs_bucket\""
#       comparison      = "COMPARISON_GT"
#       threshold_value = 1000000000 
#       duration        = "60s"

#       aggregations {
#         alignment_period     = "60s"
#         per_series_aligner   = "ALIGN_SUM"
#         cross_series_reducer = "REDUCE_SUM"
#       }
#     }
#   }

#   combiner = "AND"

#   notification_channels =  [
#         "projects/my-project-a1-31774/notificationChannels/7042861184236912339"
#     ]
#     severity = "WARNING"
# }

# Define the variable for email address
variable "email_address" {
  description = "The email address for the notification channel."
  type        = string
  default     = "nipunkr2003@gmail.com"  # Your email address
}

# Create a custom notification channel (email)
resource "google_monitoring_notification_channel" "custom_email_channel" {
  display_name = "Custom Email Notifications"
  type         = "email"

  labels = {
    email_address = var.email_address  # Use the provided email address
  }
}

# Define the storage dashboard
resource "google_monitoring_dashboard" "dashboard" {
  dashboard_json = <<EOF
{
    "displayName": "Storage dashboard",
    "gridLayout": {
        "columns": 2,
        "widgets": [
            {
                "title": "Bucket Size Alert",
                "xyChart": {
                    "dataSets": [
                        {
                            "timeSeriesQuery": {
                                "timeSeriesFilter": {
                                    "filter": "metric.type=\"storage.googleapis.com/storage/total_bytes\"",
                                    "aggregation": {
                                        "perSeriesAligner": "ALIGN_MAX"
                                    }
                                },
                                "unitOverride": "1"
                            },
                            "plotType": "LINE"
                        }
                    ],
                    "timeshiftDuration": "0s",
                    "yAxis": {
                        "label": "y1Axis",
                        "scale": "LINEAR"
                    }
                }
            },
            {
                "title": "Object deletion alert",
                "xyChart": {
                    "dataSets": [
                        {
                            "timeSeriesQuery": {
                                "timeSeriesFilter": {
                                    "filter": "metric.type=\"storage.googleapis.com/storage/v2/deleted_bytes\"",
                                    "aggregation": {
                                        "perSeriesAligner": "ALIGN_RATE"
                                    }
                                },
                                "unitOverride": "1"
                            },
                            "plotType": "STACKED_BAR"
                        }
                    ],
                    "timeshiftDuration": "0s",
                    "yAxis": {
                        "label": "y1Axis",
                        "scale": "LINEAR"
                    }
                }
            }
        ]
    }
}
EOF
}

# Alert policy for bucket size
resource "google_monitoring_alert_policy" "bucket_size_alert" {
  display_name = "Bucket Size Alert"

  conditions {
    display_name = "Bucket Size Exceeded"
    condition_threshold {
      filter          = "metric.type=\"storage.googleapis.com/storage/total_bytes\" AND resource.type=\"gcs_bucket\""
      comparison      = "COMPARISON_GT"
      threshold_value = 10000000  # Set the threshold in bytes
      duration        = "60s"

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MAX"
      }
    }
  }

  combiner              = "AND"
  notification_channels = [google_monitoring_notification_channel.custom_email_channel.id]

  alert_strategy {
    auto_close = "3600s"  # Automatically close the alert after 1 hour
  }
}


