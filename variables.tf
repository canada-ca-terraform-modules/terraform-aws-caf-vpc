variable "tags" {
  description = "Tags applied to all resources (merged with vpc.tags)"
  type        = map(string)
  default     = {}
}

variable "env" {
  description = "(Required) env value used in name generation"
  type        = string
}

variable "userDefinedString" {
  description = "(Required) UserDefinedString part of the name of the VPC"
  type        = string
}

variable "vpc" {
  description = "(Required) Object describing the VPC (see TFVars Parameters below). Optional `name` key overrides the auto-derived \"env-userDefinedString\" Name tag value."
  type        = any
  default     = {}
}
