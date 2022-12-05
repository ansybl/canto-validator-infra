variable "prefix" {
  description = "Prefix to prepend to resource names."
  type        = string
}

variable "environment" {
  type        = string
}

variable "network_name" {
  type = string
}

variable "vm_tags" {
  description = "Additional network tags for the instances."
  type = list(string)
  default     = []
}

variable "create_firewall_rule" {
  description = "Create tag-based firewall rule."
  type        = bool
  default     = false
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

variable "create_static_ip" {
  description = "Create a static IP"
  type        = bool
  default     = false
}

variable "instance_name" {
  description = "The desired name to assign to the deployed instance"
  default = "disk-instance-vm-test"
}

variable "image" {
  description = "The Docker image to deploy to GCE instances"
}

variable "env_variables" {
  type = map(string)
  default = null
}

variable "privileged_mode" {
  type = bool
  default = false
}

# gcloud compute machine-types list | grep micro | grep us-central1-a
# e2-micro / 2 / 1.00
# f1-micro / 1 / 0.60
# gcloud compute machine-types list | grep small | grep us-central1-a
# e2-small / 2 / 2.00
# g1-small / 1 / 1.70
variable "machine_type" {
  type = string
  default = "f1-micro"
}

variable "ssh_keys" {
  default = {}
}

variable "activate_tty" {
  type = bool
  default = false
}

variable "custom_command" {
  type = list(string)
  default = null
}

variable "additional_metadata" {
  type = map(string)
  description = "Additional metadata to attach to the instance"
  default = null
}

variable "client_email" {
  description = "Service account email address"
  type = string
  default = null
}
