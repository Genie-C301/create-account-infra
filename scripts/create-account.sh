#!/bin/bash
echo $PWD
ls
/root/.local/bin/aptos key generate --output-file $PWD/new-key.json
/root/.local/bin/aptos init --network devnet --private-key-file $PWD/new-key.json
/root/.local/bin/aptos move publish --named-addresses genie_account=default --assume-yes --package-dir $PWD/genie_account --profile default
rm -rf ./genie_account/build
rm -rf .aptos
rm -rf new-key.json
rm -rf new-key.json.pub