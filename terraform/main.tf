terraform {
  backend "gcs" {
    bucket      = "canto-validator-infra-bucket-tfstate"
    prefix      = "terraform/state"
    credentials = "../terraform-service-key.json"
  }
}

provider "google" {
  project     = var.project
  credentials = file(var.credentials)
  region      = var.region
  zone        = var.zone
}

resource "google_storage_bucket" "default" {
  name          = "canto-validator-infra-bucket-tfstate"
  force_destroy = false
  location      = "US"
  storage_class = "STANDARD"
  versioning {
    enabled = true
  }
}

module "gce_worker_container" {
  for_each        = toset(local.all_nodes)
  source          = "./gce-with-container"
  image           = "gcr.io/${var.project}/${local.image_name}:${var.image_tag}"
  privileged_mode = true
  activate_tty    = true
  machine_type    = var.machine_type
  prefix          = local.prefix
  env_variables = {
    BOOTSTRAP         = "true"
    STATE_SYNC_ENABLE = "true"
    # TODO: make it dynamic
    TRUST_HEIGHT            = 1895000
    TRUST_HASH              = "e03a1b6455da75269576ee3c31ccbf419c2f6408ad68bbb37e07898d4d2d3d77"
    MINIMUM_GAS_PRICES      = "0.0001acanto"
    CHAIN_ID                = local.chain_id
    PERSISTENT_PEERS        = "16ca056442ffcfe509cee9be37817370599dcee1@147.182.255.149:26656,16ca056442ffcfe509cee9be37817370599dcee1@147.182.255.149:26656"
    RPC_SERVERS             = "147.182.255.149:26657,147.182.255.149:26657"
    ADDITIONAL_DEPENDENCIES = "jq tmux vim"
    TENDERMINT_KEYFILE      = contains(var.validator_nodes, each.key) ? replace(data.google_secret_manager_secret_version.tendermint_keyfile[each.key].secret_data, "\n", "\\n") : ""
    PASSPHRASE              = contains(var.validator_nodes, each.key) ? data.google_secret_manager_secret_version.passphrase[each.key].secret_data : ""
    PRIV_VALIDATOR_KEY      = contains(var.validator_nodes, each.key) ? replace(data.google_secret_manager_secret_version.priv_validator_key[each.key].secret_data, "\n", "\\n") : ""
    API                     = contains(var.full_nodes, each.key) ? "true" : "false"
    UNSAFE_CORS             = contains(var.full_nodes, each.key) ? "true" : "false"
    API_PORT                = var.tendermint_api_port
    P2P_PORT                = var.tendermint_p2p_port
    RPC_PORT                = var.tendermint_rpc_port
  }
  instance_name        = "${each.key}-${var.environment}"
  network_name         = "default"
  create_firewall_rule = var.create_firewall_rule
  vm_tags              = contains(var.validator_nodes, each.key) ? var.validators_vm_tags : var.nodes_vm_tags
  # This has the permission to download images from Container Registry
  client_email = var.client_email
  ssh_keys     = var.ssh_keys
}
