provider "azurerm" {
  version = "~>2.0"
  features {}
}

locals {
  unique_name_stub = substr(module.naming.unique-seed, 0, 5)
}

module "naming" {
  source = "git::https://github.com/Azure/terraform-azurerm-naming"
}

resource "azurerm_resource_group" "test_group" {
  name     = "${module.naming.resource_group.slug}-${module.naming.event_hub.slug}-max-test-${local.unique_name_stub}"
  location = "uksouth"
}

module "terraform-azurerm-event-hub" {
  source              = "../../"
  resource_group_name = azurerm_resource_group.test_group.name
  prefix              = [local.unique_name_stub]
  suffix              = [local.unique_name_stub]
  sku                 = "Basic"
  capacity            = "2"
  event_hubs = {
    "eh-test" = {
      name              = "${module.naming.event_hub.slug}-${local.unique_name_stub}"
      partition_count   = 1
      message_retention = 1
      authorisation_rules = {
        "ehra-default" = {
          name   = "${module.naming.event_hub_authorization_rule.slug}-${local.unique_name_stub}"
          listen = true
          send   = false
          manage = false
        }
      }
    }
  }
}
