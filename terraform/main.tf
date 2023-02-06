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

provider "google-beta" {
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

resource "google_project_service" "cloud_run_api" {
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

module "gce_worker_container" {
  for_each        = { for node in local.all_nodes_with_types : node.slug => node }
  source          = "./gce-with-container"
  image           = "gcr.io/${var.project}/${local.canto_image_name}:${var.image_tag}"
  privileged_mode = true
  activate_tty    = true
  machine_type    = var.machine_types[each.value.type]
  prefix          = var.prefix
  environment     = local.environment
  env_variables = {
    MONIKER                 = each.value.slug
    BOOTSTRAP               = var.bootstrap
    STATE_SYNC_ENABLE       = var.state_sync_enable
    TRUST_HEIGHT            = var.trust_height
    TRUST_HASH              = var.trust_hash
    MINIMUM_GAS_PRICES      = var.minimum_gas_prices
    CHAIN_ID                = local.chain_id
    PERSISTENT_PEERS        = join(",", local.persistent_peers_by_type[each.value.type])
    PRIVATE_PEER_IDS        = join(",", var.private_peer_ids)
    RPC_SERVERS             = join(",", var.rpc_servers)
    ADDITIONAL_DEPENDENCIES = var.additional_dependencies
    TENDERMINT_KEYFILE      = each.value.type == "validator" ? replace(data.google_secret_manager_secret_version.tendermint_keyfile[each.key].secret_data, "\n", "\\n") : ""
    PASSPHRASE              = each.value.type == "validator" ? data.google_secret_manager_secret_version.passphrase[each.key].secret_data : ""
    PRIV_VALIDATOR_KEY      = each.value.type == "validator" ? replace(data.google_secret_manager_secret_version.priv_validator_key[each.key].secret_data, "\n", "\\n") : ""
    NODE_KEY                = contains(["sentry", "validator"], each.value.type) ? replace(data.google_secret_manager_secret_version.node_key[each.key].secret_data, "\n", "\\n") : ""
    PROMETHEUS              = var.enable_tendermint_prometheus
    # Turn this off for the nodes that are on a LAN IP.
    # By default, only nodes with a routable address will be considered for connection.
    # If this setting is turned off, non-routable IP addresses, like addresses in a private network, can be added to the address book.
    ADDR_BOOK_STRICT = contains(["sentry", "validator"], each.value.type) ? false : true
    # disable the peer exchange for validators
    PEX         = each.value.type != "validator"
    API         = each.value.type == "full"
    UNSAFE_CORS = each.value.type == "full"
    API_PORT    = var.tendermint_api_port
    P2P_PORT    = var.tendermint_p2p_port
    RPC_PORT    = var.tendermint_rpc_port
  }
  instance_name = each.value.slug
  network_name  = "default"
  # we often use the internal static IP for unfirewalled communications within the VPC e.g.
  # validators to sentry p2p connection, exposed prometheus metrics...
  create_static_ip        = true
  create_firewall_rule    = var.create_firewall_rule
  tendermint_api_port     = var.tendermint_api_port
  tendermint_p2p_port     = var.tendermint_p2p_port
  tendermint_rpc_port     = var.tendermint_rpc_port
  tendermint_evm_rpc_port = var.tendermint_evm_rpc_port
  vm_tags                 = each.value.type == "validator" ? var.validators_vm_tags : var.nodes_vm_tags
  # This has the permission to download images from Container Registry
  client_email = var.client_email
  ssh_keys     = var.ssh_keys
}
