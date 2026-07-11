#main.tf

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

terraform {
  backend "s3" {
    bucket       = ""${var.bucket_prefix}-${data.aws_caller_identity.current.account_id}"
    key          = "keycloak-ecs-fargate/terraform.tfstate"
    region       = var.aws_region
    use_lockfile = true
    encrypt      = true
  }
}
