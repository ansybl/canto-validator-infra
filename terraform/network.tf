resource "google_compute_address" "static" {
  for_each = toset(var.full_nodes)
  name     = "${local.prefix}-ipv4-address-${each.key}-${var.environment}"
}

resource "google_compute_firewall" "web" {
  name          = "${local.prefix}-firewall-tag-web-${var.environment}"
  description   = "Ingress to allow Tendermint ports 80 and 443 to machines with the 'web' tag"
  network       = "default"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web"]

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
}
