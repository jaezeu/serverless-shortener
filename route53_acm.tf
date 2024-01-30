data "aws_acm_certificate" "issued" {
  domain   = var.domain_name
  statuses = ["ISSUED"]
}

resource "aws_api_gateway_domain_name" "shortener" {
  domain_name              = var.domain_name
  regional_certificate_arn = data.aws_acm_certificate.issued.arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "shortener" {
  api_id      = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_stage.stage.stage_name
  domain_name = aws_api_gateway_domain_name.shortener.domain_name
}

resource "aws_route53_record" "shortener" {
  name    = aws_api_gateway_domain_name.shortener.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.zone.zone_id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.shortener.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.shortener.regional_zone_id
  }
}