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

output "account_s3_bucket" {
    value = { 
        name = "accounts20240905145120463100000001"
        arn = "arn:aws:s3:::accounts20240905145120463100000001"
    }
}

output "log_arn" {
    value = "arn:aws:logs:us-east-1:435318396456:*"
}

output "common_code_layer_arn" {
    value = "arn:aws:lambda:us-east-1:435318396456:layer:common-code:240"
}

output "queues" {
    value = {
        send_email = {
            arn = "arn:aws:sqs:us-east-1:435318396456:send_email_queue",
            url = "https://sqs.us-east-1.amazonaws.com/435318396456/send_email_queue"
        } 
        user_history = {
            arn = "arn:aws:sqs:us-east-1:435318396456:user_history_queue",
            url = "https://sqs.us-east-1.amazonaws.com/435318396456/user_history_queue"
        }
        account_history = {
            arn = "arn:aws:sqs:us-east-1:435318396456:account_history_queue",
            url = "https://sqs.us-east-1.amazonaws.com/435318396456/account_history_queue"
        }
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
