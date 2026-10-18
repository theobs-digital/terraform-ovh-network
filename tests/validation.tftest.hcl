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
    terraform_data.validations,
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
    terraform_data.validations,
  ]
}

run "vlan_id_zero_for_no_vlan" {
  command = plan

  variables {
    vlan_id = 0
  }

  assert {
    condition     = ovh_cloud_project_network_private.this[0].vlan_id == 0
    error_message = "vlan_id 0, a network without VLAN, must be accepted."
  }
}

run "vlan_id_up_to_4095" {
  command = plan

  variables {
    vlan_id = 4096
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
