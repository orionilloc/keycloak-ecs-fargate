#main.tf

terraform {
  backend "s3" {
    bucket       = "ansible-linux-sandbox-terraform-state"
    key          = "ansible-sandbox/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}
