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

variable "nodes_vm_tags" {
  description = "Additional network tags for the nodes instances."
  type        = list(string)
  default     = ["tendermint-p2p", "tendermint-api", "tendermint-rpc"]
}

variable "validators_vm_tags" {
  description = "Additional network tags for the validators instances."
  type        = list(string)
  default     = ["tendermint-p2p"]
}

variable "full_nodes" {
  description = "Slug of the non validator full nodes."
  type        = list(string)
  default     = []
}

variable "validator_nodes" {
  description = "Slug of the nodes that will perform validation."
  type        = list(string)
  default     = []
}

variable "default_chain_id" {
  type    = string
  default = "canto_740-1"
}

variable "environment_to_chain_id" {
  type = map(string)
}

variable "tendermint_p2p_port" {
  description = "Port for interacting with the p2p Tendermint network."
  type        = number
  default     = 26656
}

variable "tendermint_rpc_port" {
  description = "Port Tendermint RPC will listen on."
  type        = number
  default     = 26657
}

variable "tendermint_api_port" {
  description = "Port for interacting with the REST API."
  type        = number
  default     = 1317
}

variable "node_domain_suffix" {
  description = "Used for the certificate, node domain will be <node>.<node_domain_suffix>"
  type        = string
  default     = ""
}

variable "create_reverse_proxy" {
  description = "Setup a reverse proxy in front of the node (useful for getting the REST API over SSL)."
  type        = bool
  default     = false
}

locals {
  environment = terraform.workspace
  prefix      = "${var.prefix}-${local.environment}"
  image_name  = "canto-validator-${local.environment}"
  chain_id    = lookup(var.environment_to_chain_id, local.environment, var.default_chain_id)
  all_nodes   = concat(var.validator_nodes, var.full_nodes)
}
