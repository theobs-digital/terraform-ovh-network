output "network" {
  description = "ID, name, regions and OpenStack IDs of the private network."
  value       = module.network.network
}

output "subnets" {
  description = "The subnets, by region."
  value       = module.network.subnets
}

output "gateways" {
  description = "The gateways, by region."
  value       = module.network.gateways
}
