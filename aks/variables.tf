variable "aks_name" {
  type    = string
  default = "Green-Hat"
}

variable "location" {
  type    = string
  default = "Korea Central"
}

variable "resource_group_name" {
  type    = string
  default = "Green-Hat"
}

variable "harbor_admin_password" {
  type      = string
  sensitive = true
}