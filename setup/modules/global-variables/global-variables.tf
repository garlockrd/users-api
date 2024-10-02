output "aws_region" {
  value = "us-east-1"
}

output "aws_user_config" {
    value = "/Users/rgarlock/.aws/credentials"
}

output "aws_node_runtime" {
    value = "nodejs20.x"
}

output "lambda_upload_s3_bucket" {
    value = "lambda-uploads20240905145120463100000002"
}

output "log_arn" {
    value = "arn:aws:logs:us-east-1:435318396456:*"
}

output "layer_arns" {
    value = {
        user_layer = "arn:aws:lambda:us-east-1:435318396456:layer:user-layer:6",
        account_layer = "arn:aws:lambda:us-east-1:435318396456:layer:account-layer:6",
        email_layer = "arn:aws:lambda:us-east-1:435318396456:layer:email-layer:8",
        http_layer = "arn:aws:lambda:us-east-1:435318396456:layer:http-layer:1"
    }
}

output "queues" {
    value = {
        send_email = "arn:aws:sqs:us-east-1:435318396456:send_email_queue",
        user_history = "arn:aws:sqs:us-east-1:435318396456:user_history_queue",
        account_history = "arn:aws:sqs:us-east-1:435318396456:account_history_queue"
    }
}

output "dynamo_table_info" {
    value = {
        user_history = {
            name = "user-history"
            arn = "arn:aws:dynamodb:us-east-1:435318396456:table/user-history"
        },
        account_history = {
            name = "account-history"
            arn = "arn:aws:dynamodb:us-east-1:435318396456:table/account-history"
        },
        account = {
            name = "account"
            arn = "arn:aws:dynamodb:us-east-1:435318396456:table/account"
        },
        user = {
            name = "user"
            arn = "arn:aws:dynamodb:us-east-1:435318396456:table/user"
        },
        invited_user = {
            name = "invited-user"
            arn = "arn:aws:dynamodb:us-east-1:435318396456:table/invited-user"
        },
        password_history = {
            name = "password-history"
            arn = "arn:aws:dynamodb:us-east-1:435318396456:table/password-history"
        },
        permission = {
            name = "permission"
            arn = "arn:aws:dynamodb:us-east-1:435318396456:table/permission"
        },
        role = {
            name = "role"
            arn = "arn:aws:dynamodb:us-east-1:435318396456:table/role"
        }
    }
}
