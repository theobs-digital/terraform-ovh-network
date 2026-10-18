###############################################################################
# Network Outputs
###############################################################################

output "network" {
  description = "Information about the created OVH private network."
  value = local.create_network ? {
    id                    = ovh_cloud_project_network_private.this[0].id
    name                  = local.network_name
    regions               = ovh_cloud_project_network_private.this[0].regions
    regions_openstack_ids = ovh_cloud_project_network_private.this[0].regions_openstack_ids
  } : null
}

###############################################################################
# Subnet Outputs
###############################################################################

output "subnets" {
  description = "Map of subnets indexed by their key in `subnets`, containing all attributes."
  value = {
    for key, s in ovh_cloud_project_network_private_subnet.this :
    key => {
      id         = s.id
      cidr       = s.network
      start_ip   = s.start
      end_ip     = s.end
      dhcp       = s.dhcp
      no_gateway = s.no_gateway
    }
  }
}

###############################################################################
# Gateway Outputs
###############################################################################

output "gateways" {
  description = "Map of gateways indexed by their key in `gateways`, containing all attributes."
  value = {
    for key, g in ovh_cloud_project_gateway.this :
    key => {
      id         = g.id
      name       = g.name
      model      = g.model
      region     = g.region
      subnet_id  = g.subnet_id
      network_id = g.network_id
    }
  }
}


###############################################################################
# Summary Output
###############################################################################

output "module_summary" {
  description = "Summary of ids created by this module."
  value = {
    network_id = local.create_network ? ovh_cloud_project_network_private.this[0].id : null
    subnets    = { for key, s in ovh_cloud_project_network_private_subnet.this : key => s.id }
    gateways   = { for key, g in ovh_cloud_project_gateway.this : key => g.id }
  }
}
