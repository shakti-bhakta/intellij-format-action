#!/bin/bash

# Exit immediately if any command fails
set -e

if [[ $# -ne 3 ]]; then
  echo 'Exactly three parameters required: path, include-pattern, style-settings-file'
  exit 1
fi

path=$1
include_pattern=$2
style_settings_file=$3

echo '--- Input ---'
echo "path: $path"
echo "include_pattern: $include_pattern"
echo "style_settings_file: $style_settings_file"


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
   echo "Downloading IntelliJ IDEA..."
  wget --no-verbose -O /tmp/idea.tar.gz https://download.jetbrains.com/idea/ideaIC-2024.3.3.tar.gz
  mkdir -p "$IDEA_DIR"
  echo "Extracting IntelliJ IDEA..."
  tar xzf /tmp/idea.tar.gz -C "$IDEA_DIR" --strip-components=1
  rm /tmp/idea.tar.gz
else
  echo "IntelliJ IDEA is already installed. Skipping download."
fi

git config --global --add safe.directory /github/workspace

cd "/github/workspace/$path" || exit 2
changed_files_before=$(git status --short)

# Run the format.sh command and print its output to the console
echo "Running format.sh..."
if ! "$IDEA_DIR/bin/format.sh" -m "$include_pattern" $style_flags -dry -r . 2>&1 | tee format_output.log; then
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

echo "Formatting completed successfully. No changes detected."
