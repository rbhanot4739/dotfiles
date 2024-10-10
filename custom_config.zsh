# vim: set filetype=sh:

#  =================================== Functions ===================================
get_hidden_files() {
  if [[ $1 == "long" ]]; then
    local params=('--git' '--group' '--group-directories-first' '--time-style=long-iso' '--color-scale=all' '--icons' '--header')
    if [[ $2 ]]; then
      OLDDIR=$(pwd)
      cd $2
      eza $params --group-directories-first -snew -dl .* 2>/dev/null
      cd $OLDDIR
    else
      eza $params --group-directories-first -snew -dl .* 2>/dev/null
    fi
  else
    if [[ $1 ]]; then
      OLDDIR=$(pwd)
      cd $1
      eza --group-directories-first -snew -d .* 2>/dev/null
      cd $OLDDIR
    else
      eza --group-directories-first -snew -d .* 2>/dev/null
    fi

  fi
}

debug_print() {
  if [[ "$DEBUG" -eq 1 ]]; then
    echo "DEBUG: $@"
  fi
}

mx() {
  /bin/bash $HOME/tmux-sessions.sh $@
  # manage_tmux_sessions $@
}

tm() {
  /bin/bash ~/tmux-manager.sh "$@"
}

zle -N tm
bindkey '^O' tm
# alias mm='__tmux_mgr'

# cd_up() {
#   # some comment
#
#   local num_dots=${#1}
#   # build a pth like ../../../ using a loop based on num_dots
#   local pth=""
#   for ((i = 1; i <= num_dots; i++)); do
#     pth="../$pth"
#   done
#   debug_print $(which cd)
#   debug_print "moving up by $num_dots directories to pth $pth"
#   cd $pth
# }

cd_up_widget() {
  echo "cd_up called"
  cd ..
  zle reset-prompt
  zle accept-line
}

zle -N cd_up_widget
bindkey '' cd_up_widget

#  =================================== Aliases ===================================

# fi

# alias fman="fd -t f . --follow /usr/share/man/ /opt/homebrew/share/man/ | fzf --layout reverse --prompt '∷ ' --pointer ▶ --marker ⇒ --delimiter '/' --with-nth=-1 --height 40% --border=double | xargs man"
alias m="mint "
alias mf="mint format"
alias mb="mint build"
alias mbc="mint build-cfg"
alias mun="mint undeploy"
alias mbd="mint deploy"
alias rfmt="rexec mint format"
alias rbld="rexec mint build"
alias rbld="rexec mint test"
alias rcfg="rexec mint build-cfg"
alias rundep="rexec mint undeploy"
alias rdep="rexec mint deploy"

# create folowing aliases only if eza is installed else use ls
if [[ $(command -v eza) ]]; then
  local eza_params=('--git' '--group' '--group-directories-first' '--time-style=long-iso' '--color-scale=all' '--icons')
  alias ls='eza -I "*pyc*" $eza_params'
  alias lsa='ls --all'
  # alias l='ls --git-ignore'
  # print tree format
  alias lst='ls -T -L=3'
  alias ll='ls --header --long --sort=modified'
  alias l='ll'
  alias lla='ll --all'
  # sort by size
  alias lS='ll --sort=size'
  alias lSa='lla --sort=size'
  alias llA='eza -lbhHigUmuSa'
  alias lsd='ls -D'
  alias lsf='ls -F'
  alias llf='ll -F'
  alias lld='ll -D'
  alias lsh='get_hidden_files '
  alias llh='get_hidden_files long '
fi

# some utility aliases
alias dud='du -d 1 -hc 2> /dev/null | grep -Ev "\.$"|sort -h'
alias h='history 0'
alias ssh='ssh '
alias xx='exit'
alias ee='$EDITOR ~/.zshrc'
alias c='clear'
alias r='exec zsh'
alias cp='cp -av'
alias md='mkdir'
alias hg="h | rg"
alias wh='which '
alias wich='which '
[[ $(command -v nvim) ]] && alias vim='nvim'
[[ $(command -v rg) ]] && alias grep='rg' && alias gr='rg'
[[ $(command -v tmuxinator) ]] && alias mux="tmuxinator "
if [[ $(command -v eza) ]]; then
  alias less='bat'
  alias cat='bat --color always'
fi
if [[ $(command -v gh) ]]; then
  alias ghc='gh copilot explain '
  alias ghcs='gh copilot suggest '
fi

# git aliases
alias lg='lazygit'
alias g="git "
alias ga='git add '
alias gco='git co '
alias gcb='git cb '
alias gcom='git checkout master'
alias gcm='git commit -a -m '
alias gcma='git commit --amend '
alias gs='git status'
alias gb='git branch '
alias gbl='gb -l'
alias gba='gb -a'
# diff commands
alias gd='git diff'
alias gdf='git diff --name-status'
alias gsd='git show --pretty="" --name-status ' # show changes for a commit

# push/pull
alias gpl='git pull'
alias gps='git push '

# log/reflog
alias glg='git log'
alias gl="git log --pretty=format:'%C(auto)%h%d%Creset %s %C(cyan) [%aN] %Creset %C(green)(%ci)%Creset'"
alias gla="git log --pretty=format:'%C(auto)%h%d%Creset %s %C(cyan) [%aN] %Creset %C(green)(%ci)%Creset' --graph --all"
alias grf='git reflog '
alias grfp='git reflog --date=local'

# rebase commmands
alias grb='git rebase '
alias grbi='git rebase -i '
alias grbm='git rebase master'
alias grbc='git rebase --continue '
alias grba='git rebase --abort '
# reset/revert
alias gdk='git restore '
alias grst='git reset '

# vagrant aliases
alias vsh='vagrant ssh'
alias vrel='vagrant reload'

alias dk=docker
alias dkc=docker-compose
# alias .='cd_up .'
# alias ..='cd_up ..'
# alias ...='cd_up ...'
# alias ....='cd_up .....'
# alias .....='cd_up .....'
alias zz='z -'
alias cm='chezmoi'
alias cmcd='chezmoi cd'
