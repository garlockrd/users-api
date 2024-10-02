variable api_id { type = string }
variable name { type = string }
variable local_path { type = string }

variable file_name {
    type = string
    default = "request-schema.json"
}

resource "aws_api_gateway_model" "default" {
    rest_api_id  = var.api_id
    name         = var.name
    description  = "A JSON schema"
    content_type = "application/json"
    schema       = file("${var.local_path}/${var.file_name}")
}