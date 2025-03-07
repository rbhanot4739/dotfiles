#/bin/bash

current_pane=$(tmux display-message -p '#S:#{window_index}.#{pane_index}')

info="--info=hidden"
prompt="--prompt='Panes > '"
border="--border --padding 1,1  --border-label=' Tmux Pane Switcher '"
header_first="--header-first"
header="--header-label '' --header 'Pane format: <session name:> <window_name> [cwd for pane]
Press Enter to switch to the selected pane'"
layout=$([[ -n ${TMUX} ]] && echo "--tmux center,90%,80% --padding 2,1,0,1 --margin 0 --reverse" || echo "--height 70% --layout=reverse --margin 15%,15%")
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

tmux_panes=$(tmux list-panes -a -F "#S:#{window_index}.#{pane_index}: #{window_name}<>#{pane_current_path}" | grep -v "$current_pane" |
	while read -r line; do
    # shell expansion
    path="${line##*<>}"    # this removes everything from beginning of the string upto `*<>`
		prefix="${line%%<>*}"    # this removes everything from the end of the string upto `<>*`

		path="${path/#$HOME/~}"
		# Split the path into components
		IFS='/' read -r -a path_components <<<"$path"

		truncated_path=""
		for ((i = 0; i < ${#path_components[@]} - 1; i++)); do
			if [[ "${path_components[$i]}" == .* ]]; then
				path_components[$i]="${path_components[$i]:0:3}"
			else
				path_components[$i]="${path_components[$i]:0:2}"
			fi
		done
		truncated_path=$(
			IFS=/
			echo "${path_components[*]}"
		)
		echo "$prefix [$truncated_path]"
	done)

printf "%s\n" "$tmux_panes" | eval "$fzf_cmd -d ':' --with-nth 1,3"
exit 0
