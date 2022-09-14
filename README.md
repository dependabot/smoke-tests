<h1 align="center">
    <picture>
        <source media="(prefers-color-scheme: light)" srcset="https://user-images.githubusercontent.com/7659/174594540-5e29e523-396a-465b-9a6e-6cab5b15a568.svg">
        <source media="(prefers-color-scheme: dark)" srcset="https://user-images.githubusercontent.com/7659/174594559-0b3ddaa7-e75b-4f10-9dee-b51431a9fd4c.svg">
        <img src="https://user-images.githubusercontent.com/7659/174594540-5e29e523-396a-465b-9a6e-6cab5b15a568.svg" alt="Dependabot" width="336">
    </picture>
</h1>

This repo contains manifest files for various package managers
and is used to perform end-to-end tests for Dependabot.

You're welcome to use this repo to test Dependabot functionality.
However, we aren't accepting contributions at this time.

## How does this work?

Dependabot CLI has the capability to generate and consume test files. 

To generate a test, run `dependabot update go_modules dependabot/smoke-tests --dry-run -o my-test.yml`. This will create `my-test.yml` containing the inputs you provided, plus some ignore conditions to make the test more reproducable, and also contain the ouputs the CLI recorded.

To run the test, run `dependabot test -f my-test.yml`. This will run Dependabot with the inputs provided in the test, and assert the outputs match what was previously recorded.

### Caching

To further aid in reproducability, the CLI can instruct the Proxy to enable caching with the ```--cache tmp/cache``` option. Simply pass that along with a path to use for the cache during testing, and the Proxy will dump messages it received there. 

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
  
To see the percentage of caching on each test, go to the [Smoke tests](https://github.com/dependabot/smoke-tests/actions/workflows/smoke.yml) summary view. If the test has low cache coverage then it is more likely to fail in the future. Rerun the Cache one workflow to recache it, or debug why it is uncachable. 

Sometimes after a test has been uncached for a while, it will break, and recaching won't fix it. In this case we will need to regenerate the test locally with `dependabot test -f tests/smoke-bundler.yaml -o tests/smoke-bundler.yaml` for example, then push it up, and recache that test.

Where possible try to add additional ignore_conditions and allowed_updates so even when uncached the tests will not fail.

### Secrets

To keep secrets out of test files, the CLI can use environment variables instead:

```yaml
credentials:
  - type: npm_registry
    registry: https://npm.pkg.github.com
    token: $MY_TOKEN
```
