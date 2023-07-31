variable "playbooks" {
  type = list(string)
}

variable "connection" {
  type = object({
    type             = optional(string, "ssh")
    user             = optional(string, "ec2-user")
    host             = string
    private_key_path = string
  })
}

variable "distribution" {
  type = string
}

variable "envs" {
  type = map(string)
}
