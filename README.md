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
| `network_vlan_id` | Private network VLAN ID |

---

### Optional variables

| Name | Type | Default | Description |
|----|----|----|----|
| `network_name` | `string` | `private-network-${network_vlan_id}` | Network name |
| `network_region` | `list(string)` | `["EU-WEST-PAR"]` | Network regions |
| `create_network` | `bool` | `true` | Create the network |
| `create_subnet` | `bool` | `true` | Create subnets |
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

### Network + Subnets (no gateway)

```hcl
module "network" {
  source = "git::https://github.com/theobs-digital/terraform-ovh-network.git?ref=v0.1.0"

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

### Network + Subnets + Gateway

```hcl
module "network" {
  source = "git::https://github.com/theobs-digital/terraform-ovh-network.git?ref=v0.1.0"

  service_name    = var.service_name
  network_vlan_id = 604
  network_region  = ["EU-WEST-PAR", "GRA9"]

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
      region        = "GRA9"
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
      region = "GRA9"
      name   = "gw-gra"
      model  = "s"
    }
  ]
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

#### <a name="input_network_vlan_id"></a> [network\_vlan\_id](#input\_network\_vlan\_id)

Description: The VLAN ID of the network. Must be greater than zero.

Type: `number`

#### <a name="input_service_name"></a> [service\_name](#input\_service\_name)

Description: The OVHcloud Project service name.

Type: `string`

### Optional Inputs

The following input variables are optional (have default values):

#### <a name="input_create_gateway"></a> [create\_gateway](#input\_create\_gateway)

Description: If true, create one gateway per subnet.

Type: `bool`

Default: `false`

#### <a name="input_create_network"></a> [create\_network](#input\_create\_network)

Description: If true, create a new OVH private network.

Type: `bool`

Default: `true`

#### <a name="input_create_subnet"></a> [create\_subnet](#input\_create\_subnet)

Description: If true, create subnets for the private network.

Type: `bool`

Default: `true`

#### <a name="input_gateways"></a> [gateways](#input\_gateways)

Description: List of gateways. One gateway per subnet when create\_gateway = true.

Type:

```hcl
list(object({
    region = string
    name   = string
    model  = string
  }))
```

Default: `[]`

#### <a name="input_network_name"></a> [network\_name](#input\_network\_name)

Description: Name of the private network. If null, an automatic name is generated.

Type: `string`

Default: `null`

#### <a name="input_network_region"></a> [network\_region](#input\_network\_region)

Description: List of regions where the network will be available.

Type: `list(string)`

Default: `null`

#### <a name="input_subnets"></a> [subnets](#input\_subnets)

Description: List of subnets to create in the private network.

Type:

```hcl
list(object({
    region       = string
    cidr         = string
    start_ip     = string
    end_ip       = string
    dhcp_enabled = bool
    no_gateway   = bool
  }))
```

Default: `[]`

### Outputs

The following outputs are exported:

#### <a name="output_gateways"></a> [gateways](#output\_gateways)

Description: Map of gateways indexed by region, containing all attributes.

#### <a name="output_module_summary"></a> [module\_summary](#output\_module\_summary)

Description: Summary of ids created by this module.

#### <a name="output_network"></a> [network](#output\_network)

Description: Information about the created OVH private network.

#### <a name="output_subnets"></a> [subnets](#output\_subnets)

Description: Map of subnets indexed by region, containing all attributes.
<!-- END_TF_DOCS -->
