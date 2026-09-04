# Core VPC + the resources that are directly, 1:1 scoped to a single VPC:
# secondary CIDR blocks, the VPC's DHCP options set/association, and the
# account's default DHCP options set. Optional add-on features that also
# bind to exactly one VPC (encryption control, block-public-access
# exclusions, peering) live in their own files: encryption.tf,
# block_public_access.tf, peering.tf. Resources for the *default* VPC's
# always-created components (default security group / route table /
# network ACL / subnets) live in default_resources.tf.
#
# See README.md "Scope" section for why aws_vpc_endpoint*, aws_vpc_ipam*,
# aws_vpc_route_server*, aws_vpc_security_group_* and aws_vpclattice_* are
# NOT part of this module despite sharing the aws_vpc_ text prefix.

resource "aws_vpc" "this" {
  count = try(var.vpc.use_default_vpc, false) ? 0 : 1

  cidr_block                           = try(var.vpc.cidr_block, null)
  instance_tenancy                     = try(var.vpc.instance_tenancy, "default")
  enable_dns_support                   = try(var.vpc.enable_dns_support, true)
  enable_dns_hostnames                 = try(var.vpc.enable_dns_hostnames, null)
  enable_network_address_usage_metrics = try(var.vpc.enable_network_address_usage_metrics, null)
  assign_generated_ipv6_cidr_block     = try(var.vpc.assign_generated_ipv6_cidr_block, null)
  ipv4_ipam_pool_id                    = try(var.vpc.ipv4_ipam_pool_id, null)
  ipv4_netmask_length                  = try(var.vpc.ipv4_netmask_length, null)
  ipv6_cidr_block                      = try(var.vpc.ipv6_cidr_block, null)
  ipv6_cidr_block_network_border_group = try(var.vpc.ipv6_cidr_block_network_border_group, null)
  ipv6_ipam_pool_id                    = try(var.vpc.ipv6_ipam_pool_id, null)
  ipv6_netmask_length                  = try(var.vpc.ipv6_netmask_length, null)

  # Tags - Merging tags provided by ESLZ with tags provided by the user
  tags = merge(var.tags, { Name = local.vpc-name }, try(var.vpc.tags, {}), local.module_tag)
}

# Manages the account's pre-existing default VPC in this region instead of
# creating a new one, when var.vpc.use_default_vpc = true. Mutually
# exclusive with aws_vpc.this above (every region has exactly one default
# VPC, so a module instance either creates a VPC or adopts the default one,
# never both).
resource "aws_default_vpc" "this" {
  count = try(var.vpc.use_default_vpc, false) ? 1 : 0

  force_destroy = try(var.vpc.default_vpc.force_destroy, null)

  tags = merge(var.tags, { Name = local.vpc-name }, try(var.vpc.default_vpc.tags, {}), local.module_tag)
}

locals {
  # The ID of whichever of the two VPC resources above was created, so
  # every other file in this module can reference "the VPC" uniformly.
  vpc_id = try(aws_vpc.this[0].id, aws_default_vpc.this[0].id)
}

# Additional IPv4 CIDR blocks beyond the VPC's primary one - keyed by
# caller-chosen name so multiple secondary blocks can be added/removed
# independently.
resource "aws_vpc_ipv4_cidr_block_association" "this" {
  for_each = try(var.vpc.secondary_ipv4_cidr_blocks, {})

  vpc_id              = local.vpc_id
  cidr_block          = try(each.value.cidr_block, null)
  ipv4_ipam_pool_id   = try(each.value.ipv4_ipam_pool_id, null)
  ipv4_netmask_length = try(each.value.ipv4_netmask_length, null)
}

# Additional IPv6 CIDR blocks beyond the VPC's primary one.
resource "aws_vpc_ipv6_cidr_block_association" "this" {
  for_each = try(var.vpc.secondary_ipv6_cidr_blocks, {})

  vpc_id                           = local.vpc_id
  assign_generated_ipv6_cidr_block = try(each.value.assign_generated_ipv6_cidr_block, null)
  ipv6_cidr_block                  = try(each.value.ipv6_cidr_block, null)
  ipv6_ipam_pool_id                = try(each.value.ipv6_ipam_pool_id, null)
  ipv6_netmask_length              = try(each.value.ipv6_netmask_length, null)
  ipv6_pool                        = try(each.value.ipv6_pool, null)
}

# Custom DHCP options set for this VPC + its association. Single-instance
# optional feature: creating both only when var.vpc.dhcp_options is set.
resource "aws_vpc_dhcp_options" "this" {
  for_each = try(var.vpc.dhcp_options, null) != null ? { enabled = true } : {}

  domain_name                       = try(var.vpc.dhcp_options.domain_name, null)
  domain_name_servers               = try(var.vpc.dhcp_options.domain_name_servers, null)
  ntp_servers                       = try(var.vpc.dhcp_options.ntp_servers, null)
  netbios_name_servers              = try(var.vpc.dhcp_options.netbios_name_servers, null)
  netbios_node_type                 = try(var.vpc.dhcp_options.netbios_node_type, null)
  ipv6_address_preferred_lease_time = try(var.vpc.dhcp_options.ipv6_address_preferred_lease_time, null)

  tags = merge(var.tags, { Name = local.vpc-name }, try(var.vpc.dhcp_options.tags, {}), local.module_tag)
}

resource "aws_vpc_dhcp_options_association" "this" {
  for_each = aws_vpc_dhcp_options.this

  vpc_id          = local.vpc_id
  dhcp_options_id = each.value.id
}

# Manages the account's default DHCP options set in this region (an
# account-wide singleton, independent of which VPC uses it - not the same
# as the per-VPC custom set above).
resource "aws_default_vpc_dhcp_options" "this" {
  for_each = try(var.vpc.default_vpc_dhcp_options, null) != null ? { enabled = true } : {}

  tags = merge(var.tags, try(var.vpc.default_vpc_dhcp_options.tags, {}), local.module_tag)
}
