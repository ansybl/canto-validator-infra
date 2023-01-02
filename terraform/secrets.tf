resource "google_project_service" "secretmanager" {
  provider = google
  service  = "secretmanager.googleapis.com"
}

# imported via:
# cantod keys import main $KEYFILE_PATH
data "google_secret_manager_secret_version" "tendermint_keyfile" {
  for_each   = toset(var.validator_nodes)
  secret     = "${var.prefix}-${each.key}-tendermint-keyfile-${local.environment}"
  version    = "latest"
  depends_on = [google_project_service.secretmanager]
}

data "google_secret_manager_secret_version" "passphrase" {
  for_each   = toset(var.validator_nodes)
  secret     = "${var.prefix}-${each.key}-passphrase-${local.environment}"
  version    = "latest"
  depends_on = [google_project_service.secretmanager]
}

# ~/.$CANTOD_HOME/config/priv_validator_key.json
data "google_secret_manager_secret_version" "priv_validator_key" {
  for_each   = toset(var.validator_nodes)
  secret     = "${var.prefix}-${each.key}-priv-validator-key-${local.environment}"
  version    = "latest"
  depends_on = [google_project_service.secretmanager]
}

# Redeploying the same key to guarantee the same node ID.
# This is useful to have a deterministic persistent_peers (`node-id@sentry-ip:port`) setting.
# This is also useful to know the validator ID to fill the `private_peer_ids` setting.
# ~/.$CANTOD_HOME/config/node_key.json
data "google_secret_manager_secret_version" "node_key" {
  for_each   = toset(concat(var.validator_nodes, var.sentry_nodes))
  secret     = "${var.prefix}-${each.key}-node-key-${local.environment}"
  version    = "latest"
  depends_on = [google_project_service.secretmanager]
}
