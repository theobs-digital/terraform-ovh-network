###############################################################################
# Locals
###############################################################################

locals {
  # Defaults
  network_name = coalesce(var.name, "private-network-${var.vlan_id}")

  create_network = var.create_network

  # Regiions list for subnets uniqueness validation
  subnet_regions = [for s in var.subnets : s.region]

  # Subnet
  create_subnet = var.create_subnet

  # Gateway
  create_gateway = var.create_gateway

}

###############################################################################
# Global validations (toujours exécutées)
###############################################################################

resource "terraform_data" "validations" {
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
  count = local.create_network ? 1 : 0

  service_name = var.service_name
  name         = local.network_name
  regions      = var.regions
  vlan_id      = var.vlan_id
}

###############################################################################
# Subnets
###############################################################################

resource "ovh_cloud_project_network_private_subnet" "this" {
  for_each = (local.create_network && local.create_subnet) ? var.subnets : {}

  service_name = var.service_name
  network_id   = ovh_cloud_project_network_private.this[0].id
  region       = each.value.region
  network      = each.value.network
  start        = each.value.start
  end          = each.value.end
  dhcp         = each.value.dhcp
  no_gateway   = each.value.no_gateway
}

###############################################################################
# Gateways
###############################################################################

resource "ovh_cloud_project_gateway" "this" {
  for_each = (local.create_network && local.create_subnet && local.create_gateway) ? var.gateways : {}

  service_name = var.service_name
  name         = each.value.name
  model        = each.value.model
  region       = each.value.region

  network_id = ovh_cloud_project_network_private.this[0].regions_openstack_ids[each.value.region]

  # The subnet of its region, whatever the keys.
  subnet_id = one([for subnet in ovh_cloud_project_network_private_subnet.this : subnet.id if subnet.region == each.value.region])
}
