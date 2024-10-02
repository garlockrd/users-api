module "global_settings" { source = "../../setup/modules/global-variables" }
locals {
    http_method = "POST"
    local_path = path.module
    lambda_name = "create-user"
    url = "create"
}

variable api_id { type = string }
variable api_root_resource_id { type = string }
variable api_execution_arn { type = string }

//Create the S3 bucket to update the zipped lambda file
module "s3_upload" {
  source = "../../setup/modules/s3-lambda-upload"
  lambda_name = local.lambda_name
  local_path = local.local_path
}

module role {
  source = "../../setup/modules/role"
  role_name = local.lambda_name
}

module role_policy {
  source = "../../setup/modules/role-policy"
  role_id =  module.role.id
  policy_name = "${local.lambda_name}-dynamodb-lambda-policy"
  statement = [
        {
           "Effect": "Allow"
           "Action" : ["dynamodb:Query"],
           "Resource" : [ module.global_settings.dynamo_table_info.user.arn, module.global_settings.dynamo_table_info.invited_user.arn ]
        }, 
        {
           "Effect": "Allow"
           "Action" : [ "dynamodb:DeleteItem" ],
           "Resource" : [ module.global_settings.dynamo_table_info.invited_user.arn ]
        }, 
        {
            "Effect": "Allow"
            "Action" : ["dynamodb:PutItem"],
            "Resource" : [ module.global_settings.dynamo_table_info.user.arn, module.global_settings.dynamo_table_info.account.arn, 
                           module.global_settings.dynamo_table_info.password_history.arn, module.global_settings.dynamo_table_info.invited_user.arn,
                           module.global_settings.dynamo_table_info.role.arn, module.global_settings.dynamo_table_info.permission.arn ]
        },
        {
           "Effect": "Allow"
           "Action" : ["sqs:SendMessage"],
           "Resource" : [ module.global_settings.queues.user_history, module.global_settings.queues.account_history, 
                          module.global_settings.queues.send_email ]
        }
      ]
}

module lambda {
  source = "../../setup/modules/lambda"
  lambda_name = local.lambda_name
  local_path = local.local_path
  s3_key = module.s3_upload.key
  source_code_hash =  module.s3_upload.archive_file_hash
  role_arn = module.role.arn
  role_id = module.role.id
  layer_arn_array = [ module.global_settings.layer_arns.http_layer ]
  environment_variables_object = {
    accountTableName = module.global_settings.dynamo_table_info.account_history.name,
    invited_user_dynamo_table = module.global_settings.dynamo_table_info.invited_user.name,
    permission_dynamo_name = module.global_settings.dynamo_table_info.permission.name,
    role_dynamo_name = module.global_settings.dynamo_table_info.role.name,
    user_dynamo_table = module.global_settings.dynamo_table_info.user.name,
    password_history_dynamo_table = module.global_settings.dynamo_table_info.password_history.name,
  }
}

resource "aws_lambda_permission" "default" {
    statement_id  = "AllowExecutionFromAPIGateway"
    action = "lambda:InvokeFunction"
    function_name = local.lambda_name
    principal = "apigateway.amazonaws.com"
    source_arn = "${var.api_execution_arn}/*/*"
}

# //Create the requst model
# module "api_request_model" {
#   source = "../../api-request"
#   api_id = var.generic_info.api_id
#   local_path = var.local_path
#   name = var.request_model_name
# }

# //Create the gateway for the endpoint
module "api_gateway" {
  source = "../../setup/modules/api-gateway"
  api_id = var.api_id
  parent_api_id = var.api_root_resource_id
  http_method = local.http_method
  lambda_invoke_arn = module.lambda.invoke_arn
  url_path = local.url
  #request_model_name = var.request_model_name
  #validator_id = var.generic_info.validator_id
}