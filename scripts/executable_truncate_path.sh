#!/bin/bash

# Get the current path
current_path="$1"

# Debug: Print the original path
# echo "Original path: $current_path"

# Ensure HOME is set
if [ -z "$HOME" ]; then
  echo "HOME variable is not set."
  exit 1
fi

# Replace home directory with ~ if it contains $HOME
if [[ "$current_path" == *"$HOME"* ]]; then
  current_path="~${current_path#$HOME}"
fi

# Debug: Print the path after replacement
# echo "Path after replacement: $current_path"

# Split the path into components
IFS='/' read -r -a path_components <<<"$current_path"

# Debug: Print the path components
# echo "Path components: ${path_components[*]}"

# Truncate all but the last two components
for ((i = 0; i < ${#path_components[@]} - 2; i++)); do
  if [[ "${path_components[$i]}" == .* ]]; then
    path_components[$i]="${path_components[$i]:0:2}"
  else
    path_components[$i]="${path_components[$i]:0:1}"
  fi
done

# Join the components back into a path
truncated_path=$(
  IFS=/
  echo "${path_components[*]}"
)

# Debug: Print the truncated path
# echo "Truncated path: $truncated_path"

echo "$truncated_path"
