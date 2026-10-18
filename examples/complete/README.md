# Complete example

Creates the private network `backend` on VLAN 604, in `EU-WEST-PAR` and
`GRA9`, with one subnet and one gateway of model `s` in each region.

```bash
export OVH_ENDPOINT=ovh-eu OVH_CLIENT_ID=... OVH_CLIENT_SECRET=...
terraform init
terraform apply -var service_name=<Public Cloud project ID>
```

A gateway uses the network of its region: every region of `gateways` must be
in `regions`.
