# shellcheck disable=2034 # ignored as this file only contains var definitions
# Dark colors
# col_bg=colour235
# col_bg1=colour237
# col_bg2=colour239
# col_bg3=colour241
# col_fg4=colour246
# col_fg3=colour248
# col_fg2=colour250
# col_fg1=colour223
# col_red2=colour167
# col_yellow=colour172
# col_yellow2=colour214
# col_blue2=colour109

col_bg=#262626      # colour235
col_bg1=#3a3a3a     # colour237
col_bg2=#4e4e4e     # colour239
col_bg3=#626262     # colour241
col_fg4=#b2b2b2     # colour246
col_fg3=#c6c6c6     # colour248
col_fg2=#dadada     # colour250
col_fg1=#ffd7af     # colour223
col_red2=#c14a4a    # colour167
col_yellow=#d78700  # colour172
col_yellow=#d78700  # colour172
col_yellow2=#ffaf00 # colour214
col_blue2=#5fafd7   # colour109
col_orange=#e78a4e
col_green=#a9b665

tmux_append_seto() {

  local _option _value _result
  _option="$1"
  _value="$2"
  TMUX_CMDS+=("set-option" "-gq" \""${_option}\"" \""${_value}\"" "\n")
}

# append preconfigured tmux set-window-option to global array
tmux_append_setwo() {
  local _option _value _result
  _option="$1"
  _value="$2"
  TMUX_CMDS+=("set-window-option" "-gq" \""${_option}\"" \""${_value}\"" "\n")
}


# shellcheck disable=SC2154
theme_set() {
  local _left_status_a _right_status_x _right_status_y _right_status_z _statusbar_alpha
  _left_status_a=$1
  _right_status_y=$2
  _right_status_z=$3
  _statusbar_alpha=$4

  tmux_append_seto "status" "on"

  # default statusbar bg color
  local _statusbar_bg="${col_bg2}"
  if [[ "$_statusbar_alpha" == "true" ]]; then _statusbar_bg="default"; fi
  tmux_append_seto "status-style" "bg=${_statusbar_bg},fg=${col_fg1}"

  # default window title colors
  local _window_title_bg=${col_yellow2}
  if [[ "$_statusbar_alpha" == "true" ]]; then _window_title_bg="default"; fi
  tmux_append_setwo "window-status-style" "bg=${_window_title_bg},fg=${col_bg1}"

  # default window with an activity alert
  tmux_append_setwo "window-status-activity-style" "bg=${col_bg1},fg=${col_fg3}"

  # active window title colors
  local _active_window_title_bg=${col_yellow2}
  if [[ "$_statusbar_alpha" == "true" ]]; then _active_window_title_bg="default"; fi
  tmux_append_setwo "window-status-current-style" "bg=${_active_window_title_bg},fg=${col_bg1}" # TODO cosider removing red!

  # pane border
  tmux_append_seto "pane-active-border-style" "fg=${col_fg2}"
  tmux_append_seto "pane-border-style" "fg=${col_bg1}"

  # message infos
  tmux_append_seto "message-style" "bg=${col_bg2},fg=${col_fg1}"

  # writing commands inactive
  tmux_append_seto "message-command-style" "bg=${col_fg3},fg=${col_bg1}"

  # pane number display
  tmux_append_seto "display-panes-active-colour" "${col_fg2}"
  tmux_append_seto "display-panes-colour" "${col_bg1}"

  # clock
  tmux_append_setwo "clock-mode-colour" "${col_blue2}"

  # bell
  tmux_append_setwo "window-status-bell-style" "bg=${col_red2},fg=${col_bg}"

  ## Theme settings mixed with colors (unfortunately, but there is no cleaner way)
  tmux_append_seto "status-justify" "left"
  tmux_append_seto "status-left-style" none
  tmux_append_seto "status-left-length" "100"
  tmux_append_seto "status-right-style" none
  tmux_append_seto "status-right-length" "100"
  tmux_append_setwo "window-status-separator" ""
  
# left status
tmux_append_seto "status-left" "#[bg=${col_fg4},fg=${col_bg1}] ${_left_status_a} #[bg=${col_bg},fg=${col_fg4},nobold,noitalics,nounderscore] #{?client_prefix,#[bg=${col_green}]#[fg=${col_bg}],}#{?client_prefix,#[bg=${col_green}]#[fg=${col_bg}]#[bold] PREFIX,}#[bg=default]#{?client_prefix,#[fg=${col_green}],}"


  # right status
  local _status_right_bg=${col_bg2}
  if [[ "$_statusbar_alpha" == "true" ]]; then _status_right_bg="default"; fi
tmux_append_seto "status-right" "#[bg=${_status_right_bg},fg=${col_fg4},nobold,nounderscore,noitalics]#{?pane_synchronized,#[fg=${col_red2}],}#{?pane_synchronized,#[bg=${col_red2}]#[fg=${col_fg2}]#[bold] SYNC ,}#{?pane_synchronized,#[fg=${col_bg}],}#[bg=default,fg=${col_bg},nobold,noitalics,nounderscore]#[bg=default,fg=${col_fg4}]#[bg=${col_fg4},fg=${col_bg1}] ${_right_status_y} #[fg=${col_bg2},nobold,noitalics,nounderscore]#[fg=${col_fg2},bg=${col_bg2},bold] ${_right_status_z}"

  # current window
  local _current_window_status_format_bg=${col_bg2}
  if [[ "$_statusbar_alpha" == "true" ]]; then _current_window_status_format_bg="default"; fi
  tmux_append_setwo "window-status-current-format" "#[bg=${col_yellow},fg=${col_bg},nobold,noitalics,nounderscore]#[bg=${col_yellow},fg=${col_bg1}] #I #[bg=${col_yellow},fg=${col_bg1},bold] #W#{?window_zoomed_flag,*Z,} #{?window_end_flag,#[bg=${_current_window_status_format_bg}],#[bg=${col_bg}]}#[fg=${col_yellow},nobold,noitalics,nounderscore]"

  # default window
  local _default_window_status_format_bg=${col_bg2}
  if [[ "$_statusbar_alpha" == "true" ]]; then _default_window_status_format_bg="default"; fi
  tmux_append_setwo "window-status-format" "#[bg=${col_bg3},fg=${col_bg},noitalics]#[bg=${col_bg3},fg=${col_fg2}] #I #[bg=${col_bg3},fg=${col_fg2}] #W #{?window_end_flag,#[bg=${_default_window_status_format_bg}],#[bg=${col_bg}]}#[fg=${col_bg3},noitalics]"

tmux_append_seto "status-justify" "centre"
}

declare -a TMUX_CMDS
# set -ogq @truncated_path "#(bash $HOME/scripts/truncate_path.sh #{pane_current_path})"
TMUX_CMDS=()
LEFT_STATUS_A='#h'
RIGHT_STATUS_Y="#{E:@truncated_path}"
RIGHT_STATUS_Z='#S'
ALPHA_STATUS='true'
theme_args=($LEFT_STATUS_A $RIGHT_STATUS_X $RIGHT_STATUS_Y $RIGHT_STATUS_Z $ALPHA_STATUS)
theme_set "${theme_args[@]}"
echo "# vim:set ft=tmux:\n"
echo "${TMUX_CMDS[@]}"
