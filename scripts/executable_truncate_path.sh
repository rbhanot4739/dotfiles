#!/bin/bash

# Get the current path
current_path="$1"
# how many characters to keep from each path component
keep_chars="${2:-2}"
# how many path components from the last to keep
keep_components="${3:-1}"

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

# Truncate all but the $keep_components
for ((i = 0; i < ${#path_components[@]} - "$keep_components"; i++)); do
	# the component is a hidden file/directory we need an extra character
	if [[ "${path_components[$i]}" == .* ]]; then
		path_components[$i]="${path_components[$i]:0:keep_chars+1}"
	else
		path_components[$i]="${path_components[$i]:0:keep_chars}"
	fi
done

# some more tweaking for the last $keep_components
handle_comps() {
  local char=$1
	for ((i = ${#path_components[@]} - keep_components; i < ${#path_components[@]}; i++)); do
		if [[ "${path_components[$i]}" == *$char* ]]; then
			IFS=$char read -ra parts <<<"${path_components[$i]}"
			for j in "${!parts[@]}"; do
				parts[$j]="${parts[$j]:0:keep_chars}"
			done
			path_components[$i]=$(
				IFS=$char
				echo "${parts[*]}"
			)
		fi
	done
}

# handle_comps "_"
# handle_comps "-"

# Join the components back into a path
truncated_path=$(
	IFS=/
	echo "${path_components[*]}"
)

# Debug: Print the truncated path
# echo "Truncated path: $truncated_path"

echo "$truncated_path"
