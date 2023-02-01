#!/bin/bash
curl -fsSL "https://aptos.dev/scripts/install_cli.py" | python3
export PATH="/root/.local/bin:$PATH"
aptos --help