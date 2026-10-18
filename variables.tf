variable "create_network" {
  description = "Whether the module creates a new OVH private network."
  type        = bool
  default     = true
}

variable "create_subnet" {
  description = "Whether the module creates subnets for the private network."
  type        = bool
  default     = true
}

variable "create_gateway" {
  description = "Whether the module creates one gateway per subnet."
  type        = bool
  default     = false
}

variable "service_name" {
  description = "The OVHcloud Project service name."
  type        = string
}

variable "name" {
  description = "Name of the private network. If null, an automatic name is generated."
  type        = string
  default     = null

  # coalesce() takes an empty name for no name: refuse it rather than fall back to private-network-<vlan_id>.
  validation {
    condition     = var.name == null ? true : length(var.name) > 0
    error_message = "If provided, name must not be an empty string."
  }
}

variable "regions" {
  description = "Regions of the network, such as `GRA9`. Left out, the network is in every region, the provider's default."
  type        = list(string)
  default     = null
}

variable "vlan_id" {
  description = "VLAN ID of the network, from 0 to 4095, 0 for no VLAN."
  type        = number

  # Provider 2.22 takes any number; the API takes 0 to 4095, 0 for no VLAN.
  validation {
    condition     = var.vlan_id >= 0 && var.vlan_id <= 4095
    error_message = "vlan_id must be between 0 and 4095."
  }
}

variable "subnets" {
  description = "Subnets to create in the private network, by a key of your choice. The key only names the subnet in the state: keep it stable, since renaming a key replaces the subnet."
  type = map(object({
    region     = string
    network    = string
    start      = string
    end        = string
    dhcp       = bool
    no_gateway = bool
  }))
  default = {}
}

variable "gateways" {
  description = "Gateways, by a key of your choice. The key only names the gateway in the state: keep it stable, since renaming a key replaces the gateway. One gateway per subnet when `create_gateway = true`, each using the subnet of its region."
  type = map(object({
    region = string
    name   = string
    model  = string
  }))
  default = {}
}
