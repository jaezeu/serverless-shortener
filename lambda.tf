module "create_url_lambda" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "${local.resource_prefix}-url-create"
  description   = "Lambda function to create URL"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.7"
  publish       = true
  lambda_role   = module.lambda_role.iam_role_arn

  create_package = true
  source_path    = "./url-create-lambda/"

  allowed_triggers = {
    AllowExecutionFromAPIGateway = {
      service = "apigateway"
    }
  }

  environment_variables = {
    APP_URL    = "https://jaezeu.com/"
    MAX_CHAR   = "16"
    MIN_CHAR   = "12"
    REGION_AWS = "${data.aws_region.current.name}"
    DB_NAME    = "${aws_dynamodb_table.shortener_table.name}"
  }
}

module "retrieve_url_lambda" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "${local.resource_prefix}-url-retrieve"
  description   = "Lambda function to retrieve URL"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.7"
  publish       = true
  lambda_role   = module.lambda_role.iam_role_arn

  create_package = true
  source_path    = "./url-retrieve-lambda/"

  allowed_triggers = {
    AllowExecutionFromAPIGateway = {
      service = "apigateway"
    }
  }

  environment_variables = {
    REGION_AWS = "${data.aws_region.current.name}"
    DB_NAME    = "${aws_dynamodb_table.shortener_table.name}"
  }
}