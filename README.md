# IntelliJ IDEA Format Action
This action automatically formats your code using the IntelliJ formatter, ensuring it adheres to good style guidelines.

## Examples
This workflow will format all files that are supported by the formatter in your repository and commit the changes whenever there's a push to the `main` branch.
```yaml
name: IntelliJ Format

on:
  push:
    branches: [ "main" ]

jobs:
  formatting:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: notdevcody/intellij-format-action@v1
```
---

This workflow will format all files that are supported by the formatter in your repository and commit the changes whenever there's a push to the `main` branch, including pull requests to it.
```yaml
name: IntelliJ Format

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:
  formatting:
    runs-on: ubuntu-latest
    steps:
      - if: github.event_name != 'pull_request'
        uses: actions/checkout@v3
      - if: github.event_name == 'pull_request'
        uses: actions/checkout@v3
        with:
          ref: ${{ github.event.pull_request.head.ref }}
      - uses: actions/checkout@v3
      - uses: notdevcody/intellij-format-action@v1
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
If true, the action will fail if any file changed.<br>
**Default:** `true`

## Outputs
### `files-changed`
Outputs the amount of files which were formatted.<br>
Zero if none changed.