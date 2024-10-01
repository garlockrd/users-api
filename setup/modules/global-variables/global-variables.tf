output "aws_region" {
  value = "us-east-1"
}

output "aws_user_config" {
    value = "/Users/rgarlock/.aws/credentials"
}

output "aws_node_runtime" {
    value = "nodejs20.x"
}

output "layer_arns" {
    value = {
        user_layer = "arn:aws:lambda:us-east-1:435318396456:layer:user-layer:5",
        account_layer = "arn:aws:lambda:us-east-1:435318396456:layer:account-layer:5",
        email_layer = "arn:aws:lambda:us-east-1:435318396456:layer:email-layer:7"
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
        }
    }
}
