output "plz_hub_vnet_rg" {
  description = "The name of the hub VNet."
  value = module.plz-con-network-hub.plz_hub_vnet_rg
}

output "plz_hub_vnet_name" {
  description = "The name of the hub VNet."
  value = module.plz-con-network-hub.plz_hub_vnet_name
}
