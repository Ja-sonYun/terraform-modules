variable "account_id" {
  type = string
}

variable "tunnel_name" {
  type = string
}

variable "zone_id" {
  type = string
}

variable "subdomains" {
  type = list(string)
}

variable "domain" {
  type = string
}

variable "allow_overwrite_dns" {
  type    = bool
  default = true
}

variable "store_example" {
  type = string
}
