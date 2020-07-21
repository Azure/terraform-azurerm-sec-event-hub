provider "azurerm" {
  version = "~>2.0"
  features {}
}

module "naming" {
  source = "git::https://github.com/Azure/terraform-azurerm-naming"
  prefix = var.prefix
  suffix = var.suffix
}

locals {
  event_hubs = flatten([
    for event_hub_key, event_hub in var.event_hubs : [
      for authorisation_rule_key, authorisation_rule in event_hub.authorisation_rules : {
        event_hub_key               = event_hub_key
        event_hub_name              = length(event_hub.name) == 0 ? module.naming.eventhub.name_unique : event_hub.name
        event_hub_partition_count   = event_hub.partition_count
        event_hub_message_retention = event_hub.message_retention
        authorisation_rule_key      = authorisation_rule_key
        authorisation_rule_name     = length(authorisation_rule.name) == 0 ? module.naming.eventhub_authorization_rule.name_unique : authorisation_rule.name
        listen                      = authorisation_rule.listen
        send                        = authorisation_rule.send
        manage                      = authorisation_rule.manage
      }
    ]
  ])

  event_hub_to_auth_rule_mapping = { for event_hub in local.event_hubs : "${event_hub.event_hub_key}.${event_hub.authorisation_rule_key}" => event_hub }
}

resource "azurerm_eventhub_namespace" "namespace" {
  name                = module.naming.eventhub_namespace.name_unique
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  sku                 = var.sku
  capacity            = var.capacity
}

resource "azurerm_eventhub" "eventhubs" {
  for_each            = local.event_hub_to_auth_rule_mapping
  resource_group_name = var.resource_group_name
  name                = each.value.event_hub_name
  namespace_name      = azurerm_eventhub_namespace.namespace.name
  partition_count     = each.value.event_hub_partition_count
  message_retention   = each.value.event_hub_message_retention
}

resource "azurerm_eventhub_authorization_rule" "authorisation_rule" {
  for_each            = local.event_hub_to_auth_rule_mapping
  resource_group_name = var.resource_group_name
  name                = each.value.authorisation_rule_name
  namespace_name      = azurerm_eventhub_namespace.namespace.name
  eventhub_name       = each.value.event_hub_name
  listen              = each.value.listen
  send                = each.value.send
  manage              = each.value.manage

  depends_on = [azurerm_eventhub.eventhubs]
}
