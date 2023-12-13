#!/bin/bash

# Wrapper for the formatter that passes action args and processes the output.
# Required args:
# - Path to base directory.
# - File include glob pattern.
# - Whether to commit on file changes.

if [[ $# -ne 5 ]]; then
  echo 'Exactly four parameters (base dir path, input file pattern, commit on changes, commit message) required.'
  exit 1
fi

base_path=$1
include_pattern=$2
commit_on_changes=$3
commit_message=$4
fail_on_changes=$5

git config --global --add safe.directory /github/workspace

cd "/github/workspace/$base_path" || exit 2
changed_files_before=$(git status --short)

/opt/idea/bin/format.sh -m $include_pattern -r .

changed_files_after=$(git status --short)
changed_files=$(diff <(echo "$changed_files_before") <(echo "$changed_files_after"))
changed_files_count=$(($(echo "$changed_files" | wc --lines) - 1))

echo "$changed_files"
echo "files-changed=$changed_files_count" >> $GITHUB_OUTPUT

if [[ "$commit_on_changes" == 'true' ]]; then
  if [[ $changed_files_count -gt 0 ]]; then
    git config user.name github-actions
    git config user.email ''
    git commit --all -m "$commit_message"
    git push
  fi
fi

if [[ "$fail_on_changes" == 'true' ]]; then
  if [[ $changed_files_count -gt 0 ]]; then
    exit 1
  fi
fi