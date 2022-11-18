output "google_compute_instance_ip" {
  value = values(module.gce_worker_container).*.google_compute_instance_ip
}
