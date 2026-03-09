# Copilot Instructions for dependabot/smoke-tests

## Repository Overview

This repo contains smoke tests for Dependabot. Each test is a YAML file in `tests/` that records the expected inputs and outputs of a Dependabot CLI run against manifest files in this repo.

## Setup

Before running or regenerating any smoke tests, you must:

1. **Download the Dependabot CLI** by running `script/download-cli.sh`. This downloads the latest binary to the repo root (it is gitignored). Requires `gh` to be installed and authenticated.

2. **Set up TLS certificates** by running `script/setup-tls.sh`. In sandboxed environments (GitHub Codespaces, GitHub Actions) a TLS-intercepting proxy re-signs all outbound HTTPS traffic with a mkcert CA. This script disables the runc shim's certificate bind mounts so the Dependabot CLI's containers keep their original cert stores. The helper scripts (`script/run-one.sh`, `script/regen.sh`) automatically detect the mkcert CA and pass `--proxy-cert` to the CLI.

Both steps are required every time a new environment is created (e.g. a fresh Codespace or a new CI job).

## Running and Regenerating Tests

- **Run a single test:** `script/run-one.sh tests/smoke-<name>.yaml`
- **Run with cache:** `script/run-one.sh tests/smoke-<name>.yaml --with-cache`
- **Regenerate a test:** `script/regen.sh tests/smoke-<name>.yaml`
- **Regenerate multiple:** `script/regen.sh tests/smoke-a.yaml tests/smoke-b.yaml`

These scripts automatically pass `--proxy-cert` when a mkcert CA is detected.

## Test File Conventions

- Smoke test YAML files live in `tests/` and are named `smoke-<ecosystem>[-variant].yaml`.
- Use 4-space indentation.
- Ignore conditions use the `>` operator to cap versions (allows updates up to and including the specified version).
- A `record_ecosystem_meta` entry follows every `create_pull_request`, `update_pull_request`, or `close_pull_request` output entry.

## Troubleshooting TLS

If you see errors like `Cannot handshake client`, `CAfile: none`, or `server certificate verification failed` when running smoke tests, make sure you have run both setup steps above. The `--proxy-cert` flag passes the mkcert CA to the Dependabot proxy so it can verify the infrastructure's MITM certificates on outbound connections.
