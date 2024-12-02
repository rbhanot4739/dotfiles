#!/bin/bash

current_pane=$(tmux display-message -p '#S:#{window_index}.#{pane_index}')

tmux list-panes -a -F "#S:#{window_index}.#{pane_index}: [#{window_name}:#{pane_current_command}]" | grep -v "^$current_pane" | fzf --preview='tmux capture-pane -ep -t $(echo {} | sed "s/: .*//")' --bind='enter:become(tmux switch-client -t $(echo {} | sed "s/: .*//"))' --tmux center,80%

exit 0
