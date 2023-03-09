variable "mandatory_tag_key" {
  type        = string
  description = "Mandatory tag key used by policy 'TagForRG'"
  default = "CostCentre"
}
variable "mandatory_tag" {
  type        = string
  description = "Tag value to include with the mandatory tag key used by policy 'TagForRG'"
  default     = "DCODNext"
}

variable "policy_definition_category" {
  type        = string
  description = "The category to use for all Policy Definitions"
  default     = "Custom"
}

data "azurerm_subscription" "current" {
}

variable "environmentKey" {
  type        = string
  description = "Optional Input - Value to describe the environment. Used for tagging. (Default: DevAKS)"
  default     = "DevAKS"
}
variable "tag_governance" {

  type = string

  description = "Specifies the name of policy-assignment"
}
variable "location" {

  type = string

  description = "Specifies the location of identity "
}
variable "identity" {
  type = string
  description = "(required-input )specifies the type of identity for policy assignment"
}

