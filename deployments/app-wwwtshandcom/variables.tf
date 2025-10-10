variable "subscription_id" {
  description = "Subscription ID for the target changes."
  type        = string
}

variable "location" {
  description = "The Azure location to deploy resources into."
  type        = string
}

variable "management_group" {
  description = "Desired ID of the top-level management group (under Tenant Root)."
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
