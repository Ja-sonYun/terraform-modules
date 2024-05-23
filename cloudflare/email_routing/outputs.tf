output "dns" {
  description = "DNS of email routing"
  value = {
    name  = var.domain
    type  = "TXT"
    value = "v=spf1 include:_spf.mx.cloudflare.net ~all"
  }
}
