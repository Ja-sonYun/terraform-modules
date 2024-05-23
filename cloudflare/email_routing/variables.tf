variable "domain" {
  type = string
}

variable "zone_id" {
  type = string
}

variable "email_routing_map" {
  type = list(object({
    custom_address = string
    destination    = list(string)
  }))
}
