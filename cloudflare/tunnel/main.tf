terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "> 3.0"
    }
  }
}

resource "random_id" "tunnel_secret" {
  byte_length = 35
}

resource "cloudflare_argo_tunnel" "tunnel" {
  account_id       = var.account_id
  name             = var.tunnel_name
  secret           = random_id.tunnel_secret.b64_std
}

resource "cloudflare_record" "subdomain" {
  count            = length(var.subdomains)

  allow_overwrite  = var.allow_overwrite_dns
  zone_id          = var.zone_id
  name             = var.subdomains[count.index]
  value            = "${cloudflare_argo_tunnel.tunnel.id}.cfargotunnel.com"
  type             = "CNAME"
  proxied          = true
}

resource "local_file" "tunnel_secret" {
  filename = "${var.store_example}/cert.json"
  content  = jsonencode({
    AccountTag = var.account_id,
    TunnelID   = cloudflare_argo_tunnel.tunnel.id,
    TunnelSecret = random_id.tunnel_secret.b64_std
    TunnelName = var.tunnel_name
  })
}

resource "local_file" "tunnel_config" {
  filename = "${var.store_example}/config.yml"
  content  = <<EOT
tunnel: ${cloudflare_argo_tunnel.tunnel.id}
credentials-file: cert.json
warp-routing:
  enabled: true

# generated subdomains for this tunnel
# ${join(" ", var.subdomains)}

ingress:
  - hostname: subdomain.${var.domain}
    # service: ssh://localhost:22

  - service: http_status:404
EOT
}

resource "local_file" "runner" {
  filename = "${var.store_example}/run.sh"
  content  = <<EOT
#!/bin/bash

cloudflared --config config.yml tunnel run
EOT
}
