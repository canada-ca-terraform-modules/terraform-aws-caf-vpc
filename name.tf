## Naming logic — derives the value used for the VPC's "Name" tag.
## aws_vpc (and every other resource in this module) has no `name` argument
## of its own - AWS VPC resources are identified only by ID, with "Name" a
## convention enforced purely via tags. So the AWS restriction that applies
## here is the generic EC2/tag-value restriction, not a resource-specific
## one: max 256 Unicode characters, charset limited to letters, digits,
## spaces, and `. : + = @ _ / -` (see naming-rules.md's procedure - this
## table entry is the tag-value restriction, confirmed against AWS's
## tagging documentation instead of an EC2-resource-name restriction since
## none exists for aws_vpc).
##
## Unlike aws_s3_bucket, the tag value has no global-uniqueness requirement
## and no begin/end constraint, so no sha1 uniqueness suffix and no
## trim-after-truncate step are needed here - a plain substr truncation is
## sufficient (see naming-rules.md step 5: "a plain substr truncation is
## only safe for resource types with no begin/end constraint").
## `var.vpc.name`, when set, overrides the auto-derived "env-userDefinedString"
## name below - still sanitized against the same tag-value charset and
## truncated to the same 256-char limit, so an explicit custom name can
## never violate the restriction the auto-derived name is built to respect.
locals {
  vpc-name-tag-regex = "/[^0-9A-Za-z .:+=@_\\/-]/" # AWS tag-value charset
  env-compliant      = replace(var.env, local.vpc-name-tag-regex, "")
  name-compliant     = replace(var.userDefinedString, local.vpc-name-tag-regex, "")
  # 256 = AWS's max tag *value* length, applied after assembling env + userDefinedString.
  vpc-name-auto   = substr("${local.env-compliant}-${local.name-compliant}", 0, 256)
  vpc-name-custom = try(var.vpc.name, null)
  vpc-name        = local.vpc-name-custom != null ? substr(replace(local.vpc-name-custom, local.vpc-name-tag-regex, ""), 0, 256) : local.vpc-name-auto
}
