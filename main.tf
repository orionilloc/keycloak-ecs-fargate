#main.tf

terraform {
  backend "s3" {
    bucket       = "keycloak-ecs-fargate-terraform-state-e40506ca"
    key          = "keycloak-ecs-fargate/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}
