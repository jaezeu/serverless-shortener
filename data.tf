data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "archive_file" "url_create" {
  type        = "zip"
  source_file = var.url_create_source
  output_path = var.url_create_output
}

data "archive_file" "url_retrieve" {
  type        = "zip"
  source_file = var.url_retrieve_source
  output_path = var.url_retrieve_output
}

data "aws_route53_zone" "zone" {
  name         = var.domain_name
}