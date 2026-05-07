#!/usr/bin/env bash
# Usage: update-ssh-hosts.sh <range1> [range2 ...]
#
# Ranges without a prefix write plain hostnames to ~/.ssh/range_hosts_cache
# Ranges with a prefix (range:prefix) write SSH config stanzas to ~/.ssh/config.ranges
#
# Example:
#   update-ssh-hosts.sh %corp-lca1.dcl.1:dcl %all-shell-hosts
set -euo pipefail

if [[ $# -eq 0 ]]; then
  echo "Usage: $0 <range1[:prefix]> [range2[:prefix]] ..." >&2
  exit 1
fi

PLAIN_CACHE=~/.ssh/range_hosts_cache
STANZA_CACHE=~/.ssh/config.ranges
PLAIN_TMP="${PLAIN_CACHE}.tmp.$$"
STANZA_TMP="${STANZA_CACHE}.tmp.$$"

plain_ranges=()
declare -A stanza_ranges  # range -> prefix

for arg in "$@"; do
  if [[ "$arg" == *:* ]]; then
    range="${arg%%:*}"
    prefix="${arg##*:}"
    stanza_ranges["$range"]="$prefix"
  else
    plain_ranges+=("$arg")
  fi
done

# Plain hostnames
if (( ${#plain_ranges[@]} > 0 )); then
  for range in "${plain_ranges[@]}"; do
    eh -e "$range" 2>/dev/null
  done | sort -u > "$PLAIN_TMP" && mv "$PLAIN_TMP" "$PLAIN_CACHE"
  echo "Updated: $(wc -l < "$PLAIN_CACHE" | tr -d ' ') hosts → $PLAIN_CACHE"
fi

# SSH config stanzas
if (( ${#stanza_ranges[@]} > 0 )); then
  : > "$STANZA_TMP"
  for range in "${!stanza_ranges[@]}"; do
    prefix="${stanza_ranges[$range]}"
    eh -e "$range" 2>/dev/null | sort -u | while read -r host; do
      alias="${prefix}-${host%.linkedin.com}"
      printf 'Host %s\n  Hostname %s\n\n' "$alias" "$host"
    done
  done >> "$STANZA_TMP" && mv "$STANZA_TMP" "$STANZA_CACHE"
  echo "Updated: $(grep -c '^Host ' "$STANZA_CACHE") stanzas → $STANZA_CACHE"
fi
