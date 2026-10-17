# Basic example

Creates the private network `private-network-604` on VLAN 604, in
`EU-WEST-PAR`, with one subnet `10.58.0.0/16` and DHCP, without a gateway.

```bash
export OVH_ENDPOINT=ovh-eu OVH_CLIENT_ID=... OVH_CLIENT_SECRET=...
terraform init
terraform apply -var service_name=<Public Cloud project ID>
```

The provider also takes `OVH_APPLICATION_KEY`, `OVH_APPLICATION_SECRET` and
`OVH_CONSUMER_KEY` instead of the OAuth2 client.
