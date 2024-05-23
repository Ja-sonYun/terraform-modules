terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "> 3.0"
    }
  }
}

resource "cloudflare_record" "dns" {
  count = length(var.dns)

  allow_overwrite = var.allow_overwrite
  zone_id         = var.zone_id
  name            = var.dns[count.index].name
  type            = var.dns[count.index].type
  value           = var.dns[count.index].value
  ttl             = 1
  proxied = contains([
    "A",
    "AAAA",
    "CNAME"
  ], var.dns[count.index].type)
}
