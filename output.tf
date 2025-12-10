###############################################################################
# Network Outputs
###############################################################################

output "network" {
  description = "Information about the created OVH private network."
  value = local.create_network ? {
    id                    = ovh_cloud_project_network_private.this[0].id
    name                  = local.network_name
    regions               = local.network_regions
    regions_openstack_ids = ovh_cloud_project_network_private.this[0].regions_openstack_ids
  } : null
}

output "network_id" {
  description = "ID of the created OVH private network (or null if not created)."
  value       = local.create_network ? ovh_cloud_project_network_private.this[0].id : null
}


###############################################################################
# Subnet Outputs
###############################################################################

output "subnets" {
  description = "Map of subnets indexed by region, containing all attributes."
  value = {
    for region, s in ovh_cloud_project_network_private_subnet.this :
    region => {
      id         = s.id
      cidr       = s.network
      start_ip   = s.start
      end_ip     = s.end
      dhcp       = s.dhcp
      no_gateway = s.no_gateway
    }
  }
}

output "subnet_ids" {
  description = "Map region => subnet_id."
  value       = { for region, s in ovh_cloud_project_network_private_subnet.this : region => s.id }
}


###############################################################################
# Gateway Outputs
###############################################################################

output "gateways" {
  description = "Map of gateways indexed by region, containing all attributes."
  value = {
    for region, g in ovh_cloud_project_gateway.this :
    region => {
      id        = g.id
      name      = g.name
      model     = g.model
      region    = g.region
      subnet_id = g.subnet_id
      network_id = g.network_id
    }
  }
}

output "gateway_ids" {
  description = "Map region => gateway_id."
  value       = { for region, g in ovh_cloud_project_gateway.this : region => g.id }
}


###############################################################################
# Summary Output
###############################################################################

output "module_summary" {
  description = "Summary of ids created by this module."
  value = {
    network_id = local.create_network ? ovh_cloud_project_network_private.this[0].id : null
    subnets    = { for region, s in ovh_cloud_project_network_private_subnet.this : region => s.id }
    gateways   = { for region, g in ovh_cloud_project_gateway.this : region => g.id }
  }
}
