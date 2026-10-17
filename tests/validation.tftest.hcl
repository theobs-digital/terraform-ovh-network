mock_provider "ovh" {}

variables {
  service_name    = "0123456789abcdef0123456789abcdef"
  network_vlan_id = 604
  subnets = [
    { region = "EU-WEST-PAR", cidr = "10.58.0.0/16", start_ip = "10.58.0.2", end_ip = "10.58.0.254", dhcp_enabled = true, no_gateway = false },
    { region = "EU-WEST-GRA", cidr = "10.36.0.0/16", start_ip = "10.36.0.2", end_ip = "10.36.0.254", dhcp_enabled = true, no_gateway = false },
  ]
}

run "subnets_need_the_network" {
  command = plan

  variables {
    create_network = false
  }

  expect_failures = [
    null_resource.validations,
  ]
}

run "one_gateway_per_subnet" {
  command = plan

  variables {
    create_gateway = true
    gateways = [
      { region = "EU-WEST-PAR", name = "gw-par", model = "s" },
    ]
  }

  expect_failures = [
    null_resource.validations,
  ]
}

run "vlan_id_above_zero" {
  command = plan

  variables {
    network_vlan_id = 0
  }

  expect_failures = [
    var.network_vlan_id,
  ]
}

run "network_name_not_empty" {
  command = plan

  variables {
    network_name = ""
  }

  expect_failures = [
    var.network_name,
  ]
}

run "network_region_not_empty" {
  command = plan

  variables {
    network_region = []
  }

  expect_failures = [
    var.network_region,
  ]
}

run "subnet_cidr" {
  command = plan

  variables {
    subnets = [
      { region = "EU-WEST-PAR", cidr = "10.58.0.0", start_ip = "10.58.0.2", end_ip = "10.58.0.254", dhcp_enabled = true, no_gateway = false },
    ]
  }

  expect_failures = [
    var.subnets,
  ]
}

run "gateway_name_not_empty" {
  command = plan

  variables {
    gateways = [
      { region = "EU-WEST-PAR", name = "", model = "s" },
    ]
  }

  expect_failures = [
    var.gateways,
  ]
}
