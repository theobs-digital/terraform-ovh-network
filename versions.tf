terraform {
  # 1.3: optional object attributes.
  required_version = ">= 1.3"

  required_providers {
    ovh = {
      source = "ovh/ovh"
      # 2.5.0: the regions_openstack_ids attribute of ovh_cloud_project_network_private.
      version = "~> 2.5"
    }
    # null_resource carries the preconditions.
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}
