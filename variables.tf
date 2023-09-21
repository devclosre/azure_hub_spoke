variable "target_region" {
  type        = string
  default     = "Australia East"
  description = "Which region does these resources belong to"
}

variable "client" {
  type        = string
  default     = "WW"
  description = "Name of our Client"
}

variable "department" {
  type        = string
  default     = "RTL"
  description = "Which domain does these resources belong to"
}

variable "env" {
  type        = string
  default     = "DEV"
  description = "Which env does these resources belong to"
}

/* variable "vnet_cidr" {
  type        = string
  default     = "10.10.0.0/16"
  description = "CIDR of Hub Vnet"
} */

/*
variable "vnet_spoke_cidr" {
  type        = string
  default     = "10.20.0.0/16"
  description = "CIDR of Spoke Vnet"
} */

/*
variable "subnets_name_tag" {
    type        = list(string)
    default     = [ "web1", "web2", "app1", "app2", "db1", "db2" ]
    description = "Name tags of subnets"
}
*/