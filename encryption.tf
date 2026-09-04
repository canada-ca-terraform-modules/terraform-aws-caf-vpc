# Manages VPC Encryption Control (Amazon VPC's "encrypt everywhere"
# guardrail) for this VPC - a single optional feature bound 1:1 to the VPC
# via vpc_id, so gated the same way as the other single-instance optional
# resources in this module (dhcp_options, etc.).
resource "aws_vpc_encryption_control" "this" {
  for_each = try(var.vpc.encryption_control, null) != null ? { enabled = true } : {}

  vpc_id                                 = local.vpc_id
  mode                                   = var.vpc.encryption_control.mode
  egress_only_internet_gateway_exclusion = try(var.vpc.encryption_control.egress_only_internet_gateway_exclusion, null)
  elastic_file_system_exclusion          = try(var.vpc.encryption_control.elastic_file_system_exclusion, null)
  internet_gateway_exclusion             = try(var.vpc.encryption_control.internet_gateway_exclusion, null)
  lambda_exclusion                       = try(var.vpc.encryption_control.lambda_exclusion, null)
  nat_gateway_exclusion                  = try(var.vpc.encryption_control.nat_gateway_exclusion, null)
  virtual_private_gateway_exclusion      = try(var.vpc.encryption_control.virtual_private_gateway_exclusion, null)

  tags = merge(var.tags, { Name = local.vpc-name }, try(var.vpc.encryption_control.tags, {}), local.module_tag)
}
