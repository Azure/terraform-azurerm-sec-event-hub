#Required variables
variable "resource_group_name" {
  type        = string
  description = "The Resource Group name in which to put the Storage Accounts."
}

variable "resource_group_location" {
  type        = string
  description = "The Resource Group location in which to put the Storage Accounts."
}

#Optional variables
variable "prefix" {
  type        = list(string)
  description = "A naming prefix to be used in the creation of unique names for Azure resources."
  default     = []
}

variable "suffix" {
  type        = list(string)
  description = "A naming suffix to be used in the creation of unique names for Azure resources."
  default     = []
}

variable "sku" {
  type        = string
  description = "The Event Hub Namespace SKU, either Standard or Basic"
  default     = "Standard"
}

variable "capacity" {
  type        = number
  description = "The capacity for the Event Hub Namespace, measured in throughput units (1-20)"
  default     = 1
}

variable "event_hubs" {
  type = map(object({
    name              = string
    partition_count   = number
    message_retention = number
    authorisation_rules = map(object({
      name   = string
      listen = bool
      send   = bool
      manage = bool
    }))
  }))
  description = "A complex type that define Azure Event Hubs and their associated Authorisation Rules."
  default = {
    "eh-default" = {
      name              = ""
      partition_count   = 1
      message_retention = 1
      authorisation_rules = {
        "ehra-default" = {
          name   = ""
          listen = true
          send   = false
          manage = false
        }
      }
    }
  }
}





