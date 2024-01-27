resource "aws_dynamodb_table" "urlshortenertable" {
  name             = var.db_name
  hash_key         = "short_id"
  billing_mode     = "PAY_PER_REQUEST"

  attribute {
    name = "short_id"
    type = "S"
  }
}