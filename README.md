# Canto Validator Infra

Automates Canto validador deployment.

## Warning
Redeploying a validation could be subject to double signing old blocks as the validator resyncs with the chain hence be subject to slashing/jailing.
Further investigations would be required to make sure the validator doesn't start signing until it's fully synced.

## Use
```sh
export WORKSPACE=testnet
make docker/build
make docker/login
make docker/push
make devops/terraform/plan
make devops/terraform/apply
```
We leverage [Terraform workspaces](https://developer.hashicorp.com/terraform/language/state/workspaces) to handle state data instance separation.
In our setup the `WORKSPACE` matches with the network (e.g. `testnet`, `mainnet`), but can also be used to stand up a dedicated dev instance (e.g. `testnet-andre`).
