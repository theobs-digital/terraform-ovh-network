###############################################################################
# Global Controls
###############################################################################

variable "create_network" {
  description = "If true, create a new OVH private network."
  type        = bool
  default     = true
}

variable "create_subnet" {
  description = "If true, create subnets for the private network."
  type        = bool
  default     = true
}

variable "create_gateway" {
  description = "If true, create one gateway per subnet."
  type        = bool
  default     = false
}

variable "service_name" {
  description = "The OVHcloud Project service name."
  type        = string
}

###############################################################################
# Network Variables
###############################################################################

variable "network_name" {
  description = "Name of the private network. If null, an automatic name is generated."
  type        = string
  default     = null

  validation {
    condition     = var.network_name == null || length(var.network_name) > 0
    error_message = "If provided, network_name must not be an empty string."
  }
}

variable "network_region" {
  description = "List of regions where the network will be available."
  type        = list(string)
  default     = null

  validation {
    condition     = var.network_region == null || length(var.network_region) > 0
    error_message = "network_region must not be an empty list."
  }
}

variable "network_vlan_id" {
  description = "The VLAN ID of the network. Must be greater than zero."
  type        = number

  validation {
    condition     = var.network_vlan_id > 0
    error_message = "network_vlan_id must be greater than 0."
  }
}

###############################################################################
# Subnet Variables
###############################################################################

variable "subnets" {
  description = "List of subnets to create in the private network."
  type = list(object({
    region        = string
    cidr          = string
    start_ip      = string
    end_ip        = string
    dhcp_enabled  = bool
    no_gateway    = bool
  }))

  validation {
    condition = alltrue([
      for s in var.subnets :
        can(cidrnetmask(s.cidr)) &&
        length(s.region) > 0 &&
        length(s.start_ip) > 0 &&
        length(s.end_ip) > 0
    ])
    error_message = "Each subnet must define a valid CIDR, region, start_ip and end_ip."
  }
}

###############################################################################
# Gateway Variables
###############################################################################

variable "gateways" {
  description = "List of gateways. One gateway per subnet when create_gateway = true."
  type = list(object({
    region = string
    name  = optional(string)
    model = optional(string)
  }))
  default = []
  validation {
    condition = alltrue([
      for g in var.gateways :
        length(g.name)  > 0 &&
        length(g.model) > 0 &&
        length(g.region) > 0
    ])
    error_message = "Each gateway must have a non-empty name and model."
  }
}
