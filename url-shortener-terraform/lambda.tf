provider "aws" {
  region = var.aws_region
}

provider "archive" {}

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

resource "aws_iam_role" "iam_role" {
  name = var.iam_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "iam_policy" {
  name                  = var.iam_policy_name
  policy                = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "dynamodb:PutItem",
                "dynamodb:DeleteItem",
                "dynamodb:GetItem",
                "dynamodb:Query",
                "dynamodb:UpdateItem"
            ],
            "Resource": "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${aws_dynamodb_table.urlshortenertable.name}"
        }
    ]
})
  
}

resource "aws_iam_role_policy_attachment" "iam_policy_attach" {
  role                  = aws_iam_role.iam_role.name
  policy_arn            = aws_iam_policy.iam_policy.arn
}

resource "aws_iam_role_policy_attachment" "managed-policy-attachment" {
  for_each   = toset(var.managed_policies)
  role       = aws_iam_role.iam_role.name
  policy_arn = each.value
}

resource "aws_lambda_function" "create_url_lambda" {
  
  filename              = "${data.archive_file.url_create.output_path}"
  source_code_hash      = "${data.archive_file.url_create.output_base64sha256}"
  function_name         = var.create_url_lambda_name
  role                  = aws_iam_role.iam_role.arn
  handler               = var.lambda_handler
  runtime               = var.lambda_runtime

  dynamic "environment" {
    for_each = length(var.environment_create) < 1 ? [] : [var.environment_create]
    content {
      variables = environment.value.variables
    }
  }
}

resource "aws_lambda_permission" "create_url_lambda_permission" {
  action                = var.action
  function_name         = aws_lambda_function.create_url_lambda.function_name
  principal             = var.principal
  statement_id          = var.statement_id
}

resource "aws_lambda_function" "retrieve_url_lambda" {
  filename              = "${data.archive_file.url_retrieve.output_path}"
  source_code_hash      = "${data.archive_file.url_retrieve.output_base64sha256}"
  function_name         = var.retrieve_url_lambda_name
  role                  = aws_iam_role.iam_role.arn
  handler               = var.lambda_handler
  runtime               = var.lambda_runtime
  
  dynamic "environment" {
    for_each = length(var.environment_retrieve) < 1 ? [] : [var.environment_retrieve]
    content {
      variables = environment.value.variables
    }
  }

}

resource "aws_lambda_permission" "retrieve_url_lambda_permission" {
  action                = var.action
  function_name         = aws_lambda_function.retrieve_url_lambda.function_name
  principal             = var.principal
  statement_id          = var.statement_id
}