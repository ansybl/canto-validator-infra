resource "google_project_service" "secretmanager" {
  provider = google
  service  = "secretmanager.googleapis.com"
}

data "google_secret_manager_secret_version" "mnemonic" {
  for_each   = toset(var.validator_slugs)
  secret     = "${local.prefix}-${each.key}-mnemonic"
  version    = "latest"
  depends_on = [google_project_service.secretmanager]
}

data "google_secret_manager_secret_version" "tendermint_keyfile" {
  for_each   = toset(var.validator_slugs)
  secret     = "${local.prefix}-${each.key}-tendermint-keyfile"
  version    = "latest"
  depends_on = [google_project_service.secretmanager]
}

data "google_secret_manager_secret_version" "passphrase" {
  for_each   = toset(var.validator_slugs)
  secret     = "${local.prefix}-${each.key}-passphrase"
  version    = "latest"
  depends_on = [google_project_service.secretmanager]
}

data "google_secret_manager_secret_version" "priv_validator_key" {
  for_each   = toset(var.validator_slugs)
  secret     = "${local.prefix}-${each.key}-priv-validator-key"
  version    = "latest"
  depends_on = [google_project_service.secretmanager]
}
