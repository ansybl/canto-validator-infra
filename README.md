# Canto Validator Infra

Automates Canto validadors, full nodes and sentry nodes deployment.

- <https://canto-testnet.ansybl.io/rpc/status>

Full nodes endpoints:

- /api/
- /rpc/
- /evm_rpc/

## Architecture

Full nodes:

![full nodes](https://github.com/ansybl/canto-validator-infra/raw/main/diagrams/full_nodes.png)

Validators:

![validators](https://github.com/ansybl/canto-validator-infra/raw/main/diagrams/validators.png)

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

## Key generation
Deploying a node or a validator requires a set of keys available in Secret Manager and pregenerated via:
```sh
make docker/run/init-keys
```
