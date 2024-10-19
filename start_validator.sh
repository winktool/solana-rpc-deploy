#!/bin/bash

exec /solana/agave/target/release/agave-validator\
        --no-voting\
        --identity /solana/validator_identity.json\
        --accounts /solana/accounts\
        --ledger /solana/ledger\
        --limit-ledger-size\
        --entrypoint entrypoint.mainnet-beta.solana.com:8001\
        --entrypoint entrypoint2.mainnet-beta.solana.com:8001\
        --entrypoint entrypoint3.mainnet-beta.solana.com:8001\
        --entrypoint entrypoint4.mainnet-beta.solana.com:8001\
        --entrypoint entrypoint5.mainnet-beta.solana.com:8001\
        --rpc-port 1100\
        --no-port-check\
        --log /solana/solana-validator.log\
        --snapshots /solana/snapshots\
        --full-rpc-api\
        --private-rpc\
        --maximum-local-snapshot-age 2500\
        --rpc-send-default-max-retries 0\
        --rpc-send-leader-count 7\
        --rpc-threads 32\
        --minimal-snapshot-download-speed 50000000\
        --account-index-exclude-key kinXdEcpDQeHPEuQnqmUgtYykqKGVFq6CeVX5iAHJq6\
        --account-index-exclude-key TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA\
        --account-index-exclude-key TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb\
        --full-snapshot-interval-slots 10000\
        --incremental-snapshot-interval-slots 2000\
        --geyser-plugin-config /solana/yellowstone-grpc/yellowstone-grpc-geyser/config.json