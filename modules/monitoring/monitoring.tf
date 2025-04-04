resource "google_monitoring_dashboard" "cert_manager_dashboard" {
  dashboard_json = <<EOF
{
  "displayName": "Cert Manager Dashboard",
  "dashboardFilters": [],
  "labels": {},
  "mosaicLayout": {
    "columns": 48,
    "tiles": [
      {
        "height": 11,
        "width": 20,
        "widget": {
          "title": "days before expiration",
          "id": "",
          "scorecard": {
            "breakdowns": [],
            "dimensions": [],
            "measures": [],
            "sparkChartView": {
              "sparkChartType": "SPARK_LINE"
            },
            "thresholds": [],
            "timeSeriesQuery": {
              "outputFullDuration": false,
              "prometheusQuery": "(certmanager_certificate_expiration_timestamp_seconds - time()) / 86400",
              "unitOverride": ""
            }
          }
        }
      },
      {
        "xPos": 20,
        "height": 11,
        "width": 28,
        "widget": {
          "title": "Certificates (Ready = True)",
          "id": "",
          "scorecard": {
            "breakdowns": [],
            "dimensions": [],
            "gaugeView": {
              "lowerBound": 0,
              "upperBound": 1
            },
            "measures": [],
            "thresholds": [],
            "timeSeriesQuery": {
              "outputFullDuration": false,
              "prometheusQuery": "certmanager_certificate_ready_status{condition=\"True\"}",
              "unitOverride": ""
            }
          }
        }
      },
      {
        "yPos": 11,
        "height": 19,
        "width": 24,
        "widget": {
          "title": "Controller Sync Call Count",
          "id": "",
          "xyChart": {
            "chartOptions": {
              "displayHorizontal": false,
              "mode": "COLOR",
              "showLegend": false
            },
            "dataSets": [
              {
                "breakdowns": [],
                "dimensions": [],
                "legendTemplate": "",
                "measures": [],
                "plotType": "LINE",
                "targetAxis": "Y1",
                "timeSeriesQuery": {
                  "outputFullDuration": false,
                  "prometheusQuery": "certmanager_controller_sync_call_count",
                  "unitOverride": ""
                }
              }
            ],
            "thresholds": [],
            "yAxis": {
              "label": "number of sync calls",
              "scale": "LINEAR"
            }
          }
        }
      },
      {
        "yPos": 11,
        "xPos": 24,
        "height": 19,
        "width": 24,
        "widget": {
          "title": "ACME Client Request Count",
          "id": "",
          "xyChart": {
            "chartOptions": {
              "displayHorizontal": false,
              "mode": "COLOR",
              "showLegend": false
            },
            "dataSets": [
              {
                "breakdowns": [],
                "dimensions": [],
                "legendTemplate": "",
                "measures": [],
                "plotType": "LINE",
                "targetAxis": "Y1",
                "timeSeriesQuery": {
                  "outputFullDuration": false,
                  "prometheusQuery": "certmanager_http_acme_client_request_count",
                  "unitOverride": ""
                }
              }
            ],
            "thresholds": [],
            "yAxis": {
              "label": "Number of requests",
              "scale": "LINEAR"
            }
          }
        }
      },
      {
        "yPos": 30,
        "height": 16,
        "width": 24,
        "widget": {
          "title": "Overall requests per 10m",
          "id": "",
          "xyChart": {
            "chartOptions": {
              "displayHorizontal": false,
              "mode": "COLOR",
              "showLegend": false
            },
            "dataSets": [
              {
                "breakdowns": [],
                "dimensions": [],
                "legendTemplate": "",
                "measures": [],
                "plotType": "LINE",
                "targetAxis": "Y1",
                "timeSeriesQuery": {
                  "outputFullDuration": false,
                  "prometheusQuery": "sum(rate(certmanager_http_acme_client_request_count[10m])) BY (status)",
                  "unitOverride": ""
                }
              }
            ],
            "thresholds": [],
            "yAxis": {
              "label": "",
              "scale": "LINEAR"
            }
          }
        }
      }
    ]
  }
}
EOF
}

