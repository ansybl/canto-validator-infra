# TODO: ideally a `google_cloud_run_service` with a nginx image
resource "google_compute_instance" "reverse_proxy" {
  for_each     = var.create_reverse_proxy ? toset(var.full_nodes) : []
  name         = "${local.prefix}-reverse-proxy-${each.key}-${var.environment}"
  machine_type = "e2-micro"
  tags         = ["web"]
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11-bullseye-v20221102"
    }
  }
  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.static[each.key].address
    }
  }

  metadata = {
    ssh-keys = join("\n", [for user, key in var.ssh_keys : "${user}:${key}"])
  }

  metadata_startup_script = <<EOT
apt update
apt --yes install nginx
mkdir -p /etc/letsencrypt/{archive,live}/${each.key}${var.node_domain_suffix}
echo '${contains(var.full_nodes, each.key) ? data.google_secret_manager_secret_version.cert_fullchain[each.key].secret_data : ""}' > /etc/letsencrypt/archive/${each.key}${var.node_domain_suffix}/fullchain.pem
echo '${contains(var.full_nodes, each.key) ? data.google_secret_manager_secret_version.cert_key[each.key].secret_data : ""}' > /etc/letsencrypt/archive/${each.key}${var.node_domain_suffix}/privkey.pem
ln -sfn /etc/letsencrypt/archive/${each.key}${var.node_domain_suffix}/fullchain.pem /etc/letsencrypt/live/${each.key}${var.node_domain_suffix}/
ln -sfn /etc/letsencrypt/archive/${each.key}${var.node_domain_suffix}/privkey.pem /etc/letsencrypt/live/${each.key}${var.node_domain_suffix}/
# TODO: use terraform templating
echo 'server {
    listen      80 default_server;
    listen      [::]:80 default_server;
    listen      443 ssl http2 default_server;
    listen      [::]:443 ssl http2 default_server;
    ssl_certificate "/etc/letsencrypt/live/${each.key}${var.node_domain_suffix}/fullchain.pem";
    ssl_certificate_key "/etc/letsencrypt/live/${each.key}${var.node_domain_suffix}/privkey.pem";
    ssl_session_cache shared:SSL:1m;
    ssl_session_timeout  10m;

    proxy_redirect      off;
    proxy_set_header    X-Real-IP $remote_addr;
    proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header    Host $http_host;

    location / {
        proxy_pass http://${module.gce_worker_container[each.key].google_compute_instance_ip}:${var.tendermint_api_port};
    }
}' > /etc/nginx/sites-available/default
systemctl restart nginx
EOT
}
