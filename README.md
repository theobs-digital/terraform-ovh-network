# OVHcloud Network Terraform Module
🧠 Design decisions

This module is OVHcloud-focused and intentionally opinionated

Global validations are enforced early to fail fast

The module is designed to be consumed by higher-level composite modules (Redis, Kubernetes, etc.)
---

## 🇬🇧 Description

Terraform module to create and manage an OVHcloud private network, its subnets, and its gateways, with strict validations to prevent any inconsistent configuration.

---

## 🇬🇧 Features

- Creation of an OVHcloud private network  
- Creation of one or more subnets  
- Optional gateway creation (one per subnet / region)  
- Global validations using `precondition`  
- Safe usage of `for_each` (no fragile index-based logic)  
- Optional creation of each component (network / subnet / gateway)  

---

## 🇬🇧 Requirements

- Terraform >= 1.14  
- OVHcloud Terraform Provider  

---

## 🇬🇧 Input Variables

### Required variables

| Name | Description |
|----|------------|
| `service_name` | OVHcloud project ID |
| `network_vlan_id` | Private network VLAN ID |

---

### Optional variables

| Name | Type | Default | Description |
|----|----|----|----|
| `network_name` | `string` | `private-network-${network_vlan_id}` | Network name |
| `network_region` | `list(string)` | `["EU-WEST-PAR"]` | Network regions |
| `create_network` | `bool` | `true` | Create the network |
| `create_subnet` | `bool` | `false` | Create subnets |
| `create_gateway` | `bool` | `false` | Create gateways |
| `subnets` | `list(object)` | `[]` | Subnet definitions |
| `gateways` | `list(object)` | `[]` | Gateway definitions |

---

### Subnet Object

| Field | Type | Description |
|----|----|------------|
| `region` | `string` | OVHcloud region |
| `cidr` | `string` | Subnet CIDR |
| `start_ip` | `string` | First usable IP |
| `end_ip` | `string` | Last usable IP |
| `dhcp_enabled` | `bool` | Enable DHCP |
| `no_gateway` | `bool` | Disable OVH gateway |

---

### Gateway Object

| Field | Type | Description |
|----|----|------------|
| `region` | `string` | OVHcloud region |
| `name` | `string` | Gateway name |
| `model` | `string` | Gateway model |

---

## 🇬🇧 Important Validations

This module enforces the following rules:

1. The network **must be enabled** to create subnets or gateways  
2. Only one subnet per region when gateways are enabled  
3. One gateway per subnet  

Any invalid configuration is blocked at `terraform plan` time.

---

## 🇬🇧  Exemples d’utilisation

### Netowrk + Subnets ( No gateway)

```hcl
module "network" {
  source = "./modules/network"

  service_name    = var.service_name
  network_vlan_id = 604

  create_network = true
  create_subnet  = true
  create_gateway = false

  subnets = [
    {
      region        = "EU-WEST-PAR"
      cidr          = "10.58.0.0/16"
      start_ip      = "10.58.0.2"
      end_ip        = "10.58.0.254"
      dhcp_enabled  = true
      no_gateway    = false
    }
  ]
}
```

### Netowrk + Subnets + Gateway

```hcl
module "network" {
  source = "./modules/network"

  service_name    = var.service_name
  network_vlan_id = 604

  create_network = true
  create_subnet  = true
  create_gateway = true

  subnets = [
    {
      region        = "EU-WEST-PAR"
      cidr          = "10.58.0.0/16"
      start_ip      = "10.58.0.2"
      end_ip        = "10.58.0.254"
      dhcp_enabled  = true
      no_gateway    = false
    },
    {
      region        = "EU-WEST-GRA"
      cidr          = "10.36.0.0/16"
      start_ip      = "10.36.0.2"
      end_ip        = "10.36.0.254"
      dhcp_enabled  = true
      no_gateway    = false
    }
  ]

  gateways = [
    {
      region = "EU-WEST-PAR"
      name   = "gw-par"
      model  = "s"
    },
    {
      region = "EU-WEST-GRA"
      name   = "gw-gra"
      model  = "s"
    }
  ]
}

