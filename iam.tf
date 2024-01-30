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

  name        = "${local.resource_prefix}-lambda-policy"
  path        = "/"
  description = "IAM Policy to be attached to the lambda role"

  policy = data.aws_iam_policy_document.lambda_policy.json
}
