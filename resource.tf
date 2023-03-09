terraform {

  required_providers {

    azurerm = {

      source  = "hashicorp/azurerm"

      version = "3.44.1"

    }

  }

}




provider "azurerm" {

  features {




  }

}

resource "azurerm_policy_definition" "addTagToRG" {
  #count = length(var.mandatory_tag_keys)

  name         = "addTagToRG_${var.mandatory_tag_key}"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Add tag ${var.mandatory_tag_key} to resource group"
  description  = "Adds the mandatory tag key ${var.mandatory_tag_key} when any resource group missing this tag is created or updated. \nExisting resource groups can be remediated by triggering a remediation task.\nIf the tag exists with a different value it will not be changed."

  metadata = <<METADATA
    {
    "category": "${var.policy_definition_category}",
    "version" : "1.0.0"
    }
METADATA

  policy_rule = <<POLICY_RULE
    {
        "if": {
          "allOf": [
            {
              "field": "type",
              "equals": "Microsoft.Resources/subscriptions/resourceGroups"
            },
            {
              "field": "[concat('tags[', parameters('tagName'), ']')]",
              "exists": "false"
            }
          ]
        },
        "then": {
          "effect": "modify",
          "details": {
            "roleDefinitionIds": [
              "/providers/microsoft.authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
            ],
            "operations": [
              {
                "operation": "add",
                "field": "[concat('tags[', parameters('tagName'), ']')]",
                "value": "[parameters('tagValue')]"
              }
            ]
          }
        }
  }
POLICY_RULE


  parameters = <<PARAMETERS
    {
        "tagName": {
          "type": "String",
          "metadata": {
            "displayName": "Mandatory Tag ${var.mandatory_tag_key}",
            "description": "Name of the tag, such as ${var.mandatory_tag_key}"
          },
          "defaultValue": "${var.mandatory_tag_key}"
        },
        "tagValue": {
          "type": "String",
          "metadata": {
            "displayName": "Tag Value '${var.mandatory_tag_value}'",
            "description": "Value of the tag, such as '${var.mandatory_tag_value}'"
          },
          "defaultValue": "'${var.mandatory_tag_value}'"
        }
  }
PARAMETERS

}
resource "azurerm_subscription_policy_assignment" "tag_governance" {
  name                 = "tag_governance"
  description          = "Assignment of the Tag Governance policy to subscription."
  policy_definition_id = azurerm_policy_definition.addTagToRG.id
