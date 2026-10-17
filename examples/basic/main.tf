# Endpoint and credentials come from the OVH_* environment variables.
provider "ovh" {}

module "network" {
  source = "../.."

  service_name    = var.service_name
  network_vlan_id = 604

  subnets = [
    {
      region       = "EU-WEST-PAR"
      cidr         = "10.58.0.0/16"
      start_ip     = "10.58.0.2"
      end_ip       = "10.58.0.254"
      dhcp_enabled = true
      no_gateway   = false
    },
  ]
}
