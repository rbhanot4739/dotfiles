#!/bin/bash

# Todo: Adding following features
# Session window preview

# THIS IS THE WORKING VERSION OF THE SCRIPT
get_tmux_sessions() {
  sess_cmd="tmux list-sessions -F '#S#{?session_attached, (attached),}' 2> /dev/null"
	tmux_sessions=$(eval $sess_cmd | while read -r line; do echo    $line; done)
  # echo $tmux_sessions
  eval $sess_cmd
}
export -f get_tmux_sessions

get_zoxide_dirs() {
	path_cmd=$([[ -f $HOME/scripts/truncate_path.sh ]] && echo "$HOME/scripts/truncate_path.sh {x} 2 2" || echo "basename {x}")
	# cmd="zoxide query -l | head -n 10 | xargs -I {x} $path_cmd |while read -r line; do echo   \$line; done"
	cmd="zoxide query -l | head -n 20 | xargs -I {x} $path_cmd"
	eval "$cmd" 
}
export -f get_zoxide_dirs

get_tmuxinator_projects() {
	tmuxinator list | tail -n +2 | sed 's/ \{1,\}/\n/g'
}
export -f get_tmuxinator_projects

rename_session() {

  clear
	# Prompt the user to enter a string
  old_name=$(echo "$1" | cut -d' ' -f1)
	echo -n "Please enter new session name[$old_name] (Escape/Ctrl+C to cancel): "
  # old_name=$([[ $1 == "current" ]] && tmux display-message -p '#S' || echo "$1")

	user_input=""

	while true; do
		# Read user input one character at a time
		read -rsn1 input

		if [[ "$input" == $'\e' ]]; then
			# Escape key pressed, exit the function
			# echo -e "\nOperation canceled."
			return
		elif [[ "$input" == $'\n' || "$input" == $'\x0' ]]; then
			# Enter key pressed, exit the loop and finalize input
			# echo -e "\nInput accepted."
			break
		# elif [[ "$input" == $'\x7f' ]]; then
    elif [[ "$input" == $'\x7f' || "$input" == $'\b' ]]; then
			# Backspace pressed, remove the last character
			if [[ -n "$user_input" ]]; then
				# Only delete if there's something to delete
				user_input="${user_input%?}"
				echo -ne "\b \b" # Move cursor back and clear the character
			fi
		else
			# Other key pressed, append it to the string and display it
			user_input+="$input"
			echo -n "$input" # Show the character pressed
		fi
	done

	# echo -e "\nYou entered: $user_input"

	session_name=$user_input
	[[ -n $session_name ]] && tmux rename-session -t "$old_name" "$session_name"
}
export -f rename_session

get_current_session(){
  [[ -n "$TMUX" ]] && tmux display-message -p '#S'
}
export -f get_current_session

del_session() {
	clear
  [[ $1 =~ "attached" ]] && echo "You can't delete the currently attached session !!" && sleep 1 && return
	echo -n "Are you sure you want to delete session ($1) [y/n]: "
	read -r -n 1 response
	response=${response:-n}
	[[ "$response" =~ ^[Yy]$ ]] && tmux kill-session -t "$1"
}
export -f del_session

TRANSFORMER='
 if [[ $FZF_PROMPT =~ Sessions ]]; then
    # enable zoxide only if its installed
    if [[ $(command -v zoxide) ]]; then
      # echo "change-prompt(Zoxide Dirs (Top 10) > )+reload(get_zoxide_dirs | while read -r line; do echo    \$line; done)"
      echo "change-prompt(Zoxide Dirs (Top 10) > )+reload(get_zoxide_dirs)"
    # enable tmuxinator only if its installed
    elif [[ $(command -v tmuxinator) ]]; then
      echo "change-prompt(Tmuxinator Projects > )+reload(get_tmuxinator_projects)"
    fi
elif [[ $FZF_PROMPT =~ Zoxide ]]; then
    # enable tmuxinator only if its installed
    if [[ $(command -v tmuxinator) ]]; then
    echo "change-prompt(Tmuxinator Projects > )+reload(get_tmuxinator_projects)"
  else
    echo "change-prompt(Tmux Sessions > )+reload(get_tmux_sessions)"
    fi
else
  echo "change-prompt(Tmux Sessions > )+reload(get_tmux_sessions)"
fi
 '


del_bind="del:execute(del_session {})+reload(get_tmux_sessions)"
rename_bind="ctrl-]:execute(rename_session {})+reload(get_tmux_sessions)"
fzf_binds='enter:accept-or-print-query'
info="--info=hidden"
border="--border --padding 1,1  --border-label=' Tmux Session Manager '"
# color_label="--color=label:green:bold"
# color_border="--color=border:green"
# color_header="--color=header:blue"
header_first="--header-first"
header="--header-label ' Keymaps ' --header '
> ?: Switch between Tmux Sessions / Zoxide Dirs/ Tmuxinator Projects
> Enter:  Attach to existing tmux session
          Start session in a directory
          Start a tmuxinator project
> Del: Kill tmux session / Stop tmuxinator project
> Ctrl-]: Rename a session
'"
binds="--bind \"$fzf_binds\" --bind \"$del_bind\" --bind \"$rename_bind\""
prompt="--prompt ' Tmux Sessions > '"
fzf_transform=' --bind "?:transform:$TRANSFORMER"'
layout=$([[ -n ${TMUX} ]] && echo "--tmux center,40%,50%,border-native --margin 0 --reverse" || echo "--height 70% --layout=reverse --margin 15%,15%")

fzf_cmd="fzf --style full"
[ -n "$info" ] && fzf_cmd+=" $info"
[ -n "$border" ] && fzf_cmd+=" $border"
[ -n "$color_label" ] && fzf_cmd+=" $color_label"
[ -n "$color_border" ] && fzf_cmd+=" $color_border"
[ -n "$header_first" ] && fzf_cmd+=" $header_first"
[ -n "$header" ] && fzf_cmd+=" $header"
[ -n "$color_header" ] && fzf_cmd+=" $color_header"
[ -n "$binds" ] && fzf_cmd+=" $binds"
[ -n "$prompt" ] && fzf_cmd+=" $prompt"
[ -n "$fzf_transform" ] && fzf_cmd+=" $fzf_transform"
[ -n "$layout" ] && fzf_cmd+=" $layout"

tmux_attach_start() {
	local session="$1"
	local mode="$2"
	local tmux_action=""
	tmux_action=$([[ -n ${TMUX} ]] && echo "switch-client" || echo "attach-session")
	local tmux_sessions=$(get_tmux_sessions)
	local tmuxinator_projects="tmuxinator list | tail -n +2"

	# if its an existing session then attach to it
	if [[ $tmux_sessions =~ (^|[[:space:]])$session($|[[:space:]]) ]]; then
		tmux "$tmux_action" -t "$session"
	# check if its a tmuxinator project and start it
	elif [[ $(eval "$tmuxinator_projects") =~ (^|[[:space:]])$session($|[[:space:]]) ]]; then
		tmuxinator start "$session"
	else
    # selection=$(get_zoxide_dirs |while read -r line; do echo   $line; done| SHELL="$shell" eval "$fzf_cmd -d ' ' --accept-nth 2")
		if [[ $(get_zoxide_dirs  | tr '\n' ' ') =~ (^|[[:space:]])$session($|[[:space:]]) ]]; then
			session_dir=$(echo "$session" | awk -F '/' '{print $(NF-1)"/"$NF}')
			cmd="zoxide query $session_dir"
			session_dir=$(eval "$cmd")
			session=$(basename "$session_dir")
			if [[ $(echo "$tmux_sessions" | tr '\n' ' ') =~ (^|[[:space:]])$session($|[[:space:]]) ]]; then
				tmux "$tmux_action" -t "$session"
			else
				cd "$session_dir" || echo "$session_dir can't be accessed"
			fi
		fi
		# its a new session that user has entered as query, so lets create and switch to it
		if [[ "$mode" == "term" ]]; then
			create_session "$session"
		else
			tmux new-session -d -s "$session" 2>/dev/null && tmux "$tmux_action" -t "$session"
		fi

	fi
}

create_session() {
	local session="$1"
	echo -n "No existing session found with name '$session'. Do you want to create a new session? (y/n): "
	read -r -n 1 response
	response=${response:-Y}
	if [[ "$response" =~ ^[Yy]$ ]]; then
		echo -e "\nCreating new session named '$session'"
		tmux new-session -d -s "$1" && tmux "$tmux_action" -t "$session"
	else
		echo -e "\nSession creation aborted."
	fi
}
handler_request() {
	local session=""
	# if session name is passed as argument, then directly attach to it
	if [[ -n "$1" ]]; then
		tmux_attach_start "$1" "term"
		return
	else
		# tmux_sessions=$(get_tmux_sessions | while read -r line; do echo    $line; done)
		tmux_sessions=$(get_tmux_sessions)
		if [[ -z "$TMUX" && -z $tmux_sessions ]]; then
      # selection=$(get_zoxide_dirs |while read -r line; do echo    $line; done| SHELL="$shell" eval "$fzf_cmd --prompt ' Zoxide > ' -d ' ' --accept-nth 2")
      selection=$(get_zoxide_dirs | SHELL="$shell" eval "$fzf_cmd --prompt ' Zoxide > ' -d ' ' --accept-nth 1")
      [[ -z $selection ]] && return
      session_dir=$(echo "$selection" | awk -F '/' '{print $(NF-1)"/"$NF}')
      cmd="zoxide query $session_dir"
      session_dir=$(eval "$cmd")
      session=$(basename "$session_dir")
      cd "$session_dir" || exit
      tmux new-session -s "$session"
      return
			# echo "No existing tmux sessions found, creating new session 'default'"
			# tmux new-session -s default
		fi
		shell=$(which bash)
		# get the selection from fzf
		selection=$(echo -n -e "$tmux_sessions"  | SHELL="$shell" eval "$fzf_cmd -d ' ' --accept-nth 1")
		if [[ -n $selection ]]; then
			tmux_attach_start "$selection" "fzf"
		fi
	fi
}

if [[ $# -gt 1 ]]; then
	echo "Invalid use of command, Usage: \"$0\" [session-name]"
	return
fi

handler_request "$@"
