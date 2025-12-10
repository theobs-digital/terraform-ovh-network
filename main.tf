###############################################################################
# Locals
###############################################################################

locals {
  # Defaults
  network_name    = var.network_name != null && length(var.network_name) > 0 ? var.network_name : "private-network-${var.network_vlan_id}"
  network_regions = var.network_region != null && length(var.network_region) > 0 ? var.network_region : ["EU-WEST-PAR"]

  create_network  = var.create_network

  # Regiions list for subnets uniqueness validation
  subnet_regions = [for s in var.subnets : s.region]

  # Subnet
  create_subnet   = var.create_subnet
 
  # Gateway
  create_gateway  = var.create_gateway

  gateways_by_region = local.create_gateway ? {
    for g in try(var.gateways, []) : g.region => g
  } : {}

}

###############################################################################
# Global validations (toujours exécutées)
###############################################################################

resource "null_resource" "validations" {
  lifecycle {
    precondition {
      condition     = !(local.create_subnet || local.create_gateway) || local.create_network
      error_message = "You must enable create_network when create_subnet or create_gateway is true."
    }

    precondition {
      condition     = (!local.create_gateway) || (length(var.subnets) == length(distinct(local.subnet_regions)))
      error_message = "When gateways are enabled, each subnet must have a unique region."
    }

    precondition {
      condition     = (!local.create_gateway) || (length(var.gateways) == length(var.subnets))
      error_message = "When gateways are enabled, the number of gateways must match the number of subnets."
    }
  }
}

###############################################################################
# Network
###############################################################################

resource "ovh_cloud_project_network_private" "this" {
  count        = local.create_network ? 1 : 0

  service_name = var.service_name
  name         = local.network_name
  regions      = local.network_regions
  vlan_id      = var.network_vlan_id
}

###############################################################################
# Subnets
###############################################################################

resource "ovh_cloud_project_network_private_subnet" "this" {
  for_each = (local.create_network && local.create_subnet) ? { for subnet in var.subnets : subnet.region => subnet } : {}

  service_name = var.service_name
  network_id   = ovh_cloud_project_network_private.this[0].id
  region       = each.value.region
  network      = each.value.cidr
  start        = each.value.start_ip
  end          = each.value.end_ip
  dhcp         = each.value.dhcp_enabled
  no_gateway   = each.value.no_gateway
}

###############################################################################
# Gateways
###############################################################################

resource "ovh_cloud_project_gateway" "this" {
  for_each = (local.create_network && local.create_subnet && local.create_gateway) ? local.gateways_by_region : {}

  service_name = var.service_name
  name         = each.value.name
  model        = each.value.model
  region       = each.value.region

  network_id = ovh_cloud_project_network_private.this[0].regions_openstack_ids[each.key]

  subnet_id  = ovh_cloud_project_network_private_subnet.this[each.key].id
}
