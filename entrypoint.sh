#!/bin/bash

if [[ $# -ne 3 ]]; then
  echo 'Exactly three parameters required: path, include-glob, style-settings-file'
  exit 1
fi

base_path=$1
include_pattern=$2
style_settings_file=$3

echo 'Input: path, include-glob, style-settings-file'
echo base_path
echo include_pattern
echo style_settings_file


style_flags="-allowDefaults"



if [[ "$style_settings_file" != "unset" ]]; then
  if [ ! -f "$style_settings_file" ]; then
    echo "Error: style-settings-file '$style_settings_file' does not exist."
    exit 1
  fi
  style_flags="-s $style_settings_file"
fi

IDEA_DIR=${IDEA_CACHE_DIR:-"/github/workflow/idea-cache"}

if [ ! -d "$IDEA_DIR/bin" ]; then
  # You can find builds here: https://youtrack.jetbrains.com/articles/IDEA-A-21/IDEA-Latest-Builds-And-Release-Notes
  wget --no-verbose -O /tmp/idea.tar.gz https://download.jetbrains.com/idea/ideaIC-2024.3.3.tar.gz
  mkdir -p "$IDEA_DIR"
  tar xzf /tmp/idea.tar.gz -C "$IDEA_DIR" --strip-components=1
  rm /tmp/idea.tar.gz
fi

git config --global --add safe.directory /github/workspace

cd "/github/workspace/$base_path" || exit 2
changed_files_before=$(git status --short)

# Run the format.sh command and capture its exit code
if ! "$IDEA_DIR/bin/format.sh" -m "$include_pattern" $style_flags -dry -r .; then
  echo "Error: format.sh command failed."
  exit 1
fi

changed_files_after=$(git status --short)
changed_files=$(diff <(echo "$changed_files_before") <(echo "$changed_files_after"))
changed_files_count=$(($(echo "$changed_files" | wc --lines) - 1))

echo "$changed_files"
echo "files-changed=$changed_files_count" >> $GITHUB_OUTPUT

# Fail on change
if [[ $changed_files_count -gt 0 ]]; then
  exit 1
fi
