terraform {
  # 1.4: terraform_data, which carries the preconditions.
  required_version = ">= 1.4"

  required_providers {
    ovh = {
      source = "ovh/ovh"
      # 2.5.0: the regions_openstack_ids attribute of ovh_cloud_project_network_private.
      version = "~> 2.5"
    }
  }
}
