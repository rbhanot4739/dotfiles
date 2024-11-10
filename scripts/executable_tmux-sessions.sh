#!/bin/bash

# Todo: Adding following features
# Session window preview
# Let create new sessions in opened a directry

header="Keys: enter(Attach), del(Kill)"
fzf_binds='enter:accept-or-print-query,delete:become(tmux kill-session -t {})'
fzf_opts="--header-first --wrap --border-label='Select session to manage'  --color=label:green:bold --color=border:green  --bind \"$fzf_binds\"  --header \"$header\""

inside_tmux() {
  local session=""
  local fzf_cmd="fzf-tmux -p $fzf_opts"
  if [[ -n "$1" ]]; then
    tmux switch-client -t "$1" 2>/dev/null || tmux new-session -d -s "$1" && tmux switch-client -t "$1"
    return
  else
    sess_list=$(tmux list-sessions -F "#{session_name}" 2>/dev/null)
    session=$(echo -n -e "$sess_list" | eval "$fzf_cmd")
    if [[ -n $session ]]; then
      # echo "WIll try to attach or create $session"
      tmux switch-client -t "$session" 2>/dev/null || tmux new-session -d -s "$session" && tmux switch-client -t "$session"
    fi
  fi
}

outside_tmux() {
  local fzf_cmd="fzf -1 -0 --margin=10%,40%,10%,10%  $fzf_opts"
  local session_name=""
  if [[ -n "$1" ]]; then
    # if an argument is supplied try attaching to that session if exists else create a new one but do NOT attach to it
    tmux attach-session -t "$1" 2>/dev/null || tmux new-session -s "$1"
    return
  else
    sess_list=$(tmux list-sessions -F "#{session_name}" 2>/dev/null)
    session_name=$(echo -n "$sess_list" | eval "$fzf_cmd")
    if [[ -n $session_name ]]; then
      # echo "WIll try to attach or create $session"
      tmux attach-session -t "$session_name" || tmux new-session -s "$session_name"
    else
      tmux new-session -s "default"
    fi

  fi

}

get_sessions() {
  local sess_list=$(tmux list-sessions -F "#{session_name}" 2>/dev/null)
  echo -n "$sess_list"
}

if [[ $# -gt 1 ]]; then
  echo "Invalid use of command, Usage: mx [session-name]"
  return
fi

if [[ -n "$TMUX" ]]; then
  inside_tmux $@
else
  outside_tmux $@
fi

# manage_sess() {
#   local action=$1
#   local session_name=$2
#   echo "Action: $action, Session: $session_name"
# }
#
# sess() {
#
#   fzf_binds='enter:become(~/manage_session.sh attach {}),delete:become(~/manage_session.sh kill {})'
#   tmux_cmd="tmux list-sessions -F '#{session_name}'"
#   zoxide_cmd="zoxide query -ls | head -n 5"
#
#   tmux ls -F '#{session_name}' |
#     fzf --bind $fzf_binds --prompt 'Sessions> ' --header 'CTRL-T: Switch between Files/Directories' --bind 'ctrl-t:transform:[[ ! $FZF_PROMPT =~ Sessions ]] &&
#               echo "change-prompt(Sessions> )+reload(tmux list-sessions -F \"#{session_name}\")" ||
#               echo "change-prompt(zoxide> )+reload(zoxide query -l)"'
# }


