# The four resource types that manage components AWS automatically creates
# alongside every VPC (default or custom): the default security group,
# default route table, default network ACL, and default subnets. All are
# optional here since adopting them into Terraform state is a deliberate
# choice (they exist whether or not you manage them), gated on their own
# object/map keys under var.vpc.

locals {
  # aws_default_security_group's ingress/egress are typed as
  # set(object({...})) with no optional() modifier in the provider's SDKv2
  # schema, so every attribute of the object must be present (as null when
  # unset) or Terraform rejects the value outright - callers only supply
  # the keys they care about, so fill in the rest here.
  default_security_group_rule_defaults = {
    cidr_blocks      = null
    description      = null
    ipv6_cidr_blocks = null
    prefix_list_ids  = null
    security_groups  = null
    self             = null
  }
}

resource "aws_default_security_group" "this" {
  for_each = try(var.vpc.default_security_group, null) != null ? { enabled = true } : {}

  vpc_id = local.vpc_id
  ingress = try(var.vpc.default_security_group.ingress, null) == null ? null : [
    for rule in var.vpc.default_security_group.ingress :
    merge(local.default_security_group_rule_defaults, rule)
  ]
  egress = try(var.vpc.default_security_group.egress, null) == null ? null : [
    for rule in var.vpc.default_security_group.egress :
    merge(local.default_security_group_rule_defaults, rule)
  ]
  revoke_rules_on_delete = try(var.vpc.default_security_group.revoke_rules_on_delete, null)

  tags = merge(var.tags, { Name = local.vpc-name }, try(var.vpc.default_security_group.tags, {}), local.module_tag)
}

resource "aws_default_route_table" "this" {
  for_each = try(var.vpc.default_route_table, null) != null ? { enabled = true } : {}

  default_route_table_id = try(aws_vpc.this[0].default_route_table_id, aws_default_vpc.this[0].default_route_table_id)
  route                  = try(var.vpc.default_route_table.route, null)
  propagating_vgws       = try(var.vpc.default_route_table.propagating_vgws, null)

  tags = merge(var.tags, { Name = local.vpc-name }, try(var.vpc.default_route_table.tags, {}), local.module_tag)
}

resource "aws_default_network_acl" "this" {
  for_each = try(var.vpc.default_network_acl, null) != null ? { enabled = true } : {}

  default_network_acl_id = try(aws_vpc.this[0].default_network_acl_id, aws_default_vpc.this[0].default_network_acl_id)
  subnet_ids             = try(var.vpc.default_network_acl.subnet_ids, null)

  dynamic "ingress" {
    for_each = try(var.vpc.default_network_acl.ingress, [])
    content {
      rule_no         = ingress.value.rule_no
      action          = ingress.value.action
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      cidr_block      = try(ingress.value.cidr_block, null)
      ipv6_cidr_block = try(ingress.value.ipv6_cidr_block, null)
      icmp_type       = try(ingress.value.icmp_type, null)
      icmp_code       = try(ingress.value.icmp_code, null)
    }
  }

  dynamic "egress" {
    for_each = try(var.vpc.default_network_acl.egress, [])
    content {
      rule_no         = egress.value.rule_no
      action          = egress.value.action
      from_port       = egress.value.from_port
      to_port         = egress.value.to_port
      protocol        = egress.value.protocol
      cidr_block      = try(egress.value.cidr_block, null)
      ipv6_cidr_block = try(egress.value.ipv6_cidr_block, null)
      icmp_type       = try(egress.value.icmp_type, null)
      icmp_code       = try(egress.value.icmp_code, null)
    }
  }

  tags = merge(var.tags, { Name = local.vpc-name }, try(var.vpc.default_network_acl.tags, {}), local.module_tag)
}

# Default subnets are per-Availability-Zone, so this is a map keyed by the
# caller's chosen name (typically the AZ) rather than a single object.
resource "aws_default_subnet" "this" {
  for_each = try(var.vpc.default_subnets, {})

  availability_zone                              = try(each.value.availability_zone, null)
  ipv6_cidr_block                                = try(each.value.ipv6_cidr_block, null)
  ipv6_native                                    = try(each.value.ipv6_native, null)
  assign_ipv6_address_on_creation                = try(each.value.assign_ipv6_address_on_creation, null)
  enable_dns64                                   = try(each.value.enable_dns64, null)
  enable_resource_name_dns_a_record_on_launch    = try(each.value.enable_resource_name_dns_a_record_on_launch, null)
  enable_resource_name_dns_aaaa_record_on_launch = try(each.value.enable_resource_name_dns_aaaa_record_on_launch, null)
  map_public_ip_on_launch                        = try(each.value.map_public_ip_on_launch, null)
  private_dns_hostname_type_on_launch            = try(each.value.private_dns_hostname_type_on_launch, null)
  # customer_owned_ipv4_pool/map_customer_owned_ip_on_launch/outpost_arn
  # (AWS Outposts-only, all three or none) intentionally omitted - a niche
  # combination validated together by the provider; add if an Outposts use
  # case is needed.
  force_destroy = try(each.value.force_destroy, null)

  tags = merge(var.tags, { Name = "${local.vpc-name}-${each.key}" }, try(each.value.tags, {}), local.module_tag)
}
