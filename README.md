# IntelliJ IDEA Format Action

This action automatically formats your code using the IntelliJ formatter, ensuring it adheres to good style guidelines.

## Examples

Both examples implement caching of downloaded IDEA files (~900MB). <br>
Cache generation might take a while on the first run, but saves bandwidth and is faster later on.

This workflow will format all files that are supported by the formatter in your repository and commit the changes whenever there's a push to the `main` branch.

```yaml
name: IntelliJ Format

on:
  push:
    branches: ["main"]

jobs:
  formatting:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Cache IDEA
        uses: actions/cache@v3
        with:
          path: /home/runner/work/_temp/_github_workflow/idea-cache
          key: ${{ runner.os }}-idea-cache-v2
      - uses: notdevcody/intellij-format-action@v2
```

---

This workflow will format all files that are supported by the formatter in your repository and commit the changes whenever there's a push to the `main` branch, including pull requests to it.

```yaml
name: IntelliJ Format

on:
  push:
    branches: ["main"]
  pull_request:
    branches: ["main"]

jobs:
  formatting:
    runs-on: ubuntu-latest
    steps:
      - if: github.event_name != 'pull_request'
        uses: actions/checkout@v4
      - if: github.event_name == 'pull_request'
        uses: actions/checkout@v4
        with:
          ref: ${{ github.event.pull_request.head.ref }}
      - name: Cache IDEA
        uses: actions/cache@v3
        with:
          path: /home/runner/work/_temp/_github_workflow/idea-cache
          key: ${{ runner.os }}-idea-cache-v2
      - uses: notdevcody/intellij-format-action@v2
```

## Inputs

While none of these inputs are mandatory, you can specify them to modify the action's behavior.

### `include-glob`

Pattern for files to include. Supports glob-style wildcards. Multiple patterns can be separated by commas.<br>
**Default:** `*`

### `path`

Path to project directory. The formatter is executed recursively from here. Must be relative to the workspace.<br>
**Default:** `.`

### `commit-on-changes`

If true, the action will commit any files changed by the formatter.<br>
**Default:** `true`

### `commit-message`

The commit message to use when committing.<br>
**Default:** `IntelliJ Code Format`

### `fail-on-changes`

If true, the action will fail if any files were changed.<br>
**Default:** `true`

### `style-settings-file`

A path to IntelliJ IDEA code style settings .xml file.<br>
**Default:** `unset` (`-allowDefaults` argument)

## Outputs

### `files-changed`

Outputs the number of files which were formatted.<br>
Zero if none changed.
