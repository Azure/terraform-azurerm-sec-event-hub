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
  name     = "${module.terraform-azurerm-naming.resource_group.slug}-${module.terraform-azurerm-naming.event_hub.slug}-minimal-test-${random.resource_group_name_suffix.result}"
  location = "uksouth"
}

module "terraform-azurerm-event-hub" {
  source              = "../"
  resource_group_name = azurerm_resource_group.test_group.name
}
