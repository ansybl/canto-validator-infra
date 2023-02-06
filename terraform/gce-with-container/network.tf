resource "google_compute_firewall" "allow_tag_tendermint_p2p" {
  count         = var.create_firewall_rule ? 1 : 0
  name          = "${var.prefix}-${local.instance_name}-ingress-tag-p2p-${var.environment}"
  description   = "Ingress to allow Tendermint P2P ports to machines with the 'tendermint-p2p' tag"
  network       = var.network_name
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["tendermint-p2p"]

  allow {
    protocol = "tcp"
    ports    = [var.tendermint_p2p_port]
  }
}

resource "google_compute_firewall" "allow_tag_tendermint_rpc" {
  count         = var.create_firewall_rule ? 1 : 0
  name          = "${var.prefix}-${local.instance_name}-ingress-tag-rpc-${var.environment}"
  description   = "Ingress to allow Tendermint RPC ports to machines with the 'tendermint-rpc' tag"
  network       = var.network_name
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["tendermint-rpc"]

  allow {
    protocol = "tcp"
    ports    = [var.tendermint_rpc_port]
  }
}

resource "google_compute_firewall" "allow_tag_tendermint_api" {
  count         = var.create_firewall_rule ? 1 : 0
  name          = "${var.prefix}-${local.instance_name}-ingress-tag-api-${var.environment}"
  description   = "Ingress to allow Tendermint API ports to machines with the 'tendermint-api' tag"
  network       = var.network_name
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["tendermint-api"]

  allow {
    protocol = "tcp"
    ports    = [var.tendermint_api_port]
  }
}

resource "google_compute_firewall" "allow_tag_tendermint_evm_rpc" {
  count         = var.create_firewall_rule ? 1 : 0
  name          = "${var.prefix}-${local.instance_name}-ingress-tag-evm-rpc-${var.environment}"
  description   = "Ingress to allow Tendermint EVM RPC ports to machines with the 'tendermint-evm-rpc' tag"
  network       = var.network_name
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["tendermint-evm-rpc"]

  allow {
    protocol = "tcp"
    ports    = [var.tendermint_evm_rpc_port]
  }
}

resource "google_compute_firewall" "allow_tag_tendermint_prometheus" {
  count         = var.create_firewall_rule ? 1 : 0
  name          = "${var.prefix}-${local.instance_name}-ingress-tag-prom-${var.environment}"
  description   = "Ingress to allow Tendermint Prometheus port to machines with the 'tendermint-prometheus' tag"
  network       = var.network_name
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["tendermint-prometheus"]

  allow {
    protocol = "tcp"
    ports    = [var.tendermint_prometheus_port]
  }
}

resource "google_compute_address" "static" {
  name = "${var.prefix}-${local.instance_name}-address-${var.environment}"
}

resource "google_compute_address" "static_internal" {
  name         = "${var.prefix}-${local.instance_name}-internal-address-${var.environment}"
  address_type = "INTERNAL"
}
