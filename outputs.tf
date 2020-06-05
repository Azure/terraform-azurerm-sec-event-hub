output "event_hub_namespace" {
  value = azurerm_eventhub_namespace.namespace
}

output "event_hubs" {
  value = azurerm_eventhub.eventhubs
}
