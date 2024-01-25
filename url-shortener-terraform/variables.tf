variable "aws_region" {
    default = "ap-southeast-1"
}

######### DYnamo DB variables#########
variable "db_name" {}
variable "partition_key" {}


#########IAM VARIABLES######
variable "iam_role_name" {}
variable "iam_policy_name" {}
variable "managed_policies" {
    description = "list of managed policies to attach"
    type = list(string)
}

########Lambda Variables ########
  
variable "action" {}
variable "principal" {}
variable "statement_id" {}
variable "create_url_lambda_name" {}
variable "retrieve_url_lambda_name" {}
variable "lambda_handler" {}
variable "lambda_runtime" {}
variable "environment_create" {
    default = ""
}
variable "environment_retrieve" {
    default = ""
}
variable url_create_source {}
variable url_create_output {}
variable url_retrieve_source {}
variable url_retrieve_output {}

###########API GATEWAY#########
variable "api_name" {}
variable "stage_name" {}


###########Domain##############
variable "domain_name" {}