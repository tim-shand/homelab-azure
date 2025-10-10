variable "azure_tenant_id" {
  description = "The Azure Tenant ID to deploy resources into."
  type        = string
}

variable "subscription_id" {
  description = "Subscription ID for the target changes."
  type        = string
}

variable "location" {
  description = "The Azure location to deploy resources into."
  type        = string
  default     = "australiaeast"
}

variable "naming" {
  description = "A map of naming parameters to use with resources."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "A map of tags to apply to resources."
  type        = map(string)
  default     = {}
}
