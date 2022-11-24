#! /bin/sh

# exit script on any error
set -e

write_client_toml() {
    envsubst < "$CANTOD_HOME/config/client.template.toml" > client.toml
}

write_config_toml() {
    envsubst < "$CANTOD_HOME/config/config.template.toml" > config.toml
}

write_app_toml() {
    envsubst < "$CANTOD_HOME/config/app.template.toml" > app.toml
}

import_keys() {
    # non validator would not have these variables set
    if [[ -z "$PRIV_VALIDATOR_KEY" ]]; then
        return
    fi
    KEYFILE_PATH=/tmp/tendermint-keyfile.txt
    echo -e $TENDERMINT_KEYFILE > $KEYFILE_PATH
    cantod keys import main $KEYFILE_PATH <<EOF
$PASSPHRASE
$PASSPHRASE
$PASSPHRASE
EOF
    rm $KEYFILE_PATH
    echo -e $PRIV_VALIDATOR_KEY > $CANTOD_HOME/${PRIV_VALIDATOR_KEY_FILE:-config/priv_validator_key.json}
}

# retrieve and set trust height/height automatically if STATE_SYNC_ENABLE=true and TRUST_HEIGHT=0
set_trusted_block() {
    if [ "$STATE_SYNC_ENABLE" != "true" ] || [ $TRUST_HEIGHT -ne 0 ]; then
        return
    fi
    if [[ -z "$RPC_SERVERS" ]]; then
        echo "can't automatically TRUST_HEIGHT without RPC_SERVERS"
        return
    fi
    RPC_SERVER=$(echo $RPC_SERVERS | cut -d , -f1)
    LATEST_HEIGHT=$(curl -s $RPC_SERVER/block | jq -r .result.block.header.height); \
    TRUST_HEIGHT=$((LATEST_HEIGHT - 2000)); \
    TRUST_HASH=$(curl -s "$RPC_SERVER/block?height=$TRUST_HEIGHT" | jq -r .result.block_id.hash)
    echo -e "LATEST_HEIGHT: $LATEST_HEIGHT\nTRUST_HEIGHT: $TRUST_HEIGHT\nTRUST_HASH: $TRUST_HASH"
}

compare_replace_config() {
    TARGET_FILE=$1
    TEMP_FILE=$2

    if [ ! -f "$TARGET_FILE" ]; then
        echo "no existing file found, creating.."
        mv "$TEMP_FILE" "$TARGET_FILE"
    else
        TARGET_FILE_HASH=$(sha256sum "$TARGET_FILE" | awk '{print $1}')
        TEMP_FILE_HASH=$(sha256sum "$TEMP_FILE" | awk '{print $1}')
        if [ "$TARGET_FILE_HASH" = "$TEMP_FILE_HASH" ]; then
            echo "$TARGET_FILE is up-to-date -- $TARGET_FILE_HASH"
            rm "$TEMP_FILE"
        else
            echo "changes detected, updating.."
            rm "$TARGET_FILE"
            mv "$TEMP_FILE" "$TARGET_FILE"
        fi
    fi

}

download_genesis() {
    rm -f genesis.json
    wget https://raw.githubusercontent.com/Canto-Network/Canto/v4.0.0/Networks/Testnet/genesis.json
}

initialize() {
    NODE_DIR=$1
    BINARY=$2

    if [ $# != 2 ]; then
        echo "expected 2 arguments for initialize"
        exit 1
    fi

    if [ ! -f "$NODE_DIR/config/genesis.json" ]; then
        echo "no existing genesis file found, initializing.."
        $BINARY init "${MONIKER:-nonamenode}" --home="$NODE_DIR" --chain-id="${CHAIN_ID:-canto_740-1}"
        cd "$NODE_DIR/config"
        download_genesis
    fi
}

update_config_files() {
    CONFIG_DIR=$1
    TEMP_DIR="$CONFIG_DIR/temp"

    mkdir -p "$TEMP_DIR" && cd "$TEMP_DIR"

    write_app_toml
    write_client_toml
    write_config_toml

    cd "$CONFIG_DIR"

    compare_replace_config "$CONFIG_DIR/app.toml" "$TEMP_DIR/app.toml"
    compare_replace_config "$CONFIG_DIR/client.toml" "$TEMP_DIR/client.toml"
    compare_replace_config "$CONFIG_DIR/config.toml" "$TEMP_DIR/config.toml"

    rm -rf "$TEMP_DIR"
}

add_system_dependencies() {
    if [[ -z "$1" ]]; then
        return
    fi;
    apk add $@
}

initialize "$CANTOD_HOME" cantod
set_trusted_block
update_config_files "$CANTOD_HOME/config"
import_keys
add_system_dependencies $ADDITIONAL_DEPENDENCIES
cd "$CANTOD_HOME"
exec supervisord --nodaemon --configuration /etc/supervisord.conf
