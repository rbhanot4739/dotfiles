#!/usr/bin/env bash

tmux_session_attach_start() {
  tmux_action=$([[ -n ${TMUX} ]] && echo "switch-client" || echo "attach-session")
  session=$1
  tmux_sessions="tmux list-sessions -F '#{session_name}' 2>/dev/null"
  # check if its a tmuxinator project and start it
  tmuxinator_projects="tmuxinator list | tail -n +2"
  if [[ $(eval "$tmux_sessions" | tr '\n' ' ') =~ (^|[[:space:]])$session($|[[:space:]]) ]]; then
    tmux "$tmux_action" -t "$session"
  elif [[ $(eval "$tmuxinator_projects") =~ (^|[[:space:]])$session($|[[:space:]]) ]]; then
    tmuxinator start "$session"
  else
    tmux new-session -d -s "$1" && tmux "$tmux_action" -t "$session"
  fi
}
export -f tmux_session_attach_start

tmux_session_kill_stop() {
  session=$1
  selection=$(echo -e "No\nYes" | fzf center,35%,35% --header "Are you sure you want to delete session [$session]?")
  if [[ $(echo "$selection" | tr '[:upper:]' '[:lower:]') == "no" ]]; then
    echo "Aborting..."
    return 0
  fi
  tmux_sessions="tmux list-sessions -F '#{session_name}'"
  tmuxinator_projects="tmuxinator list | tail -n +2"
  if [[ $(eval "$tmux_sessions" | tr '\n' ' ') =~ (^|[[:space:]])$session($|[[:space:]]) ]]; then
    tmux kill-session -t "$session"
  elif [[ $(eval "$tmuxinator_projects") =~ (^|[[:space:]])$session($|[[:space:]]) ]]; then
    tmuxinator stop "$session"
  else
    echo "No Tmux session found with name: $session"
  fi
}
export -f tmux_session_kill_stop

manage_session() {
  if [[ -n "$1" ]]; then
    echo
  else

    local attach_bind="enter:become:(tmux_session_attach_start {})"
    local del_bind="delete:become:(tmux_session_kill_stop {})"
    local new_sess_bind="ctrl-n:become:(tmux_session_attach_start {q})"

    tmux ls -F '#{session_name}' |  SHELL=$(which bash) \
     fzf \
         --no-tmux \
      --info=hidden \
      --border-label='Tmux Session Manager' \
      --color=label:green:bold --color=border:green \
      --header-first \
      --header '
      > ?: Switch between Tmux Sessions / Tmuxinator Projects
      > Enter: Attach to tmux session / Start tmuxinator project
      > del: Kill tmux session / Stop tmuxinator project
      > CTRL-N: New tmux session
     ' \
      --color=header:blue \
      --bind "$attach_bind" \
      \
      --prompt 'Tmux Sessions> ' \
      --bind '?:transform:[[ ! $FZF_PROMPT =~ Sessions ]] && \
        echo "change-prompt(Sessions> )+reload(tmux list-sessions -F \"#{session_name}\")" || \
        echo "change-prompt(Tmuxinator Projects> )+reload(tmuxinator list | tail -n +2 | tr \" \" \"\n\" | awk \"NF\")"' # --bind "$del_bind" \
    # --bind "$new_sess_bind" \
  fi
  return 0
}

if [[ $# -gt 1 ]]; then
  echo "Invalid use of command, Usage: mx [session-name]"
  return
else
  manage_session "$1"
fi
