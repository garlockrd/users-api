module global_settings { source = "../global-variables" }

variable lambda_name { type = string }
variable local_path { type = string }
variable layer_arn_array { type = any }
variable environment_variables_object { type = any }
variable role_arn { type = string }
variable role_id { type = string }
variable s3_key { type = string }
variable source_code_hash { type = string }
variable timeout { 
  type = string
  default = 3
}

resource "aws_lambda_function" "default" {
    function_name = var.lambda_name
    s3_bucket = module.global_settings.lambda_upload_s3_bucket
    s3_key = var.s3_key
    runtime = module.global_settings.aws_node_runtime
    handler = "function.handler"
    source_code_hash = var.source_code_hash
    role = var.role_arn
    timeout = var.timeout
    environment {
        variables = var.environment_variables_object
    }
    layers = var.layer_arn_array
    tags = {
      Terraform-Created = "yes"
    }
}

resource "aws_cloudwatch_log_group" "default" {
    name = "/aws/lambda/${var.lambda_name}"
    retention_in_days = 30
    tags = {
      Terraform-Created = "yes"
    }
}

module role_policy {
  source = "../role-policy"
  role_id =  var.role_id
  policy_name = "${var.lambda_name}-lambda-cloudwatch-policy"
  statement = [
    {
                Effect: "Allow",
                Action: [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents",
                    "logs:DescribeLogStreams",
                    "cloudwatch:PutMetricData",
                ],
                Resource: "*",
    }
  ]
}

output arn { value = aws_lambda_function.default.arn }
output invoke_arn { value = aws_lambda_function.default.invoke_arn }