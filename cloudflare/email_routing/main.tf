terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "> 3.0"
    }
  }
}

resource "cloudflare_email_routing_rule" "rule" {
  count   = length(var.email_routing_map)

  zone_id = var.zone_id
  name    = "Email Routing Rule ${var.email_routing_map[count.index].custom_address}"
  enabled = true

  matcher {
    type  = "literal"
    field = "to"
    value = var.email_routing_map[count.index].custom_address
  }

  action {
    type  = "forward"
    value = var.email_routing_map[count.index].destination
  }
}
