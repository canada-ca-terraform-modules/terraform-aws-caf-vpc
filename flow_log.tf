# VPC flow log, delegated to the companion terraform-aws-caf-flow_log module so its naming,
# log group and delivery role stay implemented in one place. Each value of vpc.flow_log is
# that module's `flow_log` object; deploy = false turns it off.
module "flow_log" {
  source   = "github.com/canada-ca-terraform-modules/terraform-aws-caf-flow_log.git?ref=v1.0.0"
  for_each = try(var.vpc.flow_log, null) != null && try(var.vpc.flow_log.deploy, true) ? { enabled = true } : {}

  env               = var.env
  userDefinedString = var.userDefinedString
  flow_log          = merge(var.vpc.flow_log, { vpc_id = local.vpc_id })
  tags              = var.tags
}
