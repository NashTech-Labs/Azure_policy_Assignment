output "addTagToRG_policy_ids" {
  value       = azurerm_policy_definition.TagForRG.*.id
  description = "The policy definition ids for TagForRG policy"
}

