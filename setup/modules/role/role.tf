variable role_name { type = string }

resource "aws_iam_role" "default" {
    name = var.role_name
    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
        Action =  "sts:AssumeRole",
        Effect = "Allow"
        Sid    = ""
        Principal = {
            Service = ["lambda.amazonaws.com"]
        }
        }
    ]
    })
    tags = {
        Terraform-Created = "yes"
    }
}

output arn { value = aws_iam_role.default.arn }
output id { value = aws_iam_role.default.id }