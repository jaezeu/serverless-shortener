module "create_url_lambda" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "${local.resource_prefix}-url-create"
  description   = "Lambda function to create URL"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
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
    APP_URL    = "https://${local.resource_prefix}.${local.zone_name}/"
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
  runtime       = "python3.12"
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

module "lambda_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5.30.0"

  trusted_role_services = [
    "lambda.amazonaws.com"
  ]

  create_role       = true
  role_name         = "${local.resource_prefix}-lambda-role"
  role_requires_mfa = false
  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    module.lambda_policy.arn,
  ]
}

module "lambda_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.30.0"

  name = "${local.resource_prefix}-lambda-policy"

  policy = data.aws_iam_policy_document.lambda_policy.json
}
