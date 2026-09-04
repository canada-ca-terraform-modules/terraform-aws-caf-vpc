vpcs = {
  example01 = { # Key defines the userDefinedString
    # name               = "my-custom-vpc-name" # Optional: overrides the auto-derived "<env>-example01" Name tag
    cidr_block         = "10.0.0.0/16" # Optional: primary IPv4 CIDR block
    instance_tenancy   = "default"     # Optional: default, dedicated. Default: default
    enable_dns_support = true          # Optional: Default: true
    # enable_dns_hostnames                 = true  # Optional: Default: false
    # enable_network_address_usage_metrics = false # Optional: Default: false
    # assign_generated_ipv6_cidr_block     = false # Optional: Amazon-provided /56 IPv6 CIDR
    # ipv4_ipam_pool_id    = "ipam-pool-0123456789abcdef0" # Optional: allocate cidr_block from IPAM
    # ipv4_netmask_length  = 24                            # Optional: requires ipv4_ipam_pool_id
    # ipv6_cidr_block                        = "2001:db8::/56" # Optional
    # ipv6_cidr_block_network_border_group   = "ca-central-1" # Optional
    # ipv6_ipam_pool_id                      = "ipam-pool-0123456789abcdef1" # Optional
    # ipv6_netmask_length                    = 56 # Optional: 44-60 in increments of 4
    # tags = {                            # Optional: merged with ESLZ-level tags
    #   owner = "team-x"
    # }

    # Optional: adopt the account's pre-existing default VPC in this
    # region instead of creating a new one. Mutually exclusive with the
    # cidr_block/etc. arguments above.
    # use_default_vpc = true
    # default_vpc = {
    #   force_destroy = false # Optional: allow destroying a non-empty default VPC
    #   tags = { owner = "team-x" }
    # }

    # Optional: additional CIDR blocks beyond the primary one, keyed by name
    # secondary_ipv4_cidr_blocks = {
    #   extra01 = { cidr_block = "10.1.0.0/16" }
    #   # or allocate from IPAM: { ipv4_ipam_pool_id = "...", ipv4_netmask_length = 24 }
    # }
    # secondary_ipv6_cidr_blocks = {
    #   extra01 = { assign_generated_ipv6_cidr_block = true }
    # }

    # Optional: custom DHCP options set + association for this VPC
    # dhcp_options = {
    #   domain_name         = "example.internal"
    #   domain_name_servers = ["AmazonProvidedDNS"]
    #   ntp_servers         = ["10.0.0.2"]
    #   # netbios_name_servers = ["10.0.0.3"]
    #   # netbios_node_type    = "2"
    #   # tags = { owner = "team-x" }
    # }

    # Optional: manage the account's default DHCP options set (region-wide
    # singleton, independent of this VPC)
    # default_vpc_dhcp_options = {
    #   tags = { owner = "team-x" }
    # }

    # Optional: adopt/manage the VPC's default security group
    # default_security_group = {
    #   ingress = [
    #     { protocol = "-1", from_port = 0, to_port = 0, self = true }
    #   ]
    #   egress = [
    #     { protocol = "-1", from_port = 0, to_port = 0, cidr_blocks = ["0.0.0.0/0"] }
    #   ]
    #   # revoke_rules_on_delete = false
    # }

    # Optional: adopt/manage the VPC's default route table
    # default_route_table = {
    #   route = [
    #     { cidr_block = "0.0.0.0/0", gateway_id = "igw-0123456789abcdef0" }
    #   ]
    #   # propagating_vgws = ["vgw-0123456789abcdef0"]
    # }

    # Optional: adopt/manage the VPC's default network ACL
    # default_network_acl = {
    #   subnet_ids = ["subnet-0123456789abcdef0"]
    #   ingress = [
    #     { rule_no = 100, action = "allow", from_port = 0, to_port = 0, protocol = "-1", cidr_block = "0.0.0.0/0" }
    #   ]
    #   egress = [
    #     { rule_no = 100, action = "allow", from_port = 0, to_port = 0, protocol = "-1", cidr_block = "0.0.0.0/0" }
    #   ]
    # }

    # Optional: adopt/manage per-Availability-Zone default subnets, keyed by name
    # default_subnets = {
    #   ca-central-1a = { availability_zone = "ca-central-1a" }
    #   # map_public_ip_on_launch = true # Optional
    # }

    # Optional: VPC Encryption Control ("encrypt everywhere" guardrail)
    # encryption_control = {
    #   mode = "monitor" # Required: monitor, enforce
    #   # internet_gateway_exclusion             = "eligible" # Optional per-path exclusion overrides
    #   # nat_gateway_exclusion                   = "eligible"
    #   # egress_only_internet_gateway_exclusion  = "eligible"
    #   # elastic_file_system_exclusion           = "eligible"
    #   # lambda_exclusion                        = "eligible"
    #   # virtual_private_gateway_exclusion       = "eligible"
    # }

    # Optional: VPC Block Public Access exclusions, keyed by name
    # block_public_access_exclusions = {
    #   vpc-wide = { internet_gateway_exclusion_mode = "allow-egress" }         # excludes the whole VPC
    #   # subnet01 = { internet_gateway_exclusion_mode = "allow-bidirectional", subnet_id = "subnet-0123456789abcdef0" }
    # }

    # Optional: VPC Peering connections, keyed by name
    # peering_connections = {
    #   to-shared-services = {
    #     peer_vpc_id  = "vpc-0123456789abcdef0"
    #     # peer_owner_id = "123456789012" # Optional: cross-account peering
    #     # peer_region   = "ca-central-1" # Optional: inter-region peering
    #     # auto_accept   = true           # Optional: only valid for same-account/region peering
    #     # accept = true                  # Optional: also manage the accepter side from this module
    #     # manage_options_standalone = true # Optional: manage DNS-resolution options without an accepter resource
    #     # requester_options = { allow_remote_vpc_dns_resolution = true }
    #     # accepter_options  = { allow_remote_vpc_dns_resolution = true }
    #   }
    # }
  }
}
