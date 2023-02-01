#!/bin/bash
echo $PWD
ls
aptos key generate --output-file $PWD/new-key.json
aptos init --network devnet --private-key-file $PWD/new-key.json
aptos move publish --named-addresses genie_account=default --assume-yes --package-dir $PWD/genie_account
rm -rf ./genie_account/build
rm -rf .aptos
rm -rf new-key.json
rm -rf new-key.json.pub