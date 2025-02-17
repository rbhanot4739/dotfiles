
#/bin/bash

current_pane=$(tmux display-message -p '#S:#{window_index}.#{pane_index}')

info="--info=hidden"
prompt="--prompt='Panes > '"
border="--border --padding 1,1  --border-label=' Tmux Pane Switcher '"
header_first="--header-first"
header="--header-label ' Keymaps ' --header 'Press Enter to switch to the selected pane'"
layout=$([[ -n ${TMUX} ]] && echo "--tmux center,70%,70% --reverse" || echo "--height 70% --layout=reverse --margin 15%,15%")
binds="--bind 'enter:become(tmux switch-client -t \$(echo {} | sed \"s/: .*//\"))'"
preview="--preview='tmux capture-pane -ep -t \$(echo {} | sed \"s/: .*//\")'"

fzf_cmd="fzf --style full"
[ -n "$info" ] && fzf_cmd+=" $info"
[ -n "$binds" ] && fzf_cmd+="  $binds"
[ -n "$border" ] && fzf_cmd+=" $border"
[ -n "$header_first" ] && fzf_cmd+=" $header_first"
[ -n "$header" ] && fzf_cmd+=" $header"
[ -n "$layout" ] && fzf_cmd+=" $layout"
[ -n "$prompt" ] && fzf_cmd+=" $prompt"
[ -n "$preview" ] && fzf_cmd+=" $preview"

tmux_panes=$(tmux list-panes -a -F "#S:#{window_index}.#{pane_index}: [#{window_name}:#{pane_current_command}]" | grep -v "^$current_pane")
printf "%s\n" "$tmux_panes" | eval "$fzf_cmd -d ':' --with-nth 1,3,4"
# tmux list-panes -a -F "#S:#{window_index}.#{pane_index}: [#{window_name}:#{pane_current_command}]" | grep -v "^$current_pane" | fzf --style full --preview='tmux capture-pane -ep -t $(echo {} | sed "s/: .*//")' --bind='enter:become(tmux switch-client -t $(echo {} | sed "s/: .*//"))' --tmux center,80% 

exit 0
