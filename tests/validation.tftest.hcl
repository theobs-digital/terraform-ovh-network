mock_provider "ovh" {}

variables {
  service_name = "0123456789abcdef0123456789abcdef"
  vlan_id      = 604
  subnets = {
    "EU-WEST-PAR" = { region = "EU-WEST-PAR", network = "10.58.0.0/16", start = "10.58.0.2", end = "10.58.0.254", dhcp = true, no_gateway = false }
    "EU-WEST-GRA" = { region = "EU-WEST-GRA", network = "10.36.0.0/16", start = "10.36.0.2", end = "10.36.0.254", dhcp = true, no_gateway = false }
  }
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
    gateways = {
      "EU-WEST-PAR" = { region = "EU-WEST-PAR", name = "gw-par", model = "s" }
    }
  }

  expect_failures = [
    null_resource.validations,
  ]
}

run "vlan_id_above_zero" {
  command = plan

  variables {
    vlan_id = 0
  }

  expect_failures = [
    var.vlan_id,
  ]
}

run "network_name_not_empty" {
  command = plan

  variables {
    name = ""
  }

  expect_failures = [
    var.name,
  ]
}

run "network_region_not_empty" {
  command = plan

  variables {
    regions = []
  }

  expect_failures = [
    var.regions,
  ]
}

run "subnet_cidr" {
  command = plan

  variables {
    subnets = {
      "EU-WEST-PAR" = { region = "EU-WEST-PAR", network = "10.58.0.0", start = "10.58.0.2", end = "10.58.0.254", dhcp = true, no_gateway = false }
    }
  }

  expect_failures = [
    var.subnets,
  ]
}

run "gateway_name_not_empty" {
  command = plan

  variables {
    gateways = {
      "EU-WEST-PAR" = { region = "EU-WEST-PAR", name = "", model = "s" }
    }
  }

  expect_failures = [
    var.gateways,
  ]
}
