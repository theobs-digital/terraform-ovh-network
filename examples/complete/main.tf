# Endpoint and credentials come from the OVH_* environment variables.
provider "ovh" {}

module "network" {
  source = "../.."

  service_name    = var.service_name
  network_vlan_id = 604
  network_name    = "backend"
  network_region  = ["EU-WEST-PAR", "GRA9"]

  create_network = true
  create_subnet  = true
  create_gateway = true

  # One subnet per region, and one gateway per subnet.
  subnets = [
    {
      region       = "EU-WEST-PAR"
      cidr         = "10.58.0.0/16"
      start_ip     = "10.58.0.2"
      end_ip       = "10.58.0.254"
      dhcp_enabled = true
      no_gateway   = false
    },
    {
      region       = "GRA9"
      cidr         = "10.36.0.0/16"
      start_ip     = "10.36.0.2"
      end_ip       = "10.36.0.254"
      dhcp_enabled = true
      no_gateway   = false
    },
  ]

  gateways = [
    {
      region = "EU-WEST-PAR"
      name   = "gw-par"
      model  = "s"
    },
    {
      region = "GRA9"
      name   = "gw-gra"
      model  = "s"
    },
  ]
}
