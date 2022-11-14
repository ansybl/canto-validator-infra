## Service account variables

variable "credentials" {
  type = string
}

variable "client_email" {
  type = string
}

## Account variables

variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "zone" {
  type = string
}

## validator variables

variable "environment" {
  type    = string
  default = "dev"
}

variable "machine_type" {
  type = string
}

variable "prefix" {
  description = "Prefix to prepend to resource names."
  type        = string
  default     = ""
}

variable "image_tag" {
  type    = string
  default = "latest"
}

variable "ssh_keys" {
  default = {}
}

variable "create_firewall_rule" {
  description = "Create tag-based firewall rule."
  type        = bool
  default     = false
}

variable "vm_tags" {
  description = "Additional network tags for the instances."
  type        = list(string)
  default     = []
}

variable "validator_slugs" {
  type    = list(string)
  default = []
}


# Map the validator to the instance name
# TODO: this is more to demo validator specific setting, but in fact it just changes
# the compute instance name. Later the compute instance name will simply be derived from
# the slug, but validator moniker could be specifically overridden.
variable "validator_slug_to_validator_name_map" {
  type = map(string)
}

variable "default_chain_id" {
  type    = string
  default = "canto_740-1"
}

variable "environment_to_chain_id" {
  type = map(string)
}


locals {
  environment = terraform.workspace
  prefix      = "${var.prefix}-${local.environment}"
  image_name  = "canto-validator-${local.environment}"
  chain_id    = lookup(var.environment_to_chain_id, local.environment, var.default_chain_id)
}
