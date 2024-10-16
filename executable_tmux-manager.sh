#!/bin/bash

# Todo: Adding following features
# Session window preview
# Let create new sessions in opened a directry (Zoxide integration)

# THIS IS THE WORKING VERSION OF THE SCRIPT

del_confirm_header="--header 'Are you sure you want to kill session {}'"
del_bind="del:become:([[ \\\$(echo 'Yes\nNo' | fzf --tmux  $del_confirm_header) == 'Yes' ]] && tmux kill-session -t {} )"
fzf_binds='enter:accept-or-print-query'
info="--info=hidden"
border_label="--border-label='Tmux Session Manager'"
color_label="--color=label:green:bold"
color_border="--color=border:green"
header_first="--header-first"
header="--header '
      > ?: Switch between Tmux Sessions / Tmuxinator Projects
      > Enter: Attach to tmux session / Start tmuxinator project
      > del: Kill tmux session / Stop tmuxinator project
     '"
color_header="--color=header:blue"
binds="--bind \"$fzf_binds\" --bind \"$del_bind\""
prompt="--prompt 'Tmux Sessions> '"
fzf_transform="--bind '?:transform:[[ ! \$FZF_PROMPT =~ Sessions ]] && \
        echo \"change-prompt(Sessions> )+reload(tmux list-sessions -F \\\"#{session_name}\\\")\" || \
        echo \"change-prompt(Tmuxinator Projects> )+reload(tmuxinator list | tail -n +2 | tr \\\" \\\" \\\"\\n\\\" | awk \\\"NF\\\")\"'"

layout=$([[ -n ${TMUX} ]] && echo "--tmux --layout=reverse" || echo "--height 50% --layout=reverse --margin 15%,25%")
# fzf_cmd="fzf $info $border_label $color_label $color_border $header_first $header $color_header $binds $prompt $fzf_transform $layout"
fzf_cmd="fzf --tmux $info $border_label $color_label $color_border $header_first $header $color_header $binds $prompt $fzf_transform $layout"

tmux_attach_start() {
  local session="$1"
  local mode="$2"
  local tmux_action=""
  tmux_action=$([[ -n ${TMUX} ]] && echo "switch-client" || echo "attach-session")
  local tmux_sessions="tmux list-sessions -F '#{session_name}' 2>/dev/null"
  local tmuxinator_projects="tmuxinator list | tail -n +2"

  ccklekdiihgkjgevtkivevjtkbbciftjkilkubvu

  if [[ $(eval "$tmux_sessions" | tr '\n' ' ') =~ (^|[[:space:]])$session($|[[:space:]]) ]]; then
    tmux "$tmux_action" -t "$session"
  # check if its a tmuninator project and start it
  elif [[ $(eval "$tmuxinator_projects") =~ (^|[[:space:]])$session($|[[:space:]]) ]]; then
    tmuxinator start "$session"
  else
    # its a new session that user has entered as query, so lets create and switch to it
    if [[ "$mode" == "term" ]]; then
      echo -n "No existing session found with name $session. Do you want to create a new session? (Y/n): "
      read -r -n 1 response
      response=${response:-Y}
      if [[ "$response" =~ ^[Yy]$ ]]; then
        tmux new-session -d -s "$1" && tmux "$tmux_action" -t "$session"
      else
        echo "Session creation aborted."
      fi
    else
      tmux new-session -d -s "$1" && tmux "$tmux_action" -t "$session"
    fi

  fi
}

handler_request() {
  local session=""
  if [[ -n "$1" ]]; then
    tmux_attach_start "$1" "term"
    return
  else
    sess_list=$(tmux list-sessions -F "#{session_name}" 2>/dev/null)
    session=$(echo -n -e "$sess_list" | eval "$fzf_cmd")
    if [[ -n $session ]]; then
      tmux_attach_start "$session" "fzf"
    fi
  fi
}

if [[ $# -gt 1 ]]; then
  echo "Invalid use of command, Usage: mx [session-name]"
  return
fi

handler_request "$@"
