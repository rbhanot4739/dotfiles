#!/bin/bash
# Wrapper script for gh-dash fzf preview
# Filters gh pr diff output to show only the specified file

REPO_PATH="$1"
PR_NUMBER="$2"
FILE_PATH="$3"

if [ -z "$REPO_PATH" ] || [ -z "$PR_NUMBER" ] || [ -z "$FILE_PATH" ]; then
    echo "Error: Missing arguments"
    exit 1
fi

cd "$REPO_PATH" || exit 1

# Get the full PR diff and filter for the specific file
# Use awk to extract only the diff for the requested file
gh pr diff "$PR_NUMBER" 2>/dev/null | awk -v file="$FILE_PATH" '
BEGIN { printing=0; found=0 }
/^diff --git/ {
    if ($0 ~ "b/" file "$") {
        printing=1
        found=1
    } else {
        printing=0
    }
}
printing { print }
END { if (!found) print "No changes in: " file }
' | delta --side-by-side --width="${FZF_PREVIEW_COLUMNS:-120}" 2>/dev/null || echo "Failed to preview: $FILE_PATH"
