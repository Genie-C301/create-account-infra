#!/bin/bash
aptos key generate --output-file $PWD/new-key.txt --assume-yes
aptos init --network devnet --private-key-file $PWD/new-key.txt
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
sbt = {local = "../sbt"}

[addresses]
std = "0x1"
aptos_framework = "0x1"
genie_account = "$PUBKEY"
mint_nft = "f3e9a4f5e0c60b26c7db99e88e8f5547aa330bac03c3282f493b32f02adae34a"
EOF


PROFILE=$(aptos account create-resource-account --assume-yes --seed 3020 | jq -r '.Result | .resource_account')
aptos account fund-with-faucet --account $PROFILE
aptos move publish --named-addresses source_addr=$PUBKEY,genie=$PROFILE,mint_nft=f3e9a4f5e0c60b26c7db99e88e8f5547aa330bac03c3282f493b32f02adae34a --package-dir $PWD/genie_account --profile default --sender-account=$PROFILE --assume-yes

rm -rf ./genie_account/build
rm -rf .aptos
rm -rf new-key.json.pub

echo $PROFILE > $PWD/new-profile.txt