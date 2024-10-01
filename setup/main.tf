module global_settings { source = "./modules/global-variables" }

provider "aws" {
    region = module.global_settings.aws_region
    shared_credentials_files = [module.global_settings.aws_user_config]
}