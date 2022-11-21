resource "google_cloud_run_service" "nginx_reverse_proxy" {
  for_each = var.create_reverse_proxy ? toset(var.full_nodes) : []
  name     = "${var.prefix}-nginx-reverse-proxy-${each.key}-${local.environment}"
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/${var.project}/${local.nginx_image_name}:${var.image_tag}"
        ports {
          container_port = 80
        }
        env {
          name  = "PROXY_PASS_API_URL"
          value = "http://${module.gce_worker_container[each.key].google_compute_instance_ip}:${var.tendermint_api_port}/"
        }
        env {
          name  = "PROXY_PASS_RPC_URL"
          value = "http://${module.gce_worker_container[each.key].google_compute_instance_ip}:${var.tendermint_rpc_port}/"
        }
        env {
          name  = "PROXY_PASS_EVM_RPC_URL"
          value = "http://${module.gce_worker_container[each.key].google_compute_instance_ip}:${var.tendermint_evm_rpc_port}/"
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [
    google_project_service.cloud_run_api
  ]
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  for_each = var.create_reverse_proxy ? toset(var.full_nodes) : []
  location = google_cloud_run_service.nginx_reverse_proxy[each.key].location
  project  = google_cloud_run_service.nginx_reverse_proxy[each.key].project
  service  = google_cloud_run_service.nginx_reverse_proxy[each.key].name

  policy_data = data.google_iam_policy.noauth.policy_data
}
