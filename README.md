<h1 align="center">
    <picture>
        <source media="(prefers-color-scheme: light)" srcset="https://user-images.githubusercontent.com/7659/174594540-5e29e523-396a-465b-9a6e-6cab5b15a568.svg">
        <source media="(prefers-color-scheme: dark)" srcset="https://user-images.githubusercontent.com/7659/174594559-0b3ddaa7-e75b-4f10-9dee-b51431a9fd4c.svg">
        <img src="https://user-images.githubusercontent.com/7659/174594540-5e29e523-396a-465b-9a6e-6cab5b15a568.svg" alt="Dependabot" width="336">
    </picture>
</h1>

This repo contains manifest files for various package managers
and is used to perform end-to-end tests for Dependabot.

## How does this work?

Dependabot CLI has the capability to generate and consume test files.

To generate a test, run `dependabot update go_modules dependabot/smoke-tests -o my-test.yml`. This will create `my-test.yml` containing the inputs you provided, plus some ignore conditions to make the test more reproducible, and also contain the outputs the CLI recorded.

To run the test, run `dependabot test -f my-test.yml`. This will run Dependabot with the inputs provided in the test, and assert the outputs match what was previously recorded.

### Caching

To further aid in reproducibility, the CLI can instruct the Proxy to enable caching with the `--cache tmp/cache` option. Simply pass that along with a path to use for the cache during testing, and the Proxy will dump messages it received there.

If there are already cache files present, the Proxy will use them during the run instead of making a network call. Neat!

### Checking failures

Sometimes a test will fail. To more easily check the difference, use the `-o` option to write the new outputs for an easy diff:

```console
dependabot test -f input.yml -o output.yml
diff input.yml output.yml
```

Or if the file is checked into Git, just overwrite the existing file:

```console
dependabot test -f test.yml -o test.yml
```

### Workflows

This repo has several workflows used to manage the caches that are stored as build artifacts:

- Cache one
  - This allows us to run a single smoke test and cache the results.
- Cache all
  - This runs all of the smoke tests and cache the results, which is useful when a large change happens.
- Smoke
  - This test downloads the cache from the build artifacts before running each test in parallel. This was designed to run after each Pull Request.
- Regenerate Test
  - Regenerates one or more smoke tests and opens a PR with the changes. Supports building a custom updater image from a `dependabot-core` branch or PR. See [Regenerating tests](#regenerating-tests) for details.

To see the percentage of caching on each test, go to the [Smoke tests](https://github.com/dependabot/smoke-tests/actions/workflows/smoke.yml) summary view. If the test has low cache coverage then it is more likely to fail in the future. Rerun the Cache one workflow to recache it, or debug why it is uncachable.

### Regenerating tests

Sometimes after a test has been uncached for a while, it will break because the dependencies have changed, and recaching won't fix it. Also some package-managers seem to get around the caching after a while.

In this case we will need to regenerate the failing test. The preferred approach is the **[Regenerate Test](https://github.com/dependabot/smoke-tests/actions/workflows/regenerate-test.yml)** workflow (see below), but you can also do it locally with `dependabot test -f tests/smoke-bundler.yaml -o tests/smoke-bundler.yaml` then push and recache with the "Cache" workflows.

Where possible try to add additional ignore_conditions and allowed_updates so even when uncached the tests will not fail.

For convenience there's a `script/regen.sh` which will regenerate tests locally.

#### `script/regen.sh` (local)

The `script/regen.sh` script regenerates one or more smoke test files locally. It also supports building and using a custom updater image from a `dependabot-core` checkout or PR, which is useful for contributors who need to regenerate tests against unreleased core changes.

```console
# Basic usage — regenerate with the released CLI
script/regen.sh tests/smoke-bundler.yaml

# Use a pre-built updater image
script/regen.sh --updater-image my-image:latest tests/smoke-bundler.yaml

# Build the updater from a local dependabot-core checkout
script/regen.sh --local-core ../dependabot-core tests/smoke-pip.yaml

# Build the updater from a dependabot-core PR
script/regen.sh --core-pr 12345 tests/smoke-pip.yaml tests/smoke-pip-compile.yaml
```

| Option | Description |
|---|---|
| `--updater-image <image>` | Use a pre-built updater Docker image. |
| `--local-core <path>` | Path to a local `dependabot-core` checkout. The script runs `script/build` inside it to produce the updater image. |
| `--core-pr <number>` | A `dependabot-core` PR number. The script clones the repo, checks out the PR, and builds the updater image. Requires `gh` CLI. |

> **Note:** `--local-core` and `--core-pr` are mutually exclusive with each other and with `--updater-image`.

#### Regenerate Test workflow (CI)

The **Regenerate Test** workflow (`Actions → Regenerate Test`) lets maintainers regenerate smoke tests directly from GitHub Actions without any local setup. It runs the Dependabot CLI, updates the test file(s), and opens a PR with the changes.

**Inputs** (all provided via `workflow_dispatch`):

| Input | Description |
|---|---|
| `test` | Single test name, e.g. `npm`, `bundler`, `go`. Maps to `tests/smoke-<name>.yaml`. |
| `ecosystem` | Regenerate **all** tests for a package-manager, e.g. `npm_and_yarn`, `go_modules`, `pip`. |
| `core-branch` | A `dependabot-core` branch name to build a custom updater image from (for internal branches). |
| `core-pr-number` | A `dependabot-core` PR number to build a custom updater image from (for any PR including forks). |

> **Note:** Provide either `test` or `ecosystem`, not both. Similarly, provide at most one of `core-branch` or `core-pr-number`.

**Examples:**

- **Regenerate a single test:** Set `test` to `bundler` → regenerates `tests/smoke-bundler.yaml`.
- **Regenerate all tests for an ecosystem:** Set `ecosystem` to `npm_and_yarn` → regenerates every test whose `package-manager` is `npm_and_yarn`.
- **Regenerate against a core PR:** Set `test` to `pip-compile` and `core-pr-number` to `12345` → builds the updater image from that PR and regenerates the test with it. This is useful for updating smoke tests *before* a core change merges.

**What it does:**

1. Resolves which test file(s) to regenerate.
2. Installs the Dependabot CLI.
3. If a core branch or PR is provided, checks out `dependabot-core`, builds the updater image for the relevant ecosystem.
4. Downloads the existing proxy cache and runs `dependabot test -f <file> -o <result> --cache=cache` for each test — the same way the Smoke workflow runs.
5. Opens a PR with the regenerated test file(s) for review.

### How to add new tests

To create a new test:

1. Add new manifest files, and push the commit to this repo in a branch
2. Run `dependabot update $ecosystem dependabot/smoke-tests --directory $dir --commit $previous_commit_sha -o tests/smoke-$ecosystem-$testname.yaml` substituting the appropriate values:
   - $ecosystem is the directory name in dependabot-core for the ecosystem
   - $dir is the relative path to the manifest files
   - $previous_commit_sha is the commit SHA that contains the manifest files under test
   - $testname is a descriptive name for the test
3. Commit the resulting test
4. Run the [Cache-One](https://github.com/dependabot/smoke-tests/actions/workflows/cache-one.yml) Workflow to cache the test, so it won't break due to dependency changes before the PR merges 
5. When merging, be sure to make a merge commit, don't squash or rebase! This will change the $previous_commit_sha.

The reason we do it this way is the commit under test is in the API calls in the `output` section. So we must pin the test to a commit or a change to this repo will break all the tests.

Also, the manifests must be pushed up before the test can be run, because Dependabot will attempt to fetch them.

If you are contributing from a fork, perform the steps above replacing `dependabot/smoke-tests` with your fork, and we can do the rest.

### Secrets

To keep secrets out of test files, the CLI can use environment variables instead:

```yaml
credentials:
  - type: npm_registry
    registry: https://npm.pkg.github.com
    token: $MY_TOKEN
```

### ARM64 machines

Since we currently don't produce ARM images, it is recommended you use Codespaces to run and regenerate tests. It runs much faster than emulation!
