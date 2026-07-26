# variables.tf

variable "bucket_prefix" {
  description = "Prefix for the Terraform state bucket name for global uniqueness"
  type        = string
  default     = "keycloak-ecs-fargate-terraform-state"
}

variable "aws_region" {
  description = "The AWS region to deploy resources into."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name prefix for resources and tags."
  type        = string
  default     = "keycloak-ecs-fargate"
}
