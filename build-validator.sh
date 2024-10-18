#!/bin/bash
export TAG=$1
cd /solana/jito-solana
git checkout tags/$TAG
git submodule update --init --recursive
CI_COMMIT=$(git rev-parse HEAD) scripts/cargo-install-all.sh --validator-only ~/.local/share/solana/install/releases/"$TAG"

cd /solana/yellowstone-grpc
git pull
git checkout $2
cargo build --release