# Endpoint and credentials come from the OVH_* environment variables.
provider "ovh" {}

module "network" {
  source = "../.."

  service_name = var.service_name
  vlan_id      = 604
  name         = "backend"
  regions      = ["EU-WEST-PAR", "GRA9"]

  create_network = true
  create_subnet  = true
  create_gateway = true

  # One subnet per region, and one gateway per subnet.
  subnets = {
    "EU-WEST-PAR" = {
      region     = "EU-WEST-PAR"
      network    = "10.58.0.0/16"
      start      = "10.58.0.2"
      end        = "10.58.0.254"
      dhcp       = true
      no_gateway = false
    }
    "GRA9" = {
      region     = "GRA9"
      network    = "10.36.0.0/16"
      start      = "10.36.0.2"
      end        = "10.36.0.254"
      dhcp       = true
      no_gateway = false
    }
  }

  gateways = {
    "EU-WEST-PAR" = {
      region = "EU-WEST-PAR"
      name   = "gw-par"
      model  = "s"
    }
    "GRA9" = {
      region = "GRA9"
      name   = "gw-gra"
      model  = "s"
    }
  }
}
