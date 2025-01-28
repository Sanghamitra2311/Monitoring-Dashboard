resource "google_monitoring_alert_policy" "example" {
  display_name = "High CPU Usage Alert"
  combiner     = "OR"
 
  conditions {
    display_name = "CPU Usage Condition"
    condition_threshold {
      filter          = "metric.type=\"compute.googleapis.com/instance/cpu/usage_time\" AND resource.type=\"gce_instance\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0.8
      duration        = "60s"
 
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }
 
  notification_channels = [google_monitoring_notification_channel.example.id]
}
 
resource "google_monitoring_dashboard" "example" {
  dashboard_json = jsonencode({
    displayName = "Custom Dashboard"
    gridLayout = {
      widgets = [
        {
          title = "High CPU Usage Alert"
          text = {
            content = "This dashboard includes an alert policy for CPU usage that triggers if usage exceeds 80% for 60 seconds."
            format  = "MARKDOWN"
          }
        },
        {
          title = "CPU Usage Alert Policy Visualization"
          scorecard = {
            timeSeriesQuery = {
              timeSeriesFilter = {
                filter = "metric.type=\"compute.googleapis.com/instance/cpu/usage_time\" AND resource.type=\"gce_instance\""
                aggregation = {
                  alignmentPeriod   = "60s"
                  perSeriesAligner  = "ALIGN_RATE"
                }
              }
            }
            thresholds = [
              {
                label       = "Critical"
                value       = 0.8
                color       = "RED"
                direction   = "ABOVE"
                targetAxis  = "Y1"
              }
            ]
          }
        }
      ]
    }
  })
}
 
resource "google_monitoring_notification_channel" "example" {
  display_name = "Email Notification"
  type         = "email"
  labels = {
    email_address = "nipunkr2003@gmail.com"
  }
}