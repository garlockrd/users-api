variable api_id { type = string }
variable url_path { type = string }
variable http_method { type = string }
variable lambda_invoke_arn { type = string }
variable parent_api_id { type = string }
variable authorization { 
    type = string
    default = "NONE"
}
variable "authorizer_id" { 
    type = string 
    default = null
}
variable validator_id { 
    type = string
    default = null 
}
variable request_model_name {
    type = string
    default = null
}

resource "aws_api_gateway_resource" "default" {
    rest_api_id = var.api_id
    parent_id   = var.parent_api_id
    path_part   = var.url_path
}

resource "aws_api_gateway_method" "default" {
    rest_api_id = var.api_id
    resource_id = aws_api_gateway_resource.default.id
    http_method   = var.http_method
    authorization = var.authorization
    authorizer_id = var.authorizer_id
    request_validator_id = var.validator_id
    request_models = {
      "application/json" = var.request_model_name
    }
}

resource "aws_api_gateway_integration" "default" {
    rest_api_id = var.api_id
    resource_id = aws_api_gateway_resource.default.id
    http_method = var.http_method
    integration_http_method = "POST"
    type                    = "AWS_PROXY"
    uri                     = var.lambda_invoke_arn

}