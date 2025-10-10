variable "location" {
  description = "The Azure location to deploy resources into."
  type        = string
}

variable "subscription_id" {
  description = "The Azure platform subscription ID to deploy resources into."
  type        = string
}

variable "core_management_group_id" {
  description = "Desired ID of the top-level management group (under Tenant Root)."
  type        = string
}

variable "core_management_group_display_name" {
  description = "Desired display name of the top-level management group (under Tenant Root)."
  type        = string
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

variable "github_config" {
  description = "A map of Github settings."
  type        = map(string)
  default     = {}
}
