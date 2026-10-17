# Endpoint and credentials come from the OVH_* environment variables.
provider "ovh" {}

module "network" {
  source = "../.."

  service_name = var.service_name
  vlan_id      = 604

  subnets = {
    "EU-WEST-PAR" = {
      region     = "EU-WEST-PAR"
      network    = "10.58.0.0/16"
      start      = "10.58.0.2"
      end        = "10.58.0.254"
      dhcp       = true
      no_gateway = false
    }
  }
}
