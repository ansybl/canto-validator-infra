resource "google_compute_global_address" "load_balancer_address" {
  name       = "${var.prefix}-load-balancer-address-${local.environment}"
  ip_version = "IPV4"
}
