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

## Requirements

| | Version | Checked with |
|---|---|---|
| Terraform | `>= 1.3` | 1.3.10 and 1.16.5 |
| Provider [`ovh/ovh`](https://registry.terraform.io/providers/ovh/ovh/latest) | `~> 2.5` | 2.5.0 and 2.22.0 |
| Provider [`hashicorp/null`](https://registry.terraform.io/providers/hashicorp/null/latest) | `~> 3.0` | 3.0.0 and 3.3.2 |

---

## 🇬🇧 Input Variables

### Required variables

| Name | Description |
|----|------------|
| `service_name` | OVHcloud project ID |
| `vlan_id` | Private network VLAN ID |

---

### Optional variables

| Name | Type | Default | Description |
|----|----|----|----|
| `name` | `string` | `private-network-${vlan_id}` | Network name |
| `regions` | `list(string)` | `["EU-WEST-PAR"]` | Network regions |
| `create_network` | `bool` | `true` | Create the network |
| `create_subnet` | `bool` | `true` | Create subnets |
| `create_gateway` | `bool` | `false` | Create gateways |
| `subnets` | `map(object)` | `{}` | Subnet definitions, by a key of your choice |
| `gateways` | `map(object)` | `{}` | Gateway definitions, by a key of your choice |

---

### Subnet Object

| Field | Type | Description |
|----|----|------------|
| `region` | `string` | OVHcloud region |
| `network` | `string` | Subnet CIDR |
| `start` | `string` | First usable IP |
| `end` | `string` | Last usable IP |
| `dhcp` | `bool` | Enable DHCP |
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

### Network + Subnets (no gateway)

```hcl
module "network" {
  source = "git::https://github.com/theobs-digital/terraform-ovh-network.git?ref=v0.1.0"

  service_name = var.service_name
  vlan_id      = 604

  create_network = true
  create_subnet  = true
  create_gateway = false

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
```

### Network + Subnets + Gateway

```hcl
module "network" {
  source = "git::https://github.com/theobs-digital/terraform-ovh-network.git?ref=v0.1.0"

  service_name = var.service_name
  vlan_id      = 604
  regions      = ["EU-WEST-PAR", "GRA9"]

  create_network = true
  create_subnet  = true
  create_gateway = true

  subnets = {
    "EU-WEST-PAR" = {
      region     = "EU-WEST-PAR"
      network    = "10.58.0.0/16"
      start      = "10.58.0.2"
      end        = "10.58.0.254"
      dhcp       = true
      no_gateway = false
    }
    "GRA9" = {
      region     = "GRA9"
      network    = "10.36.0.0/16"
      start      = "10.36.0.2"
      end        = "10.36.0.254"
      dhcp       = true
      no_gateway = false
    }
  }

  gateways = {
    "EU-WEST-PAR" = {
      region = "EU-WEST-PAR"
      name   = "gw-par"
      model  = "s"
    }
    "GRA9" = {
      region = "GRA9"
      name   = "gw-gra"
      model  = "s"
    }
  }
}
```

More in the examples: [basic](examples/basic) and [complete](examples/complete).

## Reference

<!-- BEGIN_TF_DOCS -->
### Resources

The following resources are used by this module:

- [null_resource.validations](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) (resource)
- [ovh_cloud_project_gateway.this](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_gateway) (resource)
- [ovh_cloud_project_network_private.this](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_network_private) (resource)
- [ovh_cloud_project_network_private_subnet.this](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_network_private_subnet) (resource)

### Required Inputs

The following input variables are required:

#### <a name="input_service_name"></a> [service\_name](#input\_service\_name)

Description: The OVHcloud Project service name.

Type: `string`

#### <a name="input_vlan_id"></a> [vlan\_id](#input\_vlan\_id)

Description: The VLAN ID of the network. Must be greater than zero.

Type: `number`

### Optional Inputs

The following input variables are optional (have default values):

#### <a name="input_create_gateway"></a> [create\_gateway](#input\_create\_gateway)

Description: Whether the module creates one gateway per subnet.

Type: `bool`

Default: `false`

#### <a name="input_create_network"></a> [create\_network](#input\_create\_network)

Description: Whether the module creates a new OVH private network.

Type: `bool`

Default: `true`

#### <a name="input_create_subnet"></a> [create\_subnet](#input\_create\_subnet)

Description: Whether the module creates subnets for the private network.

Type: `bool`

Default: `true`

#### <a name="input_gateways"></a> [gateways](#input\_gateways)

Description: Gateways, by a key of your choice. The key only names the gateway in the state: keep it stable, since renaming a key replaces the gateway. One gateway per subnet when `create_gateway = true`, each using the subnet of its region.

Type:

```hcl
map(object({
    region = string
    name   = string
    model  = string
  }))
```

Default: `{}`

#### <a name="input_name"></a> [name](#input\_name)

Description: Name of the private network. If null, an automatic name is generated.

Type: `string`

Default: `null`

#### <a name="input_regions"></a> [regions](#input\_regions)

Description: List of regions where the network will be available.

Type: `list(string)`

Default: `null`

#### <a name="input_subnets"></a> [subnets](#input\_subnets)

Description: Subnets to create in the private network, by a key of your choice. The key only names the subnet in the state: keep it stable, since renaming a key replaces the subnet.

Type:

```hcl
map(object({
    region     = string
    network    = string
    start      = string
    end        = string
    dhcp       = bool
    no_gateway = bool
  }))
```

Default: `{}`

### Outputs

The following outputs are exported:

#### <a name="output_gateways"></a> [gateways](#output\_gateways)

Description: Map of gateways indexed by their key in `gateways`, containing all attributes.

#### <a name="output_module_summary"></a> [module\_summary](#output\_module\_summary)

Description: Summary of ids created by this module.

#### <a name="output_network"></a> [network](#output\_network)

Description: Information about the created OVH private network.

#### <a name="output_subnets"></a> [subnets](#output\_subnets)

Description: Map of subnets indexed by their key in `subnets`, containing all attributes.
<!-- END_TF_DOCS -->
