terraform {
  required_version = ">= 1.9"
}

variable "vpcs" {
  description = "VPC instances to deploy"
  type        = any
  default     = {}
}

module "vpc" {
  source   = "github.com/canada-ca-terraform-modules/terraform-aws-caf-vpc.git?ref=v1.0.0"
  for_each = var.vpcs

  userDefinedString = each.key
  env               = var.env
  vpc               = each.value
  tags              = var.tags
}
