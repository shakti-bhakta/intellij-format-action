#!/bin/bash

if [[ $# -ne 6 ]]; then
  echo 'Exactly six parameters required: path, include-glob, commit-on-changes, commit-message, fail-on-changes, style-settings-file'
  exit 1
fi

base_path=$1
include_pattern=$2
commit_on_changes=$3
commit_message=$4
fail_on_changes=$5
style_settings_file=$6

style_flags="-allowDefaults"

if [[ "$style_settings_file" != "unset" ]]; then
  style_flags="-s $style_settings_file"
fi

IDEA_DIR=${IDEA_CACHE_DIR:-"/github/workflow/idea-cache"}

if [ ! -d "$IDEA_DIR/bin" ]; then
  wget --no-verbose -O /tmp/idea.tar.gz https://download.jetbrains.com/idea/ideaIC-2024.2.0.1.tar.gz
  mkdir -p "$IDEA_DIR"
  tar xzf /tmp/idea.tar.gz -C "$IDEA_DIR" --strip-components=1
  rm /tmp/idea.tar.gz
fi

git config --global --add safe.directory /github/workspace

cd "/github/workspace/$base_path" || exit 2
changed_files_before=$(git status --short)

"$IDEA_DIR/bin/format.sh" -m $include_pattern $style_flags -r .

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