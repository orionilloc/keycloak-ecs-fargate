# variables.tf

variable "bucket_prefix" {
  description = "Prefix for the Terraform state bucket name; account ID appended for global uniqueness and reusability"
  type        = string
  default     = "keycloak-ecs-fargate-terraform-state"
}
