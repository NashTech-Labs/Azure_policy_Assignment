terraform {

  required_providers {

    azurerm = {

      source  = "hashicorp/azurerm"

      version = "3.44.1"

    }

  }

}
provider "azurerm" {
  features {}  
}
resource "azurerm_policy_definition" "TagForRG" {
 
  name         = var.mandatory_tag_key
  policy_type  = "Custom"
  mode         = "All"
  display_name = var.mandatory_tag_key
  #description  = var.mandatory_tag_key  

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
            "equals": "Microsoft.Resources/subscriptions/resourceGroups",
            "field": "type"
          },
          {
            "exists": "false",
            "field": "[concat('tags[', parameters('tagName'), ']')]"
          }
        ]
      },
      "then": {
        "details": {
          "operations": [
            {
              "field": "[concat('tags[', parameters('tagName'), ']')]",
              "operation": "add",
              "value": "[parameters('tagValue')]"
            }
          ],
          "roleDefinitionIds": [
            "/providers/microsoft.authorization/roleDefinitions/0f2e685f-410b-4d1a-a18c-83ae2efaad95"
          ]
        },
        "effect": "modify"
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
            "displayName": "Tag Value '${var.mandatory_tag}'",
            "description": "Value of the tag, such as '${var.mandatory_tag}'"
          },
          "defaultValue": "'${var.mandatory_tag}'"
        }
  }
PARAMETERS

}
resource "azurerm_subscription_policy_assignment" "tag_governance" {
  name                 = var.tag_governance
  description          = "Assignment of the Tag Governance policy to subscription."
  policy_definition_id = azurerm_policy_definition.TagForRG.id
  subscription_id      = data.azurerm_subscription.current.id
  identity { type = var.identity }
  location = var.location
}
