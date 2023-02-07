## Service account setup
credentials  = "../terraform-service-key.json"
client_email = "995430163323-compute@developer.gserviceaccount.com"

## Project setup
project = "dfpl-playground"
region  = "us-east5"
zone    = "us-east5-a"

## Validator setup
# gcloud compute machine-types list
machine_types = {
  validator = "e2-standard-2"
  full      = "e2-standard-2"
  sentry    = "e2-standard-2"
}
prefix          = "canto-validator"
validator_nodes = ["validator1"]
full_nodes      = ["node1"]
sentry_nodes    = ["sentry1", "sentry2"]
ssh_keys = {
  "andre" = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCXL0+ecc//lAJhiY0YIpKjkHXA7SUv4ouw+29Gps8YYme8fzTn7/gWWO11ALqqqycoJuLn7CBzCRWrUmxn1u2XsEQyaYmfbRKAUktbevHgJtQv2l8OhAmWFhRKvuMA/J5L5jY4FoozC0iQywQWLbC4Vzh7gjwxmqS7PPbamzE6xa45aI4AsxPHN1Ac2tUuuow5ILGC4Vw2bHa/7k5dnwLTGFAIJIXAn4nullC5y4hLQMJPK7NzW+77PKXzEJEye26c98rEbqdzNBnxjz+TH0B6IMZ6GtnmjArCMJPbWfitjBc8Qf/q5X8akoPQqZpkqu/ZB/MXrhfxz400PjZ0yYK710bL+wC0oeEgjlFxfuBPCICSiJqTRVr6O4tkDG3axnqPWKQjUlXkMkQkMjjZy0oZmF1/mffdODuJ6ALicREjKAcS+yOzVcJP9ZqMFHwLhaGLYjCGy//w6q/R2uVm51qEOiWP824ESIFzOQly6Udh1Jeue5JRCaAuZv+6wP4RNO8="
}
create_firewall_rule         = true
create_reverse_proxy         = true
create_load_balancer         = true
enable_tendermint_prometheus = true

domain_suffix = "ansybl.io"

# https://docs.canto.io/evm-development/quickstart-guide
environment_to_chain_id = {
  testnet = "canto_740-1"
  mainnet = "canto_7700-1"
}

node_to_domain_map = {
  node1 = "canto-testnet"
}

persistent_peers = [
  "16ca056442ffcfe509cee9be37817370599dcee1@147.182.255.149:26656",
  "16ca056442ffcfe509cee9be37817370599dcee1@147.182.255.149:26656",
]
# The validators should only be connected to the sentry nodes.
# We're using the VPC internal IPs so we're not firewalled.
# The validator ports are only open for instances in the same VPC.
validator_persistent_peers = [
  # sentry1
  "4c24b20961a7abb1f1bc7d7ff8acece6584b4fae@10.202.0.27:26656",
  # sentry2
  "bf99d6404680047a65d73c37e98bbfcbf476181f@10.202.0.30:26656",
]
private_peer_ids = [
  # validator1
  "f542db1ecb08243d613c705c43e95521dfee77b9",
]
# Overriding the default to remove p2p since we're going through Sentry nodes
# which will connect via the VPC internal IPs which isn't firewalled.
# Same thing for Prometheus.
validators_vm_tags = []
# TODO: also use our public RPC servers, not only the Plex one
rpc_servers = [
  "147.182.255.149:26657",
  "147.182.255.149:26657",
]
additional_dependencies = "jq tmux vim"
