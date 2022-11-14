locals {
  # https://www.terraform.io/docs/language/values/locals.html
  instance_name = format("%s-%s", var.instance_name, substr(md5(module.gce-container.container.image), 0, 8))

  env_variables = [for var_name, var_value in var.env_variables : {
    name = var_name
    value = var_value
  }]

  prefix     = var.prefix == "" ? "" : "${var.prefix}-"
}

####################
##### CONTAINER SETUP

module "gce-container" {
  # https://github.com/terraform-google-modules/terraform-google-container-vm
  source = "terraform-google-modules/container-vm/google"
  version = "3.1.0"

  container = {
    image = var.image
    command = var.custom_command
    env = local.env_variables
    securityContext = {
      privileged : var.privileged_mode
    }
    tty : var.activate_tty
  }

  restart_policy = "Always"
}

####################
##### COMPUTE ENGINE

resource "google_compute_instance" "this" {
  name = "${local.prefix}${local.instance_name}"
  machine_type = var.machine_type
  # If true, allows Terraform to stop the instance to update its properties.
  allow_stopping_for_update = true
  tags                      = var.vm_tags

  boot_disk {
    initialize_params {
      image = module.gce-container.source_image
      size = 100
      type = "pd-balanced"
    }
  }

  network_interface {
    network = var.network_name

    access_config {}
  }

  metadata = {
    gce-container-declaration = module.gce-container.metadata_value
    ssh-keys = join("\n", [for user, key in var.ssh_keys : "${user}:${key}"])
  }

  labels = {
    container-vm = module.gce-container.vm_container_label
  }

  service_account {
    email = var.client_email
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}

resource "google_compute_firewall" "allow_tag_tendermint_p2p" {
  count       = var.create_firewall_rule ? 1 : 0
  name        = "${local.prefix}${local.instance_name}-ingress-tag-p2p"
  description = "Ingress to allow Tendermint P2P ports to machines with the 'tendermint-p2p' tag"
  network = var.network_name
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["tendermint-p2p"]

  allow {
    protocol = "tcp"
    ports    = [var.tendermint_p2p_port]
  }
}

resource "google_compute_firewall" "allow_tag_tendermint_rpc" {
  count       = var.create_firewall_rule ? 1 : 0
  name        = "${local.prefix}${local.instance_name}-ingress-tag-rpc"
  description = "Ingress to allow Tendermint RPC ports to machines with the 'tendermint-rpc' tag"
  network = var.network_name
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["tendermint-rpc"]

  allow {
    protocol = "tcp"
    ports    = [var.tendermint_rpc_port]
  }
}
