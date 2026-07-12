#variables.tf

variable "aws_region" {
  description = "The AWS region to deploy resources into."
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "The AWS profile to use for authentication."
  type        = string
  default     = ""
}

variable "project_name" {
  description = "Project name prefix for resources and tags."
  type        = string
  default     = "keycloak-ecs-fargate"
}

variable "domain_name" {
  description = "Root domain name for referencing"
  type        = string
}
