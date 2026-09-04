# Changelog

All notable changes to this module are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
This file must be updated as part of every change to this module.

## [1.0.0] - 2026-09-04

### Added

- Initial release: `aws_vpc` core VPC resource (CIDR block, IPAM-derived
  CIDR, instance tenancy, DNS support/hostnames, Network Address Usage
  metrics, IPv6 CIDR) for aws provider `~> 6.0` (tested against `6.63.0`),
  following the terraform-aws-caf-s3_bucket module conventions (single
  `vpc` object variable, `locals.tf`/`name.tf` split, ESLZ `for_each`
  wrapper).
- `aws_default_vpc` support (`use_default_vpc = true`) to adopt the
  account's pre-existing default VPC instead of creating a new one.
- Secondary CIDR blocks: `aws_vpc_ipv4_cidr_block_association`,
  `aws_vpc_ipv6_cidr_block_association` (map-keyed, multiple per VPC).
- Custom DHCP options: `aws_vpc_dhcp_options` +
  `aws_vpc_dhcp_options_association`, and the account-wide
  `aws_default_vpc_dhcp_options`.
- Default VPC components: `aws_default_security_group`,
  `aws_default_route_table`, `aws_default_network_acl`,
  `aws_default_subnet` (map-keyed by Availability Zone).
- `aws_vpc_encryption_control` (VPC Encryption "encrypt everywhere"
  guardrail).
- `aws_vpc_block_public_access_exclusion` (map-keyed, VPC-wide or
  subnet-scoped exclusions).
- VPC Peering: `aws_vpc_peering_connection` (map-keyed, multiple peers),
  with optional `aws_vpc_peering_connection_accepter` and standalone
  `aws_vpc_peering_connection_options` per connection.
- `tests/vpc.tftest.hcl` with 18 test runs covering every feature plus
  Name-tag naming edge cases (max length, truncation, disallowed
  characters).
- `README.md` (usage, terraform-docs injected block, TFVars Parameters
  table, and a documented Scope section) and `ESLZ/vpc.tfvars` covering
  the full feature set.

### Scope

Deliberately excludes `aws_vpc_endpoint*`, `aws_vpc_ipam*`,
`aws_vpc_route_server*`, `aws_vpc_security_group_*` (rule/association
resources), `aws_vpclattice_*`, `aws_vpc_block_public_access_options`
(region-wide singleton), and
`aws_vpc_network_performance_metric_subscription` - each belongs to its
own independently-lifecycled AWS service/feature and is not scoped to a
single VPC. See `README.md`'s "Scope" section for the full rationale.
