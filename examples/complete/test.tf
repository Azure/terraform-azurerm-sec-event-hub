provider "azurerm" {
  version = "~>2.0"
  features {}
}

module "terraform-azurerm-naming" {
  source = "git@github.com:Azure/terraform-azurerm-naming"
}

resource "random_string" "resource_group_name_suffix" {
  length    = 5
  special   = false
  lower     = true
  min_lower = 5
}

resource "azurerm_resource_group" "test_group" {
  name     = "${module.terraform-azurerm-naming.resource_group.slug}-${module.terraform-azurerm-naming.event_hub.slug}-minimal-test-${random_string.resource_group_name_suffix.result}"
  location = "uksouth"
}

module "terraform-azurerm-event-hub" {
  source              = "../"
  resource_group_name = azurerm_resource_group.test_group.name
  prefix              = [random_string.resource_group_name_suffix.result]
  suffix              = [random_string.resource_group_name_suffix.result]
  sku                 = "Basic"
  capacity            = "2"
  event_hubs = {
    "eh-test" = {
      name              = "${module.terraform-azurerm-naming.event_hub.slug}-${random_string.resource_group_name_suffix.result}"
      partition_count   = 1
      message_retention = 1
      authorisation_rules = {
        "ehra-default" = {
          name   = "${module.terraform-azurerm-naming.event_hub_authorization_rule.slug}-${random_string.resource_group_name_suffix.result}"
          listen = true
          send   = false
          manage = false
        }
      }
    }
  }
}
