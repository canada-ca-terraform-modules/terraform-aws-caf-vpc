# VPC Peering - the requester side (aws_vpc_peering_connection, created
# from this VPC), with two optional companions per connection: the
# accepter side (when the peer VPC is in an account/region this same
# provider can manage) and standalone peering options (for the common case
# where accepter/requester DNS-resolution options are set on the accepter
# side outside of this module/account). Map keyed by caller-chosen name so
# a VPC can peer with more than one other VPC.

resource "aws_vpc_peering_connection" "this" {
  for_each = try(var.vpc.peering_connections, {})

  vpc_id        = local.vpc_id
  peer_vpc_id   = each.value.peer_vpc_id
  peer_owner_id = try(each.value.peer_owner_id, null)
  peer_region   = try(each.value.peer_region, null)
  auto_accept   = try(each.value.auto_accept, null)

  dynamic "accepter" {
    for_each = try(each.value.accepter_options, null) != null ? [each.value.accepter_options] : []
    content {
      allow_remote_vpc_dns_resolution = try(accepter.value.allow_remote_vpc_dns_resolution, null)
    }
  }

  dynamic "requester" {
    for_each = try(each.value.requester_options, null) != null ? [each.value.requester_options] : []
    content {
      allow_remote_vpc_dns_resolution = try(requester.value.allow_remote_vpc_dns_resolution, null)
    }
  }

  tags = merge(var.tags, { Name = "${local.vpc-name}-${each.key}" }, try(each.value.tags, {}), local.module_tag)
}

# Accepter-side management of a cross-account/cross-region peering
# connection that was automatically created in the peer account when the
# requester above set peer_owner_id/peer_region to a different
# account/region. Only created when the caller opts in via
# each.value.accept = true (accepting from *this* module invocation, i.e.
# this module is managing the peer/accepter account).
resource "aws_vpc_peering_connection_accepter" "this" {
  for_each = {
    for name, connection in try(var.vpc.peering_connections, {}) :
    name => connection if try(connection.accept, false)
  }

  vpc_peering_connection_id = aws_vpc_peering_connection.this[each.key].id
  auto_accept               = true

  tags = merge(var.tags, { Name = "${local.vpc-name}-${each.key}" }, try(each.value.tags, {}), local.module_tag)
}

# Standalone peering connection options, for setting the accepter's
# DNS-resolution options from the requester's account/module invocation
# when the accepter side isn't managed by aws_vpc_peering_connection_accepter
# above (e.g. the peer VPC belongs to a different, unmanaged account).
resource "aws_vpc_peering_connection_options" "this" {
  for_each = {
    for name, connection in try(var.vpc.peering_connections, {}) :
    name => connection if try(connection.manage_options_standalone, false)
  }

  vpc_peering_connection_id = aws_vpc_peering_connection.this[each.key].id

  dynamic "accepter" {
    for_each = try(each.value.accepter_options, null) != null ? [each.value.accepter_options] : []
    content {
      allow_remote_vpc_dns_resolution = try(accepter.value.allow_remote_vpc_dns_resolution, null)
    }
  }

  dynamic "requester" {
    for_each = try(each.value.requester_options, null) != null ? [each.value.requester_options] : []
    content {
      allow_remote_vpc_dns_resolution = try(requester.value.allow_remote_vpc_dns_resolution, null)
    }
  }
}
