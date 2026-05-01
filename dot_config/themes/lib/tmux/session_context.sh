#!/usr/bin/env bash

set -u

pane_command="${1:-}"
pane_path="${2:-$PWD}"
pane_tty="${3:-}"
client_width="${4:-120}"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

trim_left_spaces() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  printf "%s" "$value"
}

ellipsize_middle() {
  local value="$1"
  local max_chars="$2"
  local len head tail

  len=${#value}
  if (( len <= max_chars )); then
    printf "%s" "$value"
    return
  fi

  if (( max_chars <= 3 )); then
    printf "%s" "${value:0:max_chars}"
    return
  fi

  head=$(( (max_chars - 3) / 2 ))
  tail=$(( max_chars - 3 - head ))
  printf "%s...%s" "${value:0:head}" "${value: -tail}"
}

extract_ssh_target() {
  local cmdline="$1"
  local -a argv
  local host=""
  local token
  local i=1

  read -r -a argv <<< "$cmdline"

  while (( i < ${#argv[@]} )); do
    token="${argv[$i]}"

    if [[ "$token" == "--" ]]; then
      ((i++))
      break
    fi

    case "$token" in
      -4|-6|-A|-a|-C|-f|-G|-g|-K|-k|-M|-N|-n|-q|-s|-T|-t|-V|-v|-X|-x|-Y|-y)
        ((i++))
        continue
        ;;
      -b|-c|-D|-E|-e|-F|-I|-i|-J|-L|-l|-m|-O|-o|-p|-Q|-R|-S|-W|-w)
        ((i+=2))
        continue
        ;;
      -*)
        ((i++))
        continue
        ;;
      *)
        host="$token"
        break
        ;;
    esac
  done

  if [[ -z "$host" && i -lt ${#argv[@]} ]]; then
    host="${argv[$i]}"
  fi

  host="${host##*@}"
  host="${host%%.linkedin.*}"
  host="${host%%:*}"
  printf "%s" "$host"
}

ssh_cmd=""

if [[ -n "$pane_tty" ]]; then
  while IFS= read -r line; do
    line="$(trim_left_spaces "$line")"
    case "$line" in
      ssh\ *|*/ssh\ *)
        [[ "$line" == *" -W "* ]] && continue
        ssh_cmd="$line"
        ;;
    esac
  done < <(ps -t "$pane_tty" -o command= 2>/dev/null)
fi

target="$(extract_ssh_target "$ssh_cmd")"
if [[ -n "$target" ]]; then
  if (( client_width < 120 )); then
    target="$(ellipsize_middle "$target" 16)"
  elif (( client_width < 170 )); then
    target="$(ellipsize_middle "$target" 22)"
  else
    target="$(ellipsize_middle "$target" 30)"
  fi
  printf "󰣀 %s" "$target"
  exit 0
fi

if [[ "$pane_command" == "ssh" ]]; then
  printf "󰣀 ssh"
  exit 0
fi

bash "$script_dir/path_context.sh" "$pane_path" "$client_width"
