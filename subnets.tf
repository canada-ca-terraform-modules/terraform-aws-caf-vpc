# Custom subnets declared under vpc.subnets, keyed by name. Delegated to the
# companion terraform-aws-caf-subnet module so subnet naming, routing and
# CIDR reservations stay implemented in one place. Each value is that
# module's `subnet` object. Uses lookup() rather than try() so the map keys
# stay known when a subnet value is only known after apply.
module "subnets" {
  source   = "github.com/canada-ca-terraform-modules/terraform-aws-caf-subnet.git?ref=v1.0.0"
  for_each = lookup(var.vpc, "subnets", {})

  env               = var.env
  userDefinedString = "${var.userDefinedString}-${each.key}"
  vpc_id            = local.vpc_id
  subnet            = each.value
  tags              = var.tags
}
