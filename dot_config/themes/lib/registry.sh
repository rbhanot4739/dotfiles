# Registry access for the theme tools. Source this file; do not execute it.
#
# Portable: bash 3.2 (macOS /bin/bash) and newer, BSD or GNU userland. No yq and
# no bash-4 features. Registry YAML is parsed by lib/registry.awk.
#
# API
#   registry_list                         print theme names, one per line
#   registry_file <theme>                 print the YAML path (fails if missing)
#   theme_meta <theme>                    sets T_name T_mode T_description
#   theme_load <theme> <bg-mode> <sect>   sets V_<key> for each key in the section
#                                         (adaptive themes read the <bg-mode> variant)
#   theme_need <key>...                   fail if any V_<key> is missing or "null"
#   registry_dump_meta|registry_dump_section ...   raw "key<TAB>value" lines

THEMES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
THEMES_REGISTRY="${THEMES_REGISTRY:-$THEMES_ROOT/registry}"
_REGISTRY_AWK="$THEMES_ROOT/lib/registry.awk"

registry_list() {
  local f
  for f in "$THEMES_REGISTRY"/*.yaml; do
    [ -f "$f" ] || continue
    f="${f##*/}"
    printf '%s\n' "${f%.yaml}"
  done
}

registry_file() {
  local f="$THEMES_REGISTRY/$1.yaml"
  if [ -z "$1" ] || [ ! -f "$f" ]; then
    echo "Error: theme not found: $1" >&2
    return 1
  fi
  printf '%s\n' "$f"
}

# registry_dump_meta <theme>
registry_dump_meta() {
  local f
  f=$(registry_file "$1") || return 1
  awk -v want=meta -f "$_REGISTRY_AWK" "$f" "$f"
}

# registry_dump_section <theme> <bg-mode> <section>
registry_dump_section() {
  local f
  f=$(registry_file "$1") || return 1
  awk -v want=section -v want_mode="$2" -v section="$3" -f "$_REGISTRY_AWK" "$f" "$f"
}

# Assign "key<TAB>value" lines (stdin) to <prefix><key> shell variables.
# Keys are validated by the awk parser to [A-Za-z0-9_]+.
_registry_assign() {
  local prefix="$1" k v
  while IFS=$'\t' read -r k v; do
    [ -n "$k" ] || continue
    printf -v "${prefix}${k}" '%s' "$v"
  done
}

_registry_unset() {
  local v
  for v in $(compgen -v "$1"); do unset "$v"; done
}

theme_meta() {
  local out
  out=$(registry_dump_meta "$1") || return 1
  _registry_unset T_
  T_description=""
  _registry_assign T_ <<< "$out"
  if [ -z "${T_name:-}" ] || [ -z "${T_mode:-}" ]; then
    echo "Error: $1: registry file needs top-level 'name' and 'mode'" >&2
    return 1
  fi
  case "$T_mode" in
    dark|light|adaptive) ;;
    *) echo "Error: $1: mode must be dark, light or adaptive (got '$T_mode')" >&2; return 1 ;;
  esac
  if [ "$T_name" != "$1" ]; then
    echo "Error: $1: 'name: $T_name' does not match the file name" >&2
    return 1
  fi
}

theme_load() {
  local out
  out=$(registry_dump_section "$1" "$2" "$3") || {
    echo "Error: $1 ($2): cannot read section '$3'" >&2
    return 1
  }
  _registry_unset V_
  _registry_assign V_ <<< "$out"
}

theme_need() {
  local k val missing=""
  for k in "$@"; do
    eval "val=\${V_$k-}"
    if [ -z "$val" ] || [ "$val" = "null" ]; then
      missing="$missing $k"
    fi
  done
  if [ -n "$missing" ]; then
    echo "Error: ${THEME:-theme}: missing keys:$missing" >&2
    return 1
  fi
}
