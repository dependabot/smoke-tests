# Copilot Instructions for dependabot/smoke-tests

Read the [README](../README.md) for setup instructions, how tests work, and how to run/regenerate them.

## Test File Conventions

- Smoke test YAML files live in `tests/` and are named `smoke-<ecosystem>[-variant].yaml`.
- Use 4-space indentation.
- Ignore conditions use the `>` operator to cap versions (allows updates up to and including the specified version).
- A `record_ecosystem_meta` entry follows every `create_pull_request`, `update_pull_request`, or `close_pull_request` output entry.

## TLS in Sandboxed Environments

In sandboxed environments (e.g. the Copilot coding agent) with TLS interception, run `script/setup-tls.sh` first. After running it, pass `--proxy-cert /home/runner/work/_temp/runtime-logs/mkcert/rootCA.pem` to all `dependabot` commands. If you see errors like `Cannot handshake client`, `CAfile: none`, or `server certificate verification failed`, that script has not been run.
