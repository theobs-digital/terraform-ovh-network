# Real API, not a mock: apply this configuration, plan it again, which must
# show no change, and destroy it. A private network tf-test-ci-network on
# VLAN 4000, in one region, with one subnet and one gateway of model s, which
# is billed while it exists. The test project must be attached to a vRack in
# which VLAN 4000 is free.
#
#   export OVH_ENDPOINT=ovh-eu OVH_APPLICATION_KEY=... OVH_APPLICATION_SECRET=... OVH_CONSUMER_KEY=...
#   export TF_VAR_service_name=... TF_VAR_region=GRA9
#   terraform init
#   terraform apply
#   terraform plan -detailed-exitcode
#   terraform destroy
provider "ovh" {}

module "network" {
  source = "../"

  service_name   = var.service_name
  name           = "tf-test-ci-network"
  regions        = [var.region]
  vlan_id        = 4000
  create_gateway = true

  subnets = {
    tf-test-ci = {
      region     = var.region
      network    = "10.254.0.0/24"
      start      = "10.254.0.2"
      end        = "10.254.0.254"
      dhcp       = true
      no_gateway = false
    }
  }

  gateways = {
    tf-test-ci = { region = var.region, name = "tf-test-ci-network", model = "s" }
  }
}
