resource "google_project_service" "secretmanager" {
  provider = google
  service  = "secretmanager.googleapis.com"
}

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

data "google_secret_manager_secret_version" "priv_validator_key" {
  for_each   = toset(var.validator_nodes)
  secret     = "${var.prefix}-${each.key}-priv-validator-key-${local.environment}"
  version    = "latest"
  depends_on = [google_project_service.secretmanager]
}
