## Service account setup
credentials  = "../terraform-service-key.json"
client_email = "995430163323-compute@developer.gserviceaccount.com"

## Project setup
project = "dfpl-playground"
region  = "us-central1"
zone    = "us-central1-a"

## Validator setup
environment = "dev"
# gcloud compute machine-types list
machine_type    = "e2-standard-4"
prefix          = "canto"
validator_nodes = ["validator1"]
full_nodes      = ["node1", "node2"]
ssh_keys = {
  "andre" = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCXL0+ecc//lAJhiY0YIpKjkHXA7SUv4ouw+29Gps8YYme8fzTn7/gWWO11ALqqqycoJuLn7CBzCRWrUmxn1u2XsEQyaYmfbRKAUktbevHgJtQv2l8OhAmWFhRKvuMA/J5L5jY4FoozC0iQywQWLbC4Vzh7gjwxmqS7PPbamzE6xa45aI4AsxPHN1Ac2tUuuow5ILGC4Vw2bHa/7k5dnwLTGFAIJIXAn4nullC5y4hLQMJPK7NzW+77PKXzEJEye26c98rEbqdzNBnxjz+TH0B6IMZ6GtnmjArCMJPbWfitjBc8Qf/q5X8akoPQqZpkqu/ZB/MXrhfxz400PjZ0yYK710bL+wC0oeEgjlFxfuBPCICSiJqTRVr6O4tkDG3axnqPWKQjUlXkMkQkMjjZy0oZmF1/mffdODuJ6ALicREjKAcS+yOzVcJP9ZqMFHwLhaGLYjCGy//w6q/R2uVm51qEOiWP824ESIFzOQly6Udh1Jeue5JRCaAuZv+6wP4RNO8="
}
create_firewall_rule = true
node_domain_suffix   = ".canto.ansybl.io"
create_reverse_proxy = true

# https://docs.canto.io/evm-development/quickstart-guide
environment_to_chain_id = {
  testnet = "canto_740-1"
  mainnet = "canto_7700-1"
}

trust_height            = 1895000
trust_hash              = "e03a1b6455da75269576ee3c31ccbf419c2f6408ad68bbb37e07898d4d2d3d77"
persistent_peers        = "16ca056442ffcfe509cee9be37817370599dcee1@147.182.255.149:26656,16ca056442ffcfe509cee9be37817370599dcee1@147.182.255.149:26656"
rpc_servers             = "147.182.255.149:26657,147.182.255.149:26657"
additional_dependencies = "jq tmux vim"
