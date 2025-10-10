# Variables for the module.

variable "location" {
  description = "Target location for resources."
  type    = string
}

variable "workload_name" {
  description = "Name of workload."
  type = string
}

variable "naming" {
  description = "Map of naming conventions used for resources."
  type = map(string)
}

variable "tags" {
  description = "Map of key/value pairs used for resource tagging."
  type = map(string)
}

variable "vnet_space" {
  type = string
}

variable "subnet_space" {
  type = string
}