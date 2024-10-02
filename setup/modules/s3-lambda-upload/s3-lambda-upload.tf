module global_settings { source = "../global-variables" }

variable local_path { type = string }
variable lambda_name { type = string }

locals {
    archive_file_name = "archive.zip"
    key = "${var.lambda_name}/${local.archive_file_name}"
}

data "archive_file" "default" {
    type = "zip"
    source_dir  = var.local_path
    output_path = "${var.local_path}/${local.archive_file_name}"
    excludes    = [ "*.tf", "*.zip", "*.json" ]
}

resource "aws_s3_object" "default" {
    bucket = module.global_settings.lambda_upload_s3_bucket
    key = local.key
    source = "${var.local_path}/${local.archive_file_name}"
    etag = filemd5("${var.local_path}/${local.archive_file_name}")    
}

output "key" { value = local.key }
output "archive_file_hash" { value = data.archive_file.default.output_base64sha256 }