resource "google_compute_region_network_endpoint_group" "serverless_neg" {
  for_each              = var.create_load_balancer ? toset(var.full_nodes) : []
  project               = var.project
  name                  = "${var.prefix}-neg-${each.key}-${local.environment}"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  cloud_run {
    service = google_cloud_run_service.nginx_reverse_proxy[each.key].name
  }
}

resource "google_compute_url_map" "this" {
  count           = var.create_load_balancer ? 1 : 0
  name            = "${var.prefix}-urlmap-${local.environment}"
  project         = var.project
  default_service = module.load_balancer[0].backend_services[keys(module.load_balancer[0].backend_services)[0]].self_link

  dynamic "host_rule" {
    for_each = var.full_nodes
    content {
      hosts        = ["canto-${host_rule.value}.${var.domain_suffix}"]
      path_matcher = "path-matcher-${host_rule.value}"
    }
  }
  dynamic "path_matcher" {
    for_each = var.full_nodes
    content {
      name            = "path-matcher-${path_matcher.value}"
      default_service = module.load_balancer[0].backend_services[path_matcher.value].id
    }
  }
}

module "load_balancer" {
  count          = var.create_load_balancer ? 1 : 0
  source         = "GoogleCloudPlatform/lb-http/google//modules/serverless_negs"
  version        = "6.3.0"
  project        = var.project
  name           = "${var.prefix}-load-balancer-${local.environment}"
  create_url_map = false
  url_map        = google_compute_url_map.this[0].self_link
  create_address = false
  address        = google_compute_global_address.load_balancer_address.address

  backends = {
    for node in var.full_nodes :
    (node) => {
      description = null
      groups = [
        {
          group = google_compute_region_network_endpoint_group.serverless_neg[node].id
        }
      ]
      enable_cdn              = false
      security_policy         = null
      custom_request_headers  = null
      custom_response_headers = null

      iap_config = {
        enable               = false
        oauth2_client_id     = null
        oauth2_client_secret = null
      }

      log_config = {
        enable      = true
        sample_rate = 0.01
      }
    }
  }
}
