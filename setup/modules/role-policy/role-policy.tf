variable policy_name { type = string }
variable role_id { type = string }
variable statement { type = any }

resource "aws_iam_role_policy" "default" {
   name = "${var.policy_name}"
   role = var.role_id
   policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : var.statement
   })
}