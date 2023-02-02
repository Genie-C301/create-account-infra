#!/bin/bash
aptos key generate --output-file $PWD/new-key.json
aptos init --network devnet --private-key-file $PWD/new-key.json
PUBKEY=$(aptos account lookup-address | jq -r '.Result')

cat << EOF > $PWD/genie_account/Move.toml
[package]
name = "genie_account"
version = "1.0.0"

[dependencies]
AptosFramework = { local = "../framework/aptos-framework" }
MoveStdlib = { local = "../framework/move-stdlib"}
AptosStdlib = {local = "../framework/aptos-stdlib"}
AptosToken = { local = "../framework/aptos-token" }

[addresses]
std = "0x1"
aptos_framework = "0x1"
genie_account = "$PUBKEY"
EOF


PROFILE=$(aptos account create-resource-account --assume-yes --seed 3020 | jq -r '.Result | .resource_account')
aptos account fund-with-faucet --account $PROFILE
aptos move publish --named-addresses source_addr=$PUBKEY,genie=$PROFILE --package-dir $PWD/genie_account --profile default --sender-account=$PROFILE --assume-yes
# aptos move create-resource-account-and-publish-package --seed 3020 --address-name genie --named-addresses source_addr=$PUBKEY --package-dir $PWD/genie_account --profile default --assume-yes


rm -rf ./genie_account/build
rm -rf .aptos
rm -rf new-key.json
rm -rf new-key.json.pub

echo $PROFILE > $PWD/new-profile.txt