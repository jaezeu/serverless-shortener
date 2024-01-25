resource "aws_dynamodb_table" "urlshortenertable" {
  name             = var.db_name
  hash_key         = var.partition_key
  billing_mode     = "PAY_PER_REQUEST"

  attribute {
    name = var.partition_key
    type = "S"
  }
}