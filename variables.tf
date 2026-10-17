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

  validation {
    condition     = var.name == null ? true : length(var.name) > 0
    error_message = "If provided, name must not be an empty string."
  }
}

variable "regions" {
  description = "List of regions where the network will be available."
  type        = list(string)
  default     = null

  validation {
    condition     = var.regions == null ? true : length(var.regions) > 0
    error_message = "regions must not be an empty list."
  }
}

variable "vlan_id" {
  description = "The VLAN ID of the network. Must be greater than zero."
  type        = number

  validation {
    condition     = var.vlan_id > 0
    error_message = "vlan_id must be greater than 0."
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

  validation {
    condition = alltrue([
      for s in var.subnets :
      can(cidrnetmask(s.network)) &&
      length(s.region) > 0 &&
      length(s.start) > 0 &&
      length(s.end) > 0
    ])
    error_message = "Each subnet must define a valid CIDR network, region, start and end."
  }
}

variable "gateways" {
  description = "Gateways, by a key of your choice. The key only names the gateway in the state: keep it stable, since renaming a key replaces the gateway. One gateway per subnet when `create_gateway = true`, each using the subnet of its region."
  type = map(object({
    region = string
    name   = string
    model  = string
  }))
  default = {}
  validation {
    condition = alltrue([
      for g in var.gateways :
      length(g.name) > 0 &&
      length(g.model) > 0 &&
      length(g.region) > 0
    ])
    error_message = "Each gateway must have a non-empty name and model."
  }
}
