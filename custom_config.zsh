# vim: set filetype=sh:

#  =================================== Aliases ===================================

alias m="mint "
alias mf="mint format"
alias mb="mint build"
alias mbc="mint build-cfg"
alias mun="mint undeploy"
alias mbd="mint deploy"
alias rfmt="rexec mint format"
alias rbld="rexec mint build"
alias rcfg="rexec mint build-cfg"
alias rundep="rexec mint undeploy"
alias rdep="rexec mint deploy"
alias topo="topology-v3 "

# create folowing aliases only if eza is installed else use ls
if [[ $(command -v eza) ]]; then
	alias ls='eza -I "*pyc*" $eza_params'
	alias lsa='ls --all'
	alias lt='ls -T -L=3'
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
alias h='history 0'
# alias ssh='TERM=xterm-color ssh '
alias xx='exit'
alias ee='$EDITOR ~/.zshrc'
alias c='clear'
alias r='exec zsh'
alias cp='cp -av'
alias md='mkdir -p'
alias hg="h | rg"
alias wh='which '
alias W='wc -l'
alias wich='which '
alias wch='which '
[[ $(command -v nvim) ]] && alias vim='nvim'; alias vi='nvim'
[[ -f ~/nvim-macos-arm64/bin/nvim ]] && alias nnvim='~/nvim-macos-arm64/bin/nvim'
[[ $(command -v rg) ]] && alias grep='rg '; alias G='rg '
[[ $(command -v zoxide) ]] && alias cd='z'
[[ $(command -v bat) ]] && alias bat='bat --style=snip --color=always'; alias cat='bat'; alias less='bat -p'
[[ $(command -v gh) ]] &&  alias ghc='gh copilot explain '; alias ghcs='gh copilot suggest '
[[ $(command -v tmuxinator) ]] && alias mux="tmuxinator "
if [[ $(command -v fd) ]]; then 
    fd_bin=$(which fd)
    alias fda='$fd_bin --unrestricted --hidden'  # all files version
    alias fd="fd --ignore-file ~/.global_gitignore"
fi
[[ $(command -v dust) ]] && alias du='dust -prb'

# git aliases
alias gg='lazygit'
alias g="git "
alias ga='git add '
alias gco='git co '
alias gcb='git cb '
alias gcom='git checkout master'
alias gcm='git commit -a -m '
alias gcma='git commit --amend '
alias gs='git status'
alias gb='git branch '
alias gba='git branch -a'
# diff commands
alias gd='git diff'
alias gdf='git diff --name-status'
alias gsd='git show --pretty="" --name-status ' # show changes for a commit

# push/pull
alias gpl='git pull'
alias gps='git push '

# log/reflog
alias gl="git log --graph --color=always --abbrev-commit --pretty=format:'%C(auto)%h%C(auto)%d %s %C(green)(%ar) %C(bold blue)[%al]'"
alias gla="git log --graph --all --color=always --abbrev-commit --pretty=format:'%C(auto)%h%C(auto)%d %s %C(green)(%ar) %C(bold blue)[%al]'"
# alias grf='git reflog '
alias grf='git reflog --date=local'

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
alias zz='z -'
alias cm='chezmoi'
alias cmcd='chezmoi cd'
alias mvim="NVIM_APPNAME=nvim-minimal nvim"
alias tvim="NVIM_APPNAME=lazyvim-test nvim"

# typo prone aliases
alias ks="ls"

alias ssh='fssh'
alias s='fssh'
alias man='fman'
alias vims="nvim_conf_switcher"
alias tm='tmux_sessions'

zle -N cd_up_widget
bindkey -M emacs '^[[1;3A' cd_up_widget
bindkey -M vicmd '^[[1;3A' cd_up_widget
bindkey -M viins '^[[1;3A' cd_up_widget

zle -N tm_widget 
bindkey '^[,' tm_widget
bindkey -M vicmd '^[,' tm_widget
bindkey -M viins '^[,' tm_widget

source $HOME/fzf_config.zsh
