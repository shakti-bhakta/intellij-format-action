# IntelliJ IDEA Format Action

Check if code complies with IntelliJ code style XML.
Fails the action if any files need formatting.

## Example

The example implements caching of downloaded IDEA files (~900MB). <br>
Cache generation might take a while on the first run, but saves bandwidth and is faster later on.
```yaml
name: IntelliJ Format

on:
  pull_request:

jobs:
  check-format:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Cache IDEA
        uses: actions/cache@v3
        with:
          path: /home/runner/work/_temp/_github_workflow/idea-cache
          key: ${{ runner.os }}-idea-cache-v2
      - uses: shakti-bhakta/intellij-format-action@v2
        with:
          include-glob: '*.java'
          path: 'java-module/'
          style-settings-file: 'custom-intellij-format.xml'
```

## Inputs

While none of these inputs are mandatory, you can specify them to modify the action's behavior.

### `include-glob`

Pattern for files to include. Supports glob-style wildcards. Multiple patterns can be separated by commas.<br>
**Default:** `*`

### `path`

Path to project directory. The formatter is executed recursively from here. Must be relative to the workspace.<br>
**Default:** `.`

### `style-settings-file`

A path to IntelliJ IDEA code style settings .xml file.<br>
**Default:** `unset` (`-allowDefaults` argument)

## Outputs

### `files-changed`

Outputs the number of files which were formatted.<br>
Zero if none changed.
