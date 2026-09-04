output "object" {
  # ponytail: hand-picked list of aws_vpc's non-deprecated attributes -
  # exposing the whole resource re-surfaces `[0]` indexing noise from the
  # count-based this/aws_default_vpc split and is unnecessary since callers
  # generally only need id/cidr_block/the default_*_id attributes below.
  description = "Returns the full VPC object (whichever of aws_vpc/aws_default_vpc was created)"
  value = {
    id                        = local.vpc_id
    arn                       = try(aws_vpc.this[0].arn, aws_default_vpc.this[0].arn)
    cidr_block                = try(aws_vpc.this[0].cidr_block, aws_default_vpc.this[0].cidr_block)
    ipv6_cidr_block           = try(aws_vpc.this[0].ipv6_cidr_block, aws_default_vpc.this[0].ipv6_cidr_block)
    default_network_acl_id    = try(aws_vpc.this[0].default_network_acl_id, aws_default_vpc.this[0].default_network_acl_id)
    default_route_table_id    = try(aws_vpc.this[0].default_route_table_id, aws_default_vpc.this[0].default_route_table_id)
    default_security_group_id = try(aws_vpc.this[0].default_security_group_id, aws_default_vpc.this[0].default_security_group_id)
    main_route_table_id       = try(aws_vpc.this[0].main_route_table_id, aws_default_vpc.this[0].main_route_table_id)
    dhcp_options_id           = try(aws_vpc.this[0].dhcp_options_id, aws_default_vpc.this[0].dhcp_options_id)
    owner_id                  = try(aws_vpc.this[0].owner_id, aws_default_vpc.this[0].owner_id)
    tags_all                  = try(aws_vpc.this[0].tags_all, aws_default_vpc.this[0].tags_all)
  }
  sensitive = true
}

output "id" {
  description = "Returns the ID of the VPC"
  value       = local.vpc_id
}

output "arn" {
  description = "Returns the ARN of the VPC"
  value       = try(aws_vpc.this[0].arn, aws_default_vpc.this[0].arn)
}

output "name" {
  description = "Returns the generated Name tag value of the VPC"
  value       = local.vpc-name
}

output "cidr_block" {
  description = "Returns the primary IPv4 CIDR block of the VPC"
  value       = try(aws_vpc.this[0].cidr_block, aws_default_vpc.this[0].cidr_block)
}

output "default_security_group_id" {
  description = "Returns the ID of the VPC's default security group"
  value       = try(aws_vpc.this[0].default_security_group_id, aws_default_vpc.this[0].default_security_group_id)
}

output "default_route_table_id" {
  description = "Returns the ID of the VPC's default route table"
  value       = try(aws_vpc.this[0].default_route_table_id, aws_default_vpc.this[0].default_route_table_id)
}

output "default_network_acl_id" {
  description = "Returns the ID of the VPC's default network ACL"
  value       = try(aws_vpc.this[0].default_network_acl_id, aws_default_vpc.this[0].default_network_acl_id)
}

output "dhcp_options_id" {
  description = "Returns the ID of the DHCP options set associated with the VPC"
  value       = try(aws_vpc.this[0].dhcp_options_id, aws_default_vpc.this[0].dhcp_options_id)
}

output "secondary_ipv4_cidr_block_associations" {
  description = "Returns the IDs of secondary IPv4 CIDR block associations, keyed by the caller's chosen name"
  value       = { for k, v in aws_vpc_ipv4_cidr_block_association.this : k => v.id }
}

output "secondary_ipv6_cidr_block_associations" {
  description = "Returns the IDs of secondary IPv6 CIDR block associations, keyed by the caller's chosen name"
  value       = { for k, v in aws_vpc_ipv6_cidr_block_association.this : k => v.id }
}

output "default_subnet_ids" {
  description = "Returns the IDs of managed default subnets, keyed by the caller's chosen name"
  value       = { for k, v in aws_default_subnet.this : k => v.id }
}

output "peering_connection_ids" {
  description = "Returns the IDs of VPC peering connections, keyed by the caller's chosen name"
  value       = { for k, v in aws_vpc_peering_connection.this : k => v.id }
}
