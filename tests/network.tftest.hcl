mock_provider "ovh" {
  mock_resource "ovh_cloud_project_network_private" {
    defaults = {
      id = "pn-1234567_604"
      regions_openstack_ids = {
        "EU-WEST-PAR" = "0f3a2c1e-5b4d-4e8f-9a7b-6c5d4e3f2a10"
        "EU-WEST-GRA" = "7d6c5b4a-3e2f-4a1b-8c9d-0e1f2a3b4c5d"
      }
    }
  }
}

variables {
  service_name    = "0123456789abcdef0123456789abcdef"
  network_vlan_id = 604
}

run "network_only" {
  variables {
    create_subnet = false
  }

  assert {
    condition     = ovh_cloud_project_network_private.this[0].name == "private-network-604" && ovh_cloud_project_network_private.this[0].vlan_id == 604
    error_message = "Without network_name, the network must be named after its VLAN."
  }

  assert {
    condition     = tolist(ovh_cloud_project_network_private.this[0].regions) == tolist(["EU-WEST-PAR"])
    error_message = "Without network_region, the network must be in EU-WEST-PAR."
  }

  assert {
    condition     = length(ovh_cloud_project_network_private_subnet.this) == 0 && length(ovh_cloud_project_gateway.this) == 0
    error_message = "No subnet and no gateway must be created."
  }

  assert {
    condition     = output.network.id == "pn-1234567_604" && output.module_summary.network_id == "pn-1234567_604"
    error_message = "The outputs must carry the network ID."
  }
}

run "no_network" {
  variables {
    create_network = false
    create_subnet  = false
  }

  assert {
    condition     = length(ovh_cloud_project_network_private.this) == 0 && output.network == null
    error_message = "With create_network = false, no network must be created."
  }
}

run "subnets" {
  variables {
    network_name   = "backend"
    network_region = ["EU-WEST-PAR", "EU-WEST-GRA"]
    subnets = [
      { region = "EU-WEST-PAR", cidr = "10.58.0.0/16", start_ip = "10.58.0.2", end_ip = "10.58.0.254", dhcp_enabled = true, no_gateway = false },
      { region = "EU-WEST-GRA", cidr = "10.36.0.0/16", start_ip = "10.36.0.2", end_ip = "10.36.0.254", dhcp_enabled = false, no_gateway = true },
    ]
  }

  assert {
    condition     = ovh_cloud_project_network_private.this[0].name == "backend"
    error_message = "network_name must name the network."
  }

  assert {
    condition     = keys(ovh_cloud_project_network_private_subnet.this) == ["EU-WEST-GRA", "EU-WEST-PAR"]
    error_message = "The subnets must be keyed by region."
  }

  assert {
    condition = alltrue([
      for s in ovh_cloud_project_network_private_subnet.this : s.network_id == "pn-1234567_604"
    ])
    error_message = "Each subnet must belong to the network."
  }

  assert {
    condition = (
      ovh_cloud_project_network_private_subnet.this["EU-WEST-GRA"].network == "10.36.0.0/16" &&
      ovh_cloud_project_network_private_subnet.this["EU-WEST-GRA"].start == "10.36.0.2" &&
      ovh_cloud_project_network_private_subnet.this["EU-WEST-GRA"].end == "10.36.0.254" &&
      ovh_cloud_project_network_private_subnet.this["EU-WEST-GRA"].dhcp == false &&
      ovh_cloud_project_network_private_subnet.this["EU-WEST-GRA"].no_gateway == true
    )
    error_message = "cidr, start_ip, end_ip, dhcp_enabled and no_gateway must reach the subnet."
  }

  assert {
    condition     = output.subnets["EU-WEST-PAR"].cidr == "10.58.0.0/16" && length(ovh_cloud_project_gateway.this) == 0
    error_message = "The subnets output must list the subnets, and no gateway must be created."
  }
}

run "gateways" {
  variables {
    create_gateway = true
    network_region = ["EU-WEST-PAR", "EU-WEST-GRA"]
    subnets = [
      { region = "EU-WEST-PAR", cidr = "10.58.0.0/16", start_ip = "10.58.0.2", end_ip = "10.58.0.254", dhcp_enabled = true, no_gateway = false },
      { region = "EU-WEST-GRA", cidr = "10.36.0.0/16", start_ip = "10.36.0.2", end_ip = "10.36.0.254", dhcp_enabled = true, no_gateway = false },
    ]
    gateways = [
      { region = "EU-WEST-PAR", name = "gw-par", model = "s" },
      { region = "EU-WEST-GRA", name = "gw-gra", model = "s" },
    ]
  }

  assert {
    condition     = ovh_cloud_project_gateway.this["EU-WEST-PAR"].name == "gw-par" && ovh_cloud_project_gateway.this["EU-WEST-PAR"].model == "s"
    error_message = "name and model must reach the gateway."
  }

  assert {
    condition     = ovh_cloud_project_gateway.this["EU-WEST-GRA"].network_id == "7d6c5b4a-3e2f-4a1b-8c9d-0e1f2a3b4c5d"
    error_message = "A gateway must use the OpenStack ID of the network in its region."
  }

  assert {
    condition     = ovh_cloud_project_gateway.this["EU-WEST-GRA"].subnet_id == ovh_cloud_project_network_private_subnet.this["EU-WEST-GRA"].id
    error_message = "A gateway must use the subnet of its region."
  }

  assert {
    condition     = keys(output.module_summary.gateways) == ["EU-WEST-GRA", "EU-WEST-PAR"]
    error_message = "The summary output must list the gateways by region."
  }
}
