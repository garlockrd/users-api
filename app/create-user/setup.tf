module "global_settings" { source = "../../setup/modules/global-variables" }
locals {
    http_method = "POST"
    local_path = path.module
    lambda_name = "create-user"
    url = "create"
    request_model_name = "CreateUserRequestModel"
}

variable api_id { type = string }
variable api_root_resource_id { type = string }
variable api_execution_arn { type = string }
variable validator_id { type = string }

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
           "Resource" : [ module.global_settings.queues.user_history.arn, module.global_settings.queues.account_history.arn, 
                          module.global_settings.queues.send_email.arn ]
        },
        {
           "Effect": "Allow"
           "Action" : ["s3:PutObject"],
           "Resource" : [ module.global_settings.account_s3_bucket.arn, "${module.global_settings.account_s3_bucket.arn}/*"  ]
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
  timeout = 10
  layer_arn_array = [ module.global_settings.common_code_layer_arn ]
  environment_variables_object = {
    account_dynamo_name = module.global_settings.dynamo_table_info.account.name,
    invited_user_dynamo_name = module.global_settings.dynamo_table_info.invited_user.name,
    permission_dynamo_name = module.global_settings.dynamo_table_info.permission.name,
    role_dynamo_name = module.global_settings.dynamo_table_info.role.name,
    user_dynamo_name = module.global_settings.dynamo_table_info.user.name,
    password_history_dynamo_name = module.global_settings.dynamo_table_info.password_history.name,
    email_queue_url = module.global_settings.queues.send_email.url,
    account_history_queue_url = module.global_settings.queues.account_history.url,
    user_history_queue_url = module.global_settings.queues.user_history.url
    accounts_s3_name = module.global_settings.account_s3_bucket.name
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
module "api_request_model" {
  source = "../../setup/modules/api-request-model"
  api_id = var.api_id
  local_path = local.local_path
  name = local.request_model_name
}

module "api_gateway" {
  source = "../../setup/modules/api-gateway"
  api_id = var.api_id
  parent_api_id = var.api_root_resource_id
  http_method = local.http_method
  lambda_invoke_arn = module.lambda.invoke_arn
  url_path = local.url
  request_model_name = local.request_model_name

  validator_id = var.validator_id
}


## TO DO
# 4. Start to work through function steps
# 5. API Testing (How to get that in a repo?)