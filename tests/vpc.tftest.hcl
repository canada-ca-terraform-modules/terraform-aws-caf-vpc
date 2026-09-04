mock_provider "aws" {}

# ---------------------------------------------------------------------------
# Shared variables reused across all runs
# ---------------------------------------------------------------------------
variables {
  env               = "Dev"
  userDefinedString = "myapp"
  tags              = { environment = "test" }
  vpc               = {}
}

# ---------------------------------------------------------------------------
# naming_convention
# Verifies the generated Name tag is derived from env + userDefinedString
# and respects AWS's 256-character tag-value limit.
# ---------------------------------------------------------------------------
run "naming_convention" {
  command = plan

  assert {
    condition     = aws_vpc.this[0].tags["Name"] == "Dev-myapp"
    error_message = "Name tag must be derived from env-userDefinedString"
  }

  assert {
    condition     = length(aws_vpc.this[0].tags["Name"]) <= 256
    error_message = "Name tag must not exceed the AWS tag-value limit of 256 characters"
  }

  assert {
    condition     = can(regex("^[0-9A-Za-z .:+=@_/-]+$", aws_vpc.this[0].tags["Name"]))
    error_message = "Name tag must only contain characters AWS allows in a tag value"
  }
}

# ---------------------------------------------------------------------------
# naming_convention_truncation_edge_case
# A userDefinedString long enough to push the assembled Name tag past the
# 256-character tag-value limit must be truncated, not rejected.
# ---------------------------------------------------------------------------
run "naming_convention_truncation_edge_case" {
  command = plan

  variables {
    env               = "prod"
    userDefinedString = join("", [for i in range(60) : "abcdefghij"]) # 600 chars
  }

  assert {
    condition     = length(aws_vpc.this[0].tags["Name"]) <= 256
    error_message = "Name tag must not exceed 256 characters even after truncation"
  }
}

# ---------------------------------------------------------------------------
# naming_strips_disallowed_characters
# Characters outside AWS's tag-value charset (e.g. from a userDefinedString
# containing punctuation not on the allow-list) must be stripped, not
# passed through.
# ---------------------------------------------------------------------------
run "naming_strips_disallowed_characters" {
  command = plan

  variables {
    userDefinedString = "my!app#2024"
  }

  assert {
    condition     = can(regex("^[0-9A-Za-z .:+=@_/-]+$", aws_vpc.this[0].tags["Name"]))
    error_message = "Disallowed characters must be stripped from the Name tag"
  }
}

# ---------------------------------------------------------------------------
# naming_custom_name_override
# vpc.name, when set, overrides the auto-derived env-userDefinedString Name
# tag - still sanitized against the tag-value charset and length limit.
# ---------------------------------------------------------------------------
run "naming_custom_name_override" {
  command = plan

  variables {
    vpc = { name = "my-custom-vpc-name!" }
  }

  assert {
    condition     = aws_vpc.this[0].tags["Name"] == "my-custom-vpc-name"
    error_message = "vpc.name must override the auto-derived Name tag, sanitized against the tag-value charset"
  }
}

# ---------------------------------------------------------------------------
# default_values
# Plan succeeds with an empty vpc object (all optional fields defaulted)
# ---------------------------------------------------------------------------
run "default_values" {
  command = plan

  assert {
    condition     = aws_vpc.this[0].instance_tenancy == "default"
    error_message = "instance_tenancy must default to \"default\""
  }

  assert {
    condition     = aws_vpc.this[0].enable_dns_support == true
    error_message = "enable_dns_support must default to true"
  }

  assert {
    condition     = length(aws_default_vpc.this) == 0
    error_message = "aws_default_vpc must not be created by default"
  }
}

# ---------------------------------------------------------------------------
# tags_are_merged_with_module_tag
# ---------------------------------------------------------------------------
run "tags_are_merged_with_module_tag" {
  command = plan

  variables {
    vpc = {
      tags = { owner = "team-x" }
    }
  }

  assert {
    condition     = aws_vpc.this[0].tags["environment"] == "test"
    error_message = "Caller-supplied tags must be preserved"
  }
  assert {
    condition     = aws_vpc.this[0].tags["owner"] == "team-x"
    error_message = "vpc.tags must be merged in"
  }
  assert {
    condition     = contains(keys(aws_vpc.this[0].tags), "module")
    error_message = "module tag must be merged into tags"
  }
}

# ---------------------------------------------------------------------------
# core_vpc_arguments
# Every core aws_vpc argument is wired through from var.vpc.
# ---------------------------------------------------------------------------
run "core_vpc_arguments" {
  command = plan

  variables {
    vpc = {
      cidr_block                           = "10.0.0.0/16"
      instance_tenancy                     = "dedicated"
      enable_dns_hostnames                 = true
      enable_dns_support                   = false
      enable_network_address_usage_metrics = true
      assign_generated_ipv6_cidr_block     = true
    }
  }

  assert {
    condition     = aws_vpc.this[0].cidr_block == "10.0.0.0/16"
    error_message = "cidr_block must be passed through"
  }
  assert {
    condition     = aws_vpc.this[0].instance_tenancy == "dedicated"
    error_message = "instance_tenancy must be passed through"
  }
  assert {
    condition     = aws_vpc.this[0].enable_dns_support == false
    error_message = "enable_dns_support must be overridable"
  }
}

# ---------------------------------------------------------------------------
# use_default_vpc
# When use_default_vpc = true, aws_default_vpc is created instead of
# aws_vpc, and every other resource resolves its vpc_id from it.
# ---------------------------------------------------------------------------
run "use_default_vpc" {
  command = plan

  variables {
    vpc = {
      use_default_vpc = true
      default_vpc = {
        tags = { owner = "team-x" }
      }
    }
  }

  assert {
    condition     = length(aws_vpc.this) == 0
    error_message = "aws_vpc must not be created when use_default_vpc = true"
  }
  assert {
    condition     = length(aws_default_vpc.this) == 1
    error_message = "aws_default_vpc must be created when use_default_vpc = true"
  }
  assert {
    condition     = aws_default_vpc.this[0].tags["owner"] == "team-x"
    error_message = "default_vpc.tags must be merged in"
  }
}

# ---------------------------------------------------------------------------
# optional_features_absent_by_default
# One assert per optional sub-family resource - every for_each-gated
# resource must have length() == 0 with an empty vpc object.
# ---------------------------------------------------------------------------
run "optional_features_absent_by_default" {
  command = plan

  assert {
    condition     = length(aws_vpc_ipv4_cidr_block_association.this) == 0
    error_message = "secondary_ipv4_cidr_blocks must not be created by default"
  }
  assert {
    condition     = length(aws_vpc_ipv6_cidr_block_association.this) == 0
    error_message = "secondary_ipv6_cidr_blocks must not be created by default"
  }
  assert {
    condition     = length(aws_vpc_dhcp_options.this) == 0
    error_message = "dhcp_options must not be created by default"
  }
  assert {
    condition     = length(aws_vpc_dhcp_options_association.this) == 0
    error_message = "dhcp_options_association must not be created by default"
  }
  assert {
    condition     = length(aws_default_vpc_dhcp_options.this) == 0
    error_message = "default_vpc_dhcp_options must not be created by default"
  }
  assert {
    condition     = length(aws_default_security_group.this) == 0
    error_message = "default_security_group must not be created by default"
  }
  assert {
    condition     = length(aws_default_route_table.this) == 0
    error_message = "default_route_table must not be created by default"
  }
  assert {
    condition     = length(aws_default_network_acl.this) == 0
    error_message = "default_network_acl must not be created by default"
  }
  assert {
    condition     = length(aws_default_subnet.this) == 0
    error_message = "default_subnets must not be created by default"
  }
  assert {
    condition     = length(aws_vpc_encryption_control.this) == 0
    error_message = "encryption_control must not be created by default"
  }
  assert {
    condition     = length(aws_vpc_block_public_access_exclusion.this) == 0
    error_message = "block_public_access_exclusions must not be created by default"
  }
  assert {
    condition     = length(aws_vpc_peering_connection.this) == 0
    error_message = "peering_connections must not be created by default"
  }
  assert {
    condition     = length(aws_vpc_peering_connection_accepter.this) == 0
    error_message = "peering_connection accepter must not be created by default"
  }
  assert {
    condition     = length(aws_vpc_peering_connection_options.this) == 0
    error_message = "peering_connection standalone options must not be created by default"
  }
}

# ---------------------------------------------------------------------------
# secondary_cidr_blocks
# ---------------------------------------------------------------------------
run "secondary_cidr_blocks" {
  command = plan

  variables {
    vpc = {
      secondary_ipv4_cidr_blocks = {
        extra1 = { cidr_block = "10.1.0.0/16" }
      }
      secondary_ipv6_cidr_blocks = {
        extra1 = { assign_generated_ipv6_cidr_block = true }
      }
    }
  }

  assert {
    condition     = aws_vpc_ipv4_cidr_block_association.this["extra1"].cidr_block == "10.1.0.0/16"
    error_message = "secondary IPv4 CIDR block must be created with the given cidr_block"
  }
  assert {
    condition     = length(aws_vpc_ipv6_cidr_block_association.this) == 1
    error_message = "secondary IPv6 CIDR block must be created"
  }
}

# ---------------------------------------------------------------------------
# dhcp_options
# Creating dhcp_options also creates its association, bound to the VPC.
# ---------------------------------------------------------------------------
run "dhcp_options" {
  command = plan

  variables {
    vpc = {
      dhcp_options = {
        domain_name         = "example.com"
        domain_name_servers = ["AmazonProvidedDNS"]
      }
    }
  }

  assert {
    condition     = aws_vpc_dhcp_options.this["enabled"].domain_name == "example.com"
    error_message = "dhcp_options.domain_name must be passed through"
  }
  assert {
    condition     = length(aws_vpc_dhcp_options_association.this) == 1
    error_message = "dhcp_options_association must be created alongside dhcp_options"
  }
}

# ---------------------------------------------------------------------------
# default_vpc_dhcp_options
# ---------------------------------------------------------------------------
run "default_vpc_dhcp_options" {
  command = plan

  variables {
    vpc = {
      default_vpc_dhcp_options = {
        tags = { owner = "team-x" }
      }
    }
  }

  assert {
    condition     = length(aws_default_vpc_dhcp_options.this) == 1
    error_message = "default_vpc_dhcp_options must be created when configured"
  }
}

# ---------------------------------------------------------------------------
# default_security_group
# ---------------------------------------------------------------------------
run "default_security_group" {
  command = plan

  variables {
    vpc = {
      default_security_group = {
        ingress = [
          {
            protocol  = "-1"
            from_port = 0
            to_port   = 0
            self      = true
          }
        ]
      }
    }
  }

  assert {
    condition     = length(aws_default_security_group.this) == 1
    error_message = "default_security_group must be created when configured"
  }
}

# ---------------------------------------------------------------------------
# default_route_table
# ---------------------------------------------------------------------------
run "default_route_table" {
  command = plan

  variables {
    vpc = {
      default_route_table = {
        route = []
      }
    }
  }

  assert {
    condition     = length(aws_default_route_table.this) == 1
    error_message = "default_route_table must be created when configured"
  }
}

# ---------------------------------------------------------------------------
# default_network_acl
# ---------------------------------------------------------------------------
run "default_network_acl" {
  command = plan

  variables {
    vpc = {
      default_network_acl = {
        ingress = [
          {
            rule_no    = 100
            action     = "allow"
            from_port  = 0
            to_port    = 0
            protocol   = "-1"
            cidr_block = "0.0.0.0/0"
          }
        ]
      }
    }
  }

  assert {
    condition     = length(aws_default_network_acl.this) == 1
    error_message = "default_network_acl must be created when configured"
  }
}

# ---------------------------------------------------------------------------
# default_subnets
# ---------------------------------------------------------------------------
run "default_subnets" {
  command = plan

  variables {
    vpc = {
      default_subnets = {
        az1 = { availability_zone = "ca-central-1a" }
      }
    }
  }

  assert {
    condition     = aws_default_subnet.this["az1"].availability_zone == "ca-central-1a"
    error_message = "default_subnets must pass through availability_zone"
  }
}

# ---------------------------------------------------------------------------
# encryption_control
# ---------------------------------------------------------------------------
run "encryption_control" {
  command = plan

  variables {
    vpc = {
      encryption_control = {
        mode = "monitor"
      }
    }
  }

  assert {
    condition     = aws_vpc_encryption_control.this["enabled"].mode == "monitor"
    error_message = "encryption_control.mode must be passed through"
  }
}

# ---------------------------------------------------------------------------
# block_public_access_exclusions
# ---------------------------------------------------------------------------
run "block_public_access_exclusions" {
  command = plan

  variables {
    vpc = {
      block_public_access_exclusions = {
        vpc-wide = {
          internet_gateway_exclusion_mode = "allow-egress"
        }
        subnet-only = {
          internet_gateway_exclusion_mode = "allow-bidirectional"
          subnet_id                       = "subnet-0123456789abcdef0"
        }
      }
    }
  }

  assert {
    condition     = aws_vpc_block_public_access_exclusion.this["vpc-wide"].subnet_id == null
    error_message = "an exclusion without subnet_id must not set subnet_id"
  }
  assert {
    condition     = aws_vpc_block_public_access_exclusion.this["subnet-only"].subnet_id == "subnet-0123456789abcdef0"
    error_message = "an exclusion with subnet_id must scope to that subnet"
  }
  assert {
    condition     = aws_vpc_block_public_access_exclusion.this["subnet-only"].vpc_id == null
    error_message = "vpc_id must be null when subnet_id is set (mutually exclusive)"
  }
}

# ---------------------------------------------------------------------------
# peering_connections
# Covers the requester-only case, the accepter-managed case, and the
# standalone-options case.
# ---------------------------------------------------------------------------
run "peering_connections" {
  command = plan

  variables {
    vpc = {
      peering_connections = {
        requester_only = {
          peer_vpc_id = "vpc-0123456789abcdef0"
        }
        with_accepter = {
          peer_vpc_id = "vpc-0fedcba9876543210"
          accept      = true
        }
        standalone_options = {
          peer_vpc_id               = "vpc-0aaaaaaaaaaaaaaaa"
          manage_options_standalone = true
          requester_options = {
            allow_remote_vpc_dns_resolution = true
          }
        }
      }
    }
  }

  assert {
    condition     = length(aws_vpc_peering_connection.this) == 3
    error_message = "one aws_vpc_peering_connection must be created per entry"
  }
  assert {
    condition     = length(aws_vpc_peering_connection_accepter.this) == 1
    error_message = "only the entry with accept = true must create an accepter"
  }
  assert {
    condition     = length(aws_vpc_peering_connection_options.this) == 1
    error_message = "only the entry with manage_options_standalone = true must create standalone options"
  }
}
