output "event_hub_namespace" {
  value = module.terraform-azurerm-event-hub.event_hub_namespace
}

output "event_hubs" {
  value = module.terraform-azurerm-event-hub.event_hubs
}

