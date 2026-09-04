# VPC Block Public Access exclusions - opt a specific VPC (or one of its
# subnets) out of the account/region-wide Block Public Access guardrail.
# Map keyed by caller-chosen name since a VPC can have more than one
# exclusion (e.g. one per subnet). Note: the account/region-wide guardrail
# itself (aws_vpc_block_public_access_options) is a singleton with no
# vpc_id - out of scope for this per-VPC module, see README.md "Scope".
resource "aws_vpc_block_public_access_exclusion" "this" {
  for_each = try(var.vpc.block_public_access_exclusions, {})

  internet_gateway_exclusion_mode = each.value.internet_gateway_exclusion_mode
  # Exclude a specific subnet when subnet_id is given; otherwise exclude
  # the whole VPC.
  vpc_id    = try(each.value.subnet_id, null) == null ? local.vpc_id : null
  subnet_id = try(each.value.subnet_id, null)

  tags = merge(var.tags, { Name = "${local.vpc-name}-${each.key}" }, try(each.value.tags, {}), local.module_tag)
}
