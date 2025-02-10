# shellcheck disable=2034 # ignored as this file only contains var definitions
col_bg=colour229
col_bg0_h=colour230
col_bg0=colour229
col_bg1=colour223
col_bg2=colour250
col_bg3=colour248
col_bg4=colour246
col_gray0=colour246
col_gray1=colour245
col_gray2=colour244
col_bg0_s=colour228
col_fg=colour223
col_fg4=colour243
col_fg3=colour241
col_fg2=colour239
col_fg1=colour237
col_fg0=colour235

col_red=colour124
col_red2=colour88
col_green=colour106
col_green2=colour100
col_yellow=colour172
col_yellow2=colour136
col_blue=colour66
col_blue2=colour24
col_purple=colour132
col_purple2=colour96
col_aqua=colour72
col_aqua2=colour66
col_orange=colour166
col_orange2=colour130

# Dark colors
col_bg=colour235
col_bg0_h=colour234
col_bg0=colour235
col_bg1=colour237
col_bg2=colour239
col_bg3=colour241
col_bg4=colour243
col_gray0=colour246
col_gray1=colour245
col_gray2=colour245
col_bg0_s=colour236
col_fg=colour223
col_fg4=colour246
col_fg3=colour248
col_fg2=colour250
col_fg1=colour223
col_fg0=colour229

col_red=colour124
col_red2=colour167
col_green=colour106
col_green2=colour142
col_yellow=colour172
col_yellow2=colour214
col_blue=colour66
col_blue2=colour109
col_purple=colour132
col_purple2=colour175
col_aqua=colour72
col_aqua2=colour108
col_orange=colour166
col_orange2=colour208

tmux_append_seto() {
  local _option _value _result
  _option="$1"
  _value="$2"
  TMUX_CMDS+=("set-option" "-gq" \""${_option}\"" \""${_value}\"" ";")
}

# append preconfigured tmux set-window-option to global array
tmux_append_setwo() {
  local _option _value _result
  _option="$1"
  _value="$2"
  TMUX_CMDS+=("set-window-option" "-gq" \""${_option}\"" \""${_value}\"" ";")
}


# shellcheck disable=SC2154
theme_set() {
  local _left_status_a _right_status_x _right_status_y _right_status_z _statusbar_alpha
  _left_status_a=$1
  _right_status_x=$2
  _right_status_y=$3
  _right_status_z=$4
  _statusbar_alpha=$5

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
  tmux_append_setwo "window-status-separator" "''"

  tmux_append_seto "status-left" "#[bg=${col_fg2},fg=${col_bg1}] ${_left_status_a} #[bg=${col_bg2},fg=${col_fg2},nobold,noitalics,nounderscore]"

  # right status
  local _status_right_bg=${col_bg2}
  if [[ "$_statusbar_alpha" == "true" ]]; then _status_right_bg="default"; fi
  tmux_append_seto "status-right" "#[bg=${_status_right_bg},fg=${col_fg4},nobold,nounderscore,noitalics]#[bg=${col_fg4},fg=${col_bg1}] ${_right_status_x}  ${_right_status_y} #[bg=${col_fg4},fg=${col_fg2},nobold,noitalics,nounderscore]#[bg=${col_fg2},fg=${col_bg1}] ${_right_status_z}"

  # current window
  local _current_window_status_format_bg=${col_bg2}
  if [[ "$_statusbar_alpha" == "true" ]]; then _current_window_status_format_bg="default"; fi
  tmux_append_setwo "window-status-current-format" "#[bg=${col_yellow},fg=${col_bg2},nobold,noitalics,nounderscore]#[bg=${col_yellow},fg=${col_fg1}] #I #[bg=${col_yellow},fg=${col_fg1},bold] #W#{?window_zoomed_flag,*Z,} #{?window_end_flag,#[bg=${_current_window_status_format_bg}],#[bg=${col_bg2}]}#[fg=${col_yellow},nobold,noitalics,nounderscore]"

  # default window
  local _default_window_status_format_bg=${col_bg2}
  if [[ "$_statusbar_alpha" == "true" ]]; then _default_window_status_format_bg="default"; fi
  tmux_append_setwo "window-status-format" "#[bg=${col_bg3},fg=${col_bg2},noitalics]#[bg=${col_bg3},fg=${col_fg2}] #I #[bg=${col_bg3},fg=${col_fg2}] #W #{?window_end_flag,#[bg=${_default_window_status_format_bg}],#[bg=${col_bg2}]}#[fg=${col_bg3},noitalics]"
}

declare -a TMUX_CMDS
# set -ogq @truncated_path "#(bash $HOME/scripts/truncate_path.sh #{pane_current_path})"
TMUX_CMDS=()
LEFT_STATUS_A='#h'
RIGHT_STATUS_X='%Y-%m-%d'
RIGHT_STATUS_Y="#{E:@truncated_path}"
# RIGHT_STATUS_Y="#I"
RIGHT_STATUS_Z='#S'
ALPHA_STATUS='false'
theme_args=($LEFT_STATUS_A $RIGHT_STATUS_X $RIGHT_STATUS_Y $RIGHT_STATUS_Z $ALPHA_STATUS)
theme_set "${theme_args[@]}"
echo "${TMUX_CMDS[@]}"
