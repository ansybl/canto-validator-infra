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
  default     = ["tendermint-p2p", "tendermint-api", "tendermint-rpc", "tendermint-evm-rpc"]
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

variable "sentry_nodes" {
  description = "Slug of the sentry nodes (exposed to the public network)."
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

variable "tendermint_evm_rpc_port" {
  description = "Port for interacting with the EVM RPC server."
  type        = number
  default     = 8545
}

variable "create_reverse_proxy" {
  description = "Setup a reverse proxy in front of the node (useful for getting the REST API over SSL)."
  type        = bool
  default     = false
}

variable "bootstrap" {
  type    = bool
  default = true
}

variable "state_sync_enable" {
  type    = bool
  default = true
}

variable "trust_height" {
  description = "Will be retrieved automatically at run time if state_sync_enable=true and trust_height=0"
  type        = number
  default     = 0
}

variable "trust_hash" {
  description = "Will be retrieved automatically at run time if state_sync_enable=true and trust_height=0"
  type        = string
  default     = ""
}

variable "minimum_gas_prices" {
  type    = string
  default = "0.0001acanto"
}

variable "persistent_peers" {
  description = "Default persistent peers for all the nodes types, format: `nodeid@ip:port`"
  type        = list(string)
}


variable "validator_persistent_peers" {
  description = "Persistent peers for the validator nodes (most likely validators and other sentries)"
  type        = list(string)
  default     = []
}

variable "sentry_persistent_peers" {
  description = "Persistent peers for the Sentry nodes (most likely validators and other sentries)"
  type        = list(string)
  default     = []
}

variable "private_peer_ids" {
  description = "comma-separate list of node id values, that should not be gossiped at all times"
  type        = list(string)
  default     = []
}

variable "rpc_servers" {
  type = string
}

variable "additional_dependencies" {
  type = string
}

variable "create_load_balancer" {
  type    = bool
  default = false
}

variable "domain_suffix" {
  description = "Used for the load balancer host rule (canto-<node-key>.<domain_suffix>)"
  type        = string
  default     = ""
}

variable "node_to_domain_map" {
  description = "Used to map the domain that should be associated to the full node"
  type        = map(string)
  default     = {}
}

locals {
  environment          = terraform.workspace
  canto_image_name     = "canto-validator-${local.environment}"
  nginx_image_name     = "nginx-reverse-proxy-${local.environment}"
  chain_id             = lookup(var.environment_to_chain_id, local.environment, var.default_chain_id)
  all_nodes            = concat(var.validator_nodes, var.full_nodes, var.sentry_nodes)
  validator_nodes      = [for node in var.validator_nodes : { slug = node, type = "validator" }]
  full_nodes           = [for node in var.full_nodes : { slug = node, type = "full" }]
  sentry_nodes         = [for node in var.sentry_nodes : { slug = node, type = "sentry" }]
  all_nodes_with_types = concat(local.validator_nodes, local.full_nodes, local.sentry_nodes)
  persistent_peers_by_type = {
    validator = length(var.validator_persistent_peers) == 0 ? var.persistent_peers : var.validator_persistent_peers
    full      = var.persistent_peers
    sentry    = length(var.sentry_persistent_peers) == 0 ? var.persistent_peers : var.sentry_persistent_peers
  }
}
