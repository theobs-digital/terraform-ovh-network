output "network_id" {
  description = "ID of the test network, to find it if a run leaves it behind."
  value       = module.network.network.id
}

output "gateway_id" {
  description = "ID of the test gateway, to find it if a run leaves it behind."
  value       = module.network.gateways["tf-test-ci"].id
}
