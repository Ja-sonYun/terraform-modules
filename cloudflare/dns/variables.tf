variable "zone_id" {
  type = string
}

variable "dns" {
  type = list(object({
    name  = string
    type  = string
    value = string
  }))
}

variable "allow_overwrite" {
  type    = bool
  default = true
}
