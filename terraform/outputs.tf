output "google_compute_instance_ip" {
  value = values(module.gce_worker_container).*.google_compute_instance_ip
}

output "google_compute_instance_name_ip_map" {
  value = values(module.gce_worker_container).*.google_compute_instance_name_ip_map
}

output "load_balancer_ip" {
  value = module.load_balancer[0].external_ip
}

output "nginx_reverse_proxy_url" {
  value = values(google_cloud_run_service.nginx_reverse_proxy).*.status.0.url
}
