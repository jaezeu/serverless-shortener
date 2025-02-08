resource "aws_cloudwatch_log_group" "waf_logs" {
  name              = "aws-waf-logs-url-shortener"
  retention_in_days = 14
}

resource "aws_wafv2_ip_set" "allowed_ips" {
  name               = "url-shortener-allowed-ip-set"
  scope              = "REGIONAL"
  description        = "Allowed IP addresses"
  ip_address_version = "IPV4"

  addresses = [
    "155.69.193.63/32", #TODO
  ]
}

resource "aws_wafv2_web_acl" "api_gw_waf" {
  name  = "url-shortener-api-gateway-waf"
  scope = "REGIONAL"

  default_action {
    block {} # Block by default if no rules match
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "url-shortner-api-gateway-waf"
    sampled_requests_enabled   = true
  }

  rule {
    name     = "AllowOnlyInternalIPs"
    priority = 1

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.allowed_ips.arn
      }
    }

    action {
      allow {}
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AllowOnlyMyIPs"
      sampled_requests_enabled   = true
    }
  }
}

resource "aws_wafv2_web_acl_logging_configuration" "api_gw_waf_logging" {
  resource_arn = aws_wafv2_web_acl.api_gw_waf.arn
  log_destination_configs = [
    aws_cloudwatch_log_group.waf_logs.arn
  ]

  logging_filter {
    # Default behavior when no filters match
    default_behavior = "DROP" # means "do not log" if no filter matches

    filter {
      behavior    = "KEEP" # keep logs if the condition matches
      requirement = "MEETS_ANY"

      condition {
        action_condition {
          action = "BLOCK"
        }
      }
    }
  }
}

resource "aws_wafv2_web_acl_association" "example" {
  resource_arn = aws_api_gateway_stage.stage.arn
  web_acl_arn  = aws_wafv2_web_acl.api_gw_waf.arn
}
