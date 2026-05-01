#!/usr/bin/env bash

set -u

cwd="${1:-$PWD}"
client_width="${2:-120}"

if ! [[ "$client_width" =~ ^[0-9]+$ ]]; then
  client_width=120
fi

ellipsize_middle() {
  local value="$1"
  local max_chars="$2"
  local value_len head_len tail_len

  value_len=${#value}
  if (( value_len <= max_chars )); then
    printf "%s" "$value"
    return
  fi

  if (( max_chars <= 3 )); then
    printf "%s" "${value:0:max_chars}"
    return
  fi

  head_len=$(( (max_chars - 3) / 2 ))
  tail_len=$(( max_chars - 3 - head_len ))
  printf "%s...%s" "${value:0:head_len}" "${value: -tail_len}"
}

truncate_component() {
  local value="$1"
  local max_chars="$2"
  local value_len head_len tail_len

  value_len=${#value}
  if (( value_len <= max_chars )); then
    printf "%s" "$value"
    return
  fi

  if (( max_chars <= 4 )); then
    printf "%s" "${value:0:max_chars}"
    return
  fi

  # Keep more characters from the beginning for readability.
  head_len=$(( (max_chars - 3) * 2 / 3 ))
  (( head_len < 2 )) && head_len=2
  tail_len=$(( max_chars - 3 - head_len ))
  printf "%s...%s" "${value:0:head_len}" "${value: -tail_len}"
}

format_tail_from_stripped() {
  local stripped_path="$1"
  local base_prefix="$2"
  local max_total="$3"
  local parent_budget="$4"
  local leaf_budget="$5"
  local -a raw_parts parts
  local part total raw_parent raw_leaf parent leaf out

  IFS='/' read -r -a raw_parts <<< "$stripped_path"
  for part in "${raw_parts[@]}"; do
    [[ -n "$part" ]] && parts+=("$part")
  done
  total=${#parts[@]}

  if (( total == 0 )); then
    printf "%s" "${base_prefix%/}"
    return
  fi

  if (( total == 1 )); then
    out="${base_prefix}$(truncate_component "${parts[0]}" "$max_total")"
    printf "%s" "$(ellipsize_middle "$out" "$max_total")"
    return
  fi

  if (( total == 2 )); then
    raw_parent="${parts[0]}"
    raw_leaf="${parts[1]}"
    out="${base_prefix}${raw_parent}/${raw_leaf}"
    if (( ${#out} <= max_total )); then
      printf "%s" "$out"
      return
    fi
    parent="$(truncate_component "$raw_parent" "$parent_budget")"
    leaf="$(truncate_component "$raw_leaf" "$leaf_budget")"
    out="${base_prefix}${parent}/${leaf}"
  else
    raw_parent="${parts[$((total - 2))]}"
    raw_leaf="${parts[$((total - 1))]}"
    out="${base_prefix}.../${raw_parent}/${raw_leaf}"
    if (( ${#out} <= max_total )); then
      printf "%s" "$out"
      return
    fi
    parent="$(truncate_component "$raw_parent" "$parent_budget")"
    leaf="$(truncate_component "$raw_leaf" "$leaf_budget")"
    out="${base_prefix}.../${parent}/${leaf}"
  fi

  while (( ${#out} > max_total && parent_budget > 4 )); do
    (( parent_budget-- ))
    parent="$(truncate_component "$raw_parent" "$parent_budget")"
    if (( total == 2 )); then
      out="${base_prefix}${parent}/${leaf}"
    else
      out="${base_prefix}.../${parent}/${leaf}"
    fi
  done

  while (( ${#out} > max_total && leaf_budget > 6 )); do
    (( leaf_budget-- ))
    leaf="$(truncate_component "$raw_leaf" "$leaf_budget")"
    if (( total == 2 )); then
      out="${base_prefix}${parent}/${leaf}"
    else
      out="${base_prefix}.../${parent}/${leaf}"
    fi
  done

  printf "%s" "$(ellipsize_middle "$out" "$max_total")"
}

if (( client_width < 120 )); then
  max_chars=22
  parent_max=6
  leaf_max=10
elif (( client_width < 170 )); then
  max_chars=30
  parent_max=10
  leaf_max=14
else
  max_chars=36
  parent_max=12
  leaf_max=18
fi

if repo_root="$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)"; then
  if [[ "$cwd" == "$repo_root" ]]; then
    display_path="$(truncate_component "$(basename "$repo_root")" "$max_chars")"
  else
    rel_path="${cwd#"$repo_root"/}"
    display_path="$(format_tail_from_stripped "$rel_path" "" "$max_chars" "$parent_max" "$leaf_max")"
  fi
  printf " %s" "$display_path"
  exit 0
fi

display_path="$cwd"
if [[ "$display_path" == "$HOME"* ]]; then
  display_path="~${display_path#$HOME}"
fi

if [[ "$display_path" == "~/"* ]]; then
  stripped="${display_path#~/}"
  display_path="$(format_tail_from_stripped "$stripped" "~/" "$max_chars" "$parent_max" "$leaf_max")"
elif [[ "$display_path" == "/"* ]]; then
  stripped="${display_path#/}"
  display_path="$(format_tail_from_stripped "$stripped" "/" "$max_chars" "$parent_max" "$leaf_max")"
else
  display_path="$(format_tail_from_stripped "$display_path" "" "$max_chars" "$parent_max" "$leaf_max")"
fi

printf " %s" "$display_path"
