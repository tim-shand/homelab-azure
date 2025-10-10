#=================================================#
# Platform: Deploying Azure Platform Landing Zone.
#=================================================#

# Deploy resoures via modules.

module "az-con-network-hub" {
  source = "../../modules/az-con-network-hub"
  location = var.location # Get from TFVARS file.
  naming = var.naming # Get from TFVARS file.
  tags = var.tags # Get from TFVARS file.
  vnet_space = "10.50.0.0/22" # Allows 4x /24 subnets.
  subnet_space = "10.50.0.0/24" # Default subnet address space.
}
