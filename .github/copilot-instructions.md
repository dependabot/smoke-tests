# Copilot Instructions for dependabot/smoke-tests

## Repository Overview

This repo contains smoke tests for Dependabot. Each test is a YAML file in `tests/` that records the expected inputs and outputs of a Dependabot CLI run against manifest files in this repo.

## Setup

Before running or regenerating any smoke tests, you must:

1. **Install the Dependabot CLI** by running `go install github.com/dependabot/cli/cmd/dependabot@latest`. This installs the latest released version onto your `$PATH`. Requires Go to be installed.

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

### Graph Tests

Graph tests exercise the dependency graph submission command rather than the update command:

- Use `command: graph` in the job input (default is `update`).
- Output a `create_dependency_submission` entry (not `create_pull_request`) followed by `mark_as_processed`.
- Graph tests do **not** include `record_ecosystem_meta` entries.
- Use separate manifest directories suffixed with `-graph` (e.g., `pipenv-graph/`, `poetry-graph/`) so the manifest can differ from the one used by the update test.
- Choose manifests with transitive dependencies to produce a meaningful dependency tree.

### Package Manager Names

The `package-manager` field in test YAML uses internal Dependabot names, which don't always match the ecosystem directory name (e.g., pipenv and poetry both use `pip`). The canonical mapping is defined in [`updater/lib/github_api/ecosystem_mapper.rb`](https://github.com/dependabot/dependabot-core/blob/main/updater/lib/github_api/ecosystem_mapper.rb) in dependabot-core.

## Creating a New Smoke Test

1. Create a manifest directory at the repo root (e.g., `my-ecosystem/`) with the necessary manifest and lock files.
2. **Push the manifest files to the remote** — the test references the repo by commit SHA, so the Dependabot CLI clones from GitHub and the manifests must exist at that commit.
3. Create a skeleton test YAML in `tests/` with the `input` section filled in and an empty `output` section.
4. Run `script/regen.sh tests/smoke-<name>.yaml` to populate the expected output.
5. Validate with `script/run-one.sh tests/smoke-<name>.yaml`.

## Troubleshooting TLS

If you see errors like `Cannot handshake client`, `CAfile: none`, or `server certificate verification failed` when running smoke tests, make sure you have run both setup steps above. The `--proxy-cert` flag passes the mkcert CA to the Dependabot proxy so it can verify the infrastructure's MITM certificates on outbound connections.
