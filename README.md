# terraform-aws-caf-vpc

CAF-compliant Terraform module for creating an AWS VPC. Supports the full core `aws_vpc` resource surface available in aws provider `~> 6.0` (tested against `6.63.0`), plus the resources that are directly, 1:1 scoped to a single VPC: secondary IPv4/IPv6 CIDR blocks, a custom DHCP options set + association, the account's default DHCP options set, VPC Encryption Control, VPC Block Public Access exclusions, VPC Peering (requester, accepter, and standalone options), and the always-created default VPC components (default security group, default route table, default network ACL, default subnets) - including the ability to adopt the account's pre-existing default VPC instead of creating a new one.

See [Scope](#scope) below for AWS resources that share the `aws_vpc_` text prefix but are deliberately **not** part of this module.

## Usage

### ESLZ module block (`ESLZ/vpc.tf`)

```hcl
module "vpc" {
  source   = "github.com/canada-ca-terraform-modules/terraform-aws-caf-vpc.git?ref=v1.0.0"
  for_each = var.vpcs

  env               = var.env
  userDefinedString = each.key
  vpc               = each.value
  tags              = var.tags
}
```

See [`ESLZ/vpc.tfvars`](ESLZ/vpc.tfvars) for the full set of `vpc` object parameters.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.63.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_default_network_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl) | resource |
| [aws_default_route_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table) | resource |
| [aws_default_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_default_subnet.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_subnet) | resource |
| [aws_default_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_vpc) | resource |
| [aws_default_vpc_dhcp_options.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_vpc_dhcp_options) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_block_public_access_exclusion.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_block_public_access_exclusion) | resource |
| [aws_vpc_dhcp_options.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options) | resource |
| [aws_vpc_dhcp_options_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options_association) | resource |
| [aws_vpc_encryption_control.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_encryption_control) | resource |
| [aws_vpc_ipv4_cidr_block_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_ipv4_cidr_block_association) | resource |
| [aws_vpc_ipv6_cidr_block_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_ipv6_cidr_block_association) | resource |
| [aws_vpc_peering_connection.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection) | resource |
| [aws_vpc_peering_connection_accepter.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection_accepter) | resource |
| [aws_vpc_peering_connection_options.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection_options) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_env"></a> [env](#input\_env) | (Required) env value used in name generation | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to all resources (merged with vpc.tags) | `map(string)` | `{}` | no |
| <a name="input_userDefinedString"></a> [userDefinedString](#input\_userDefinedString) | (Required) UserDefinedString part of the name of the VPC | `string` | n/a | yes |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | (Required) Object describing the VPC (see TFVars Parameters below) | `any` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_arn"></a> [arn](#output\_arn) | Returns the ARN of the VPC |
| <a name="output_cidr_block"></a> [cidr\_block](#output\_cidr\_block) | Returns the primary IPv4 CIDR block of the VPC |
| <a name="output_default_network_acl_id"></a> [default\_network\_acl\_id](#output\_default\_network\_acl\_id) | Returns the ID of the VPC's default network ACL |
| <a name="output_default_route_table_id"></a> [default\_route\_table\_id](#output\_default\_route\_table\_id) | Returns the ID of the VPC's default route table |
| <a name="output_default_security_group_id"></a> [default\_security\_group\_id](#output\_default\_security\_group\_id) | Returns the ID of the VPC's default security group |
| <a name="output_default_subnet_ids"></a> [default\_subnet\_ids](#output\_default\_subnet\_ids) | Returns the IDs of managed default subnets, keyed by the caller's chosen name |
| <a name="output_dhcp_options_id"></a> [dhcp\_options\_id](#output\_dhcp\_options\_id) | Returns the ID of the DHCP options set associated with the VPC |
| <a name="output_id"></a> [id](#output\_id) | Returns the ID of the VPC |
| <a name="output_name"></a> [name](#output\_name) | Returns the generated Name tag value of the VPC |
| <a name="output_object"></a> [object](#output\_object) | Returns the full VPC object (whichever of aws\_vpc/aws\_default\_vpc was created) |
| <a name="output_peering_connection_ids"></a> [peering\_connection\_ids](#output\_peering\_connection\_ids) | Returns the IDs of VPC peering connections, keyed by the caller's chosen name |
| <a name="output_secondary_ipv4_cidr_block_associations"></a> [secondary\_ipv4\_cidr\_block\_associations](#output\_secondary\_ipv4\_cidr\_block\_associations) | Returns the IDs of secondary IPv4 CIDR block associations, keyed by the caller's chosen name |
| <a name="output_secondary_ipv6_cidr_block_associations"></a> [secondary\_ipv6\_cidr\_block\_associations](#output\_secondary\_ipv6\_cidr\_block\_associations) | Returns the IDs of secondary IPv6 CIDR block associations, keyed by the caller's chosen name |
<!-- END_TF_DOCS -->

## TFVars Parameters

| Parameter | Type | Default | Description |
| --------- | ---- | ------- | ----------- |
| `name` | string | `null` | Optional custom "Name" tag value. When omitted, defaults to `"<env>-<userDefinedString>"`. Either way, sanitized against AWS's tag-value charset and truncated to 256 characters. |
| `use_default_vpc` | bool | `false` | Adopt the account's pre-existing default VPC in this region instead of creating a new one. Mutually exclusive with the core `aws_vpc` arguments below. |
| `cidr_block` | string | `null` | Primary IPv4 CIDR block. |
| `instance_tenancy` | string | `"default"` | `default` or `dedicated`. |
| `enable_dns_support` | bool | `true` | Whether to enable DNS support. |
| `enable_dns_hostnames` | bool | `false` (AWS default) | Whether to enable DNS hostnames. |
| `enable_network_address_usage_metrics` | bool | `false` (AWS default) | Whether to enable Network Address Usage metrics. |
| `assign_generated_ipv6_cidr_block` | bool | `false` | Request an Amazon-provided /56 IPv6 CIDR block. |
| `ipv4_ipam_pool_id` / `ipv4_netmask_length` | string / number | `null` | Allocate `cidr_block` from an IPAM pool instead of specifying it explicitly. |
| `ipv6_cidr_block` / `ipv6_ipam_pool_id` / `ipv6_netmask_length` / `ipv6_cidr_block_network_border_group` | — | `null` | IPv6 CIDR configuration. |
| `tags` | map(string) | `{}` | Merged with ESLZ-level tags and the module tag. |
| `default_vpc` | object | `null` | `{ force_destroy, tags }` - used only when `use_default_vpc = true`. |
| `secondary_ipv4_cidr_blocks` | map(object) | `{}` | Additional IPv4 CIDR blocks, keyed by name. Each: `{ cidr_block }` or `{ ipv4_ipam_pool_id, ipv4_netmask_length }`. |
| `secondary_ipv6_cidr_blocks` | map(object) | `{}` | Additional IPv6 CIDR blocks, keyed by name. Each: `{ assign_generated_ipv6_cidr_block }` or `{ ipv6_cidr_block }` / IPAM equivalents. |
| `dhcp_options` | object | `null` | Creates a custom DHCP options set + association for this VPC: `{ domain_name, domain_name_servers, ntp_servers, netbios_name_servers, netbios_node_type, ipv6_address_preferred_lease_time, tags }`. |
| `default_vpc_dhcp_options` | object | `null` | Manages the account's default DHCP options set (region-wide singleton, independent of `use_default_vpc`): `{ tags }`. |
| `default_security_group` | object | `null` | Adopts/manages the VPC's default security group: `{ ingress, egress, revoke_rules_on_delete, tags }` (`ingress`/`egress` are lists of rule objects). |
| `default_route_table` | object | `null` | Adopts/manages the VPC's default route table: `{ route, propagating_vgws, tags }`. |
| `default_network_acl` | object | `null` | Adopts/manages the VPC's default network ACL: `{ subnet_ids, ingress, egress, tags }` (`ingress`/`egress` are lists of rule objects with `rule_no`/`action`/`from_port`/`to_port`/`protocol`/`cidr_block`/etc.). |
| `default_subnets` | map(object) | `{}` | Adopts/manages per-Availability-Zone default subnets, keyed by name: `{ availability_zone, ipv6_cidr_block, map_public_ip_on_launch, ... }`. |
| `encryption_control` | object | `null` | VPC Encryption Control: `{ mode (required: monitor/enforce), internet_gateway_exclusion, nat_gateway_exclusion, egress_only_internet_gateway_exclusion, elastic_file_system_exclusion, lambda_exclusion, virtual_private_gateway_exclusion, tags }`. |
| `block_public_access_exclusions` | map(object) | `{}` | VPC Block Public Access exclusions, keyed by name: `{ internet_gateway_exclusion_mode (required), subnet_id (optional - defaults to excluding the whole VPC when omitted), tags }`. |
| `peering_connections` | map(object) | `{}` | VPC Peering, keyed by name: `{ peer_vpc_id (required), peer_owner_id, peer_region, auto_accept, accept (bool - also manage the accepter side), manage_options_standalone (bool - manage DNS-resolution options without an accepter resource), requester_options, accepter_options, tags }`. |

## Scope

AWS overloads the `aws_vpc_` resource-name prefix across several otherwise-unrelated services. This module implements the `aws_vpc`/`aws_default_vpc` "core VPC" resource family only - every resource whose configuration is directly, 1:1 scoped to a single VPC via a `vpc_id` (or is one of the VPC's always-created default components). The following resources share the text prefix but are **deliberately out of scope**, each belonging to its own independently-lifecycled AWS service/feature and warranting its own CAF module:

- **`aws_vpc_endpoint*`** (10 resources) - VPC Endpoints (PrivateLink/Gateway) are independently managed, many-per-VPC, and typically owned by the consumer of a specific AWS service.
- **`aws_vpc_ipam*`** (9 resources) - IPAM is an organization/account-wide IP address management service, not scoped to a single VPC.
- **`aws_vpc_route_server*`** (5 resources) - Route Server is a separate dynamic-routing feature optionally attached to VPCs.
- **`aws_vpc_security_group_egress_rule` / `_ingress_rule` / `_rules_exclusive` / `_vpc_association`** - Security Group rule management belongs with the `aws_security_group` resource family, not the VPC.
- **`aws_vpclattice_*`** (13 resources) - VPC Lattice is an entirely separate AWS networking service.
- **`aws_vpc_block_public_access_options`** - A region-wide singleton guardrail setting (no `vpc_id`), distinct from the per-VPC `aws_vpc_block_public_access_exclusion` this module does cover.
- **`aws_vpc_network_performance_metric_subscription`** - Subscribes to metrics between a source/destination Region pair, not scoped to a single VPC.

Also out of scope: **`aws_subnet`** (custom, user-carved subnets - as opposed to the always-created `aws_default_subnet` this module does cover) and its subnet-scoped routing (`aws_route_table`, `aws_route`, `aws_route_table_association`, `aws_main_route_table_association`). Those are covered by the companion [`terraform-aws-caf-subnet`](https://github.com/canada-ca-terraform-modules/terraform-aws-caf-subnet) module, which takes this module's `id` output as its `vpc_id` input.

Also out of scope: **`aws_ec2_transit_gateway*`** (connecting this VPC to other VPCs via a shared Transit Gateway hub) - the hub is an account-wide singleton, not scoped to a single VPC, so the whole resource family (hub, VPC/peering/Connect attachments, route tables, policy tables, multicast, metering) is covered by the companion [`terraform-aws-caf-transit_gateway`](https://github.com/canada-ca-terraform-modules/terraform-aws-caf-transit_gateway) module instead, whose `vpc_attachments` entries take this module's `id` output as their `vpc_id` input. Direct VPC-to-VPC connectivity without a shared hub is `peering.tf`'s `aws_vpc_peering_connection`, already covered here.

`scripts/coverage_check.sh hashicorp/aws 6.63.0 aws_vpc .` reports exactly this exclusion list as "missing" (plus the resources above) - confirming full parity within the documented scope, with no undocumented gaps. `scripts/coverage_check.sh hashicorp/aws 6.63.0 aws_default .` reports full parity (`aws_default_vpc`, `aws_default_vpc_dhcp_options`, `aws_default_security_group`, `aws_default_route_table`, `aws_default_network_acl`, `aws_default_subnet` - all covered).
