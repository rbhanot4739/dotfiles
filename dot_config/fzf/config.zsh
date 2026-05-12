# vim:set ft=sh :
# Main fzf config: defaults, completers, wrappers, and git pickers.

source "$HOME/.config/fzf/common.zsh"

find_all_cmd="fd --ignore-file ~/.ignore --follow ."
find_files_cmd="$find_all_cmd --type file"
find_dirs_cmd="$find_all_cmd --type directory"
export FZF_DEFAULT_COMMAND="$find_all_cmd"

# Load theme once at startup.
_fzf_theme_opts_str=""
theme_opts=()
source "$HOME/.config/themes/lib/resolve-theme.sh"
_fzf_theme_file="$HOME/.config/themes/generated/fzf/${THEME}-${BG_MODE}.sh"
if [[ -f "$_fzf_theme_file" ]]; then
  source "$_fzf_theme_file"
elif [[ -f "$HOME/.config/themes/generated/fzf/${THEME}.sh" ]]; then
  source "$HOME/.config/themes/generated/fzf/${THEME}.sh"
fi
(( ${#theme_opts[@]} )) && _fzf_theme_opts_str="${(j: :)theme_opts}"

# Shared keybinds; context-specific binds are added below.
FZF_SHARED_KEYBINDS="\
--bind='tab:down,shift-tab:up' \
--bind='alt-s:select+down,alt-d:deselect+up' \
--bind='alt-g:toggle-all' \
--bind='alt-p:toggle-preview' \
--bind='alt-w:change-preview-window(${FZF_UNIFIED_PREVIEW_WINDOW}|down,40%,border-top,wrap|hidden)'"

# File/dir-only bind.
FZF_FILE_KEYBIND_EDIT="--bind=ctrl-v:execute(nvim {})+abort"

# Keep header color consistent across themes.
export FZF_DEFAULT_OPTS="--ansi --cycle --style full --info=inline-right --height ~50% --margin 1,2 --layout=reverse --border rounded --prompt '${FZF_UNIFIED_PROMPT}' --pointer '${FZF_UNIFIED_POINTER}' --color='label:${FZF_UNIFIED_LABEL_COLOR}' ${FZF_SHARED_KEYBINDS} ${_fzf_theme_opts_str} --color='header:${FZF_UNIFIED_HEADER_COLOR}'"
export FZF_COMPLETION_OPTS="${FZF_DEFAULT_OPTS}"
export FZF_COMPLETION_PATH_OPTS="--multi --preview-window '${FZF_UNIFIED_PREVIEW_WINDOW}'"
export FZF_COMPLETION_DIR_OPTS="--multi --preview-window '${FZF_UNIFIED_DIR_PREVIEW_WINDOW}'"
export FZF_COMPLETION_TRIGGER=","

# Per-context option arrays shared by ctrl-t/alt-c and _fzf_comprun.
# Chrome (`--header-first` + start: bind) lives in common.zsh as `_FZF_COMMON_CHROME`.
file_opts_arr=(
  --border-label 'Fuzzy Find Files'
  --ghost "$FZF_GHOST_FILES"
  --header "$FZF_UNIFIED_HEADER_FILE"
  "${_FZF_COMMON_CHROME[@]}"
  --preview "$FZF_UNIFIED_COMPLETION_FILE_PREVIEW"
  --preview-window "$FZF_UNIFIED_PREVIEW_WINDOW"
  --bind "alt-i:reload(${FZF_UNIFIED_HIDDEN_TOGGLE_FILE_CMD})"
  $FZF_FILE_KEYBIND_EDIT
)

dir_opts_arr=(
  --border-label "Fuzzy Find Dirs"
  --ghost "$FZF_GHOST_DIRS"
  --header "$FZF_UNIFIED_HEADER_DIR"
  "${_FZF_COMMON_CHROME[@]}"
  --preview "$FZF_UNIFIED_COMPLETION_DIR_PREVIEW"
  --preview-window "$FZF_UNIFIED_DIR_PREVIEW_WINDOW"
  --bind "alt-i:reload(${FZF_UNIFIED_HIDDEN_TOGGLE_DIR_CMD})"
)

mixed_opts_arr=(
  --border-label "Fuzzy Files/Dirs"
  --ghost "$FZF_GHOST_MIXED"
  --header "$FZF_UNIFIED_HEADER_FILE"
  "${_FZF_COMMON_CHROME[@]}"
  --preview "$FZF_UNIFIED_COMPLETION_FILE_PREVIEW"
  --preview-window "$FZF_UNIFIED_PREVIEW_WINDOW"
  --bind "alt-i:reload(${FZF_UNIFIED_HIDDEN_TOGGLE_ALL_CMD})"
  $FZF_FILE_KEYBIND_EDIT
)

env_opts_arr=(
  --header "$FZF_UNIFIED_HEADER_ENV"
  "${_FZF_COMMON_CHROME[@]}"
  --ghost "$FZF_GHOST_ENV"
  --preview "eval 'echo \$'{}"
)

man_opts_arr=(
  --header "$FZF_UNIFIED_HEADER_MAN"
  "${_FZF_COMMON_CHROME[@]}"
  --ghost "$FZF_GHOST_MAN"
  --preview 'tldr --color=always {} 2>/dev/null'
)

file_opts_str="${(j: :)${(@q)file_opts_arr}}"
dir_opts_str="${(j: :)${(@q)dir_opts_arr}}"
export FZF_CTRL_T_COMMAND="$find_files_cmd"
export FZF_CTRL_T_OPTS="${FZF_DEFAULT_OPTS} ${file_opts_str}"
export FZF_ALT_C_COMMAND="$find_dirs_cmd"
export FZF_ALT_C_OPTS="${FZF_DEFAULT_OPTS} ${dir_opts_str}"
export FZF_CTRL_R_OPTS="${FZF_DEFAULT_OPTS} --ghost '$FZF_GHOST_HISTORY' --preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"

# fzf-trigger candidate generators (`,<TAB>`).
_fzf_compgen_path() {
  if [[ "$1" == "." ]]; then
    command fd --ignore-file ~/.ignore --follow . --strip-cwd-prefix=always
  else
    command fd --ignore-file ~/.ignore --follow . "$1"
  fi
}
_fzf_compgen_dir() {
  if [[ "$1" == "." ]]; then
    command fd --ignore-file ~/.ignore --follow --type directory . --strip-cwd-prefix=always
  else
    command fd --ignore-file ~/.ignore --follow --type directory . "$1"
  fi
}

_fzf_complete_man() {
  _fzf_complete +m -- "$@" < <(__fzf_list_man_pages)
}

# Restrict cat/bat trigger completion to files.
_fzf_complete_cat() {
  _fzf_complete -- "$@" < <(command fd --ignore-file ~/.ignore --follow --type file . --strip-cwd-prefix=always)
}
_fzf_complete_bat() { _fzf_complete_cat "$@"; }

# Keep export/unset trigger completion aligned with tab completion.
__fzf_complete_env_vars() {
  _fzf_complete -m -- "$@" < <(__fzf_list_env_vars)
}
_fzf_complete_export() { __fzf_complete_env_vars "$@"; }
_fzf_complete_unset()  { __fzf_complete_env_vars "$@"; }

# fzf wrapper: re-load active theme for new pickers after theme switch.
fzf() {
  local -a default_opts=(--height 60% --multi)
  local -a theme_opts
  source "$HOME/.config/themes/lib/resolve-theme.sh"
  local _gen_fzf="$HOME/.config/themes/generated/fzf"

  if [[ -f "${_gen_fzf}/${THEME}-${BG_MODE}.sh" ]]; then
    set -o noglob; source "${_gen_fzf}/${THEME}-${BG_MODE}.sh"; set +o noglob
  elif [[ -f "${_gen_fzf}/${THEME}.sh" ]]; then
    set -o noglob; source "${_gen_fzf}/${THEME}.sh"; set +o noglob
  fi

  command fzf "${default_opts[@]}" "${theme_opts[@]}" --color="header:${FZF_UNIFIED_HEADER_COLOR}" "$@"
}

# Git pickers.
_GIT_FZF_PICKER_HEIGHT='68%'
_GIT_FZF_PICKER_PREVIEW_WINDOW='down,60%,border-top,wrap'
# Log format and tag canonicalization regex are shared with `gl`/`gla` (common.zsh).

_git_require_repo() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    echo "Not inside a git repository." >&2
    return 1
  }
}

# Emit a fzf --preview script that shows " <canonical tag>" followed by a graph log.
# $1 = "branch" (uses {3} as a ref) or "worktree" (uses {3} as a directory).
# Reads _GIT_LOG_PRETTY_BASE and _GIT_TAG_CANON_ERE from common.zsh.
_git_fzf_log_preview() {
  local kind="$1"
  local placeholder gitc commitish missing_check missing_msg log_target_arg
  if [[ "$kind" == "worktree" ]]; then
    placeholder='wt_path'
    gitc='git -C "$wt_path"'
    commitish='"HEAD^{commit}"'
    missing_check='[ -z "$wt_path" ] || [ ! -d "$wt_path" ]'
    missing_msg='Worktree not found: ${wt_path}'
    log_target_arg=''
  else
    placeholder='target'
    gitc='git'
    commitish='"${target}^{commit}"'
    missing_check='[ -z "$target" ]'
    missing_msg='No commit metadata available'
    log_target_arg=' "${oid}"'
  fi
  cat <<PVW
${placeholder}={3};
if ${missing_check}; then echo "${missing_msg}"; exit 0; fi
oid=\$(${gitc} rev-parse --verify --quiet ${commitish} 2>/dev/null || true);
if [ -z "\$oid" ]; then echo "No commit found"; exit 0; fi
tag=\$(${gitc} describe --tags --exact-match "\${oid}" 2>/dev/null || true);
[ -z "\$tag" ] && tag=\$(${gitc} describe --tags --abbrev=0 "\${oid}" 2>/dev/null || true);
[ -z "\$tag" ] && tag=\$(${gitc} for-each-ref --merged="\${oid}" --sort=-creatordate --count=1 --format='%(refname:short)' refs/tags 2>/dev/null);
[ -z "\$tag" ] && tag=\$(${gitc} for-each-ref --sort=-creatordate --count=1 --format='%(refname:short)' refs/tags 2>/dev/null);
if [ -n "\$tag" ]; then
  canon=\$(printf '%s' "\$tag" | sed -nE 's,.*(${_GIT_TAG_CANON_ERE}),v\\1,p');
  [ -n "\$canon" ] && tag="\$canon";
  echo " \${tag}";
  echo;
fi
${gitc} log --graph --color=always --abbrev-commit --max-count=25 --pretty=format:'${_GIT_LOG_PRETTY_BASE}'${log_target_arg}
PVW
}

_git_branch_rows() {
  local scope="${1:-local}"
  local -a refs=(refs/heads)
  [[ "$scope" == "all" ]] && refs+=(refs/remotes)

  git for-each-ref --sort=-committerdate \
    --format=$'%(refname)\t%(refname:short)\t%(committerdate:relative)' \
    "${refs[@]}" \
  | awk -F '\t' 'BEGIN{OFS="\t"} {
      full_ref=$1
      short_ref=$2
      display=short_ref
      if (index(full_ref, "refs/remotes/") == 1) {
        if (length(short_ref) >= 5 && substr(short_ref, length(short_ref) - 4) == "/HEAD") next
        slash=index(short_ref, "/")
        if (slash > 0) {
          remote=substr(short_ref, 1, slash - 1)
          branch=substr(short_ref, slash + 1)
          display=branch " (" remote ")"
        }
      }
      n++
      disp[n]=display
      ref[n]=short_ref
      age[n]=$3
      if (length(display) > maxw) maxw=length(display)
    }
    END {
      for (i=1; i<=n; i++) {
        visible=sprintf("%-" maxw "s", disp[i])
        print visible, age[i], ref[i]
      }
    }'
}

_git_switch_selected_ref() {
  local ref="$1"
  if git show-ref --verify --quiet "refs/remotes/$ref"; then
    local local_branch="${ref#*/}"
    if git show-ref --verify --quiet "refs/heads/$local_branch"; then
      git switch "$local_branch"
    else
      git switch --track -c "$local_branch" "$ref"
    fi
  else
    git switch "$ref"
  fi
}

_git_fzf_switch_branch() {
  local scope="${1:-local}"
  _git_require_repo || return 1

  local row ref
  row=$(
    _git_branch_rows "$scope" \
      | fzf --delimiter=$'\t' --with-nth=1,2 --nth=1 \
             --prompt='branch> ' \
             --height="${_GIT_FZF_PICKER_HEIGHT}" \
             --border-label 'Git Branches' \
             --ghost 'Search branches…' \
             --preview-window "${_GIT_FZF_PICKER_PREVIEW_WINDOW}" \
             --preview "$(_git_fzf_log_preview branch)"
  ) || return

  ref="${${row#*$'\t'}#*$'\t'}"
  [[ -n "$ref" ]] && _git_switch_selected_ref "$ref"
}

gbf() { _git_fzf_switch_branch local; }
gbfa() { _git_fzf_switch_branch all; }

_git_worktree_rows() {
  git worktree list --porcelain \
    | awk '
        BEGIN { OFS="\t"; path=""; branch="(detached)"; home=ENVIRON["HOME"] }
        function flush_row() {
          if (path == "") return

          display_path=path
          if (home != "") {
            if (path == home) {
              display_path="~"
            } else if (index(path, home "/") == 1) {
              display_path="~" substr(path, length(home) + 1)
            }
          }

          branch_disp=" " branch
          path_disp="󰉋 " display_path

          n++
          dp[n]=path_disp
          b[n]=branch_disp
          rp[n]=path

          if (length(path_disp) > pmax) pmax=length(path_disp)
          if (length(branch_disp) > bmax) bmax=length(branch_disp)
        }
        /^worktree / { flush_row(); path=substr($0, 10); branch="(detached)"; next }
        /^branch /   { branch=$2; sub("^refs/heads/", "", branch); next }
        END {
          flush_row()
          for (i=1; i<=n; i++) {
            print sprintf("%-" (pmax + 3) "s", dp[i]), sprintf("%-" bmax "s", b[i]), rp[i]
          }
        }
      '
}

gwt() {
  _git_require_repo || return 1

  local row worktree_path
  row=$(
    _git_worktree_rows \
      | fzf --delimiter=$'\t' --with-nth=1,2 --nth=1,2 \
             --prompt='worktree> ' \
             --height="${_GIT_FZF_PICKER_HEIGHT}" \
             --border-label 'Git Worktrees' \
             --ghost 'Search worktrees…' \
             --preview-window "${_GIT_FZF_PICKER_PREVIEW_WINDOW}" \
             --preview "$(_git_fzf_log_preview worktree)"
  ) || return

  worktree_path="${row##*$'\t'}"
  [[ -n "$worktree_path" ]] && cd "$worktree_path"
}

# fzf-trigger UI dispatcher by command.
_fzf_comprun() {
  local command=$1
  shift
  case "$command" in
    cd | z)            command fzf "${dir_opts_arr[@]}"   "$@" ;;
    bat | cat)         command fzf "${file_opts_arr[@]}"  "$@" ;;
    ls | eza)          command fzf "${mixed_opts_arr[@]}" "$@" ;;
    export | unset)    command fzf "${env_opts_arr[@]}"   "$@" ;;
    man)               command fzf "${man_opts_arr[@]}"   "$@" ;;
    *)                 command fzf "$@" ;;
  esac
}
