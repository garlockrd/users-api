module global_settings { source = "./modules/global-variables" }

provider "aws" {
    region = module.global_settings.aws_region
    shared_credentials_files = [module.global_settings.aws_user_config]
}

resource "aws_api_gateway_rest_api" "users" {
    name = "users"
    tags = { terraform_created = "yes" }
}

resource "aws_api_gateway_request_validator" "require_all" {
  name                        = "Require_headers_and_parameters"
  rest_api_id                 = aws_api_gateway_rest_api.users.id
  validate_request_body       = true
  validate_request_parameters = true
}

module "create-user" {
    source = "../app/create-user"
    api_id = aws_api_gateway_rest_api.users.id
    api_root_resource_id = aws_api_gateway_rest_api.users.root_resource_id
    api_execution_arn = aws_api_gateway_rest_api.users.execution_arn
    validator_id = aws_api_gateway_request_validator.require_all.id
}

resource "aws_api_gateway_deployment" "test" {
  depends_on = [
    module.create-user
  ]

  rest_api_id = aws_api_gateway_rest_api.users.id
  stage_name  = "test"
}

