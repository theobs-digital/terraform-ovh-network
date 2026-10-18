terraform {
  required_version = ">= 1.4"

  required_providers {
    ovh = {
      source  = "ovh/ovh"
      version = "~> 2.5"
    }
  }
}
