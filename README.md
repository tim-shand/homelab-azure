# Home Lab: Azure

Welcome to my personal Azure tenant! :wave:  
- Deployed using a Powershell bootstrap script and managed via Terraform and GitHub Actions.  
- Configured with a simplified, light platform landing zone and personal project workloads.  

## :cloud: Cloud Services

- **Azure**
  - Platform Landing Zone and basic web app services.
- **Cloudflare**
  - Several DNS zones are configured in Cloudflare, used for various personal projects.
- **Github**
  - Housing the project and providing code repository.
  - Github Actions for automation pipelines.

## :hammer_and_wrench: Deployment Tool Set

- **Infrastructre-as-Code (IaC)**
  - **Powershell**
    - Initial Bootstrapping for Service Principal, Terraform remote backend, and various utility/helper scripts.
  - **[Terraform](https://www.terraform.io/)**
    - Provider agnostic IaC tool, free to use, plenty of discussion, guides and support available.
    - Used to provision Azure infrastructre using the [AzureRM](https://registry.terraform.io/providers/hashicorp/azurerm) provider.

## :memo: To Do

- [x] Bootstrap Azure tenant using Powershell script. 
- [ ] Configure and deploy platform landing zone. 
- [ ] Migrate workloads to this code base. 
- [ ] Investigate on-prem connectivity (VPN Gateway?). 
- [ ] Investigate low-cost compute and serverless offerings. 
