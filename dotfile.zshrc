umask 022
bindkey -v # vi mode

alias ls="ls --color=tty -F"
alias ag="rg"
alias vim="nvim"
alias k="kubectl"

###########
# Zsh options (bash shopt equivalents)
###########
setopt AUTO_CD
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt CORRECT # like cdspell
setopt CHECK_JOBS
unsetopt NOMATCH # avoid "no matches found" errors

###########
# PATH
###########
PATH=$PATH:/opt/homebrew/bin
PATH="$HOME/bin:$PATH"
PATH=$PATH:$HOME/bin
PATH=$PATH:$HOME/.local/bin
PATH=$PATH:~/.kube/plugins/jordanwilson230
PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
PATH="$HOME/.cargo/bin:$PATH"
PATH="$HOME/.atuin/bin/env:$PATH"
PATH="$HOME/.local/bin:$PATH"
export PATH

[[ -r '/Users/jarv/Downloads/gcloud/google-cloud-sdk/path.zsh.inc' ]] && . '/Users/jarv/Downloads/gcloud/google-cloud-sdk/path.zsh.inc'

###########
# Completion (native zsh)
###########
autoload -Uz compinit
compinit

# gcloud / azure
[[ -r '/Users/jarv/Downloads/gcloud/google-cloud-sdk/completion.zsh.inc' ]] && . '/Users/jarv/Downloads/gcloud/google-cloud-sdk/completion.zsh.inc'
[[ -r '/Users/jarv/lib/azure-cli/az.completion' ]] && . '/Users/jarv/lib/azure-cli/az.completion'

# ssh host completion
zstyle ':completion:*:(ssh|scp|sftp|rsync):*' hosts \
  $(awk '{print $1}' ~/.ssh/known_hosts 2>/dev/null | sed 's/,.*//' | grep -v '^\[' | uniq) \
  $(grep -i '^Host ' ~/.ssh/config 2>/dev/null | awk '{for(i=2;i<=NF;i++) print $i}')

###########
# Prompt
###########
eval "$(starship init zsh)"

###########
# History
###########
HISTFILESIZE=10000
HISTSIZE=10000
HISTDIR="$HOME/.zsh_histories/$(uname -n)"
[[ ! -d $HISTDIR ]] && mkdir -p "$HISTDIR"
HISTFILE="$HISTDIR/$(date +%Y_%m)"
export HISTFILESIZE HISTDIR HISTFILE

HISTIGNORE="ls:fg:bg:exit"
setopt HIST_IGNORE_ALL_DUPS
setopt EXTENDED_HISTORY

h() {
  ls -tr ~/.zsh_histories/*/* ~/.bash_histories/*/* | xargs grep -i "$1"
}

###########
# fzf / rg defaults
###########
if type rg &>/dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files'
  export FZF_DEFAULT_OPTS='-m --height 50% --border'
fi
export FZF_DEFAULT_OPTS='--bind ctrl-d:page-down,ctrl-u:page-up'

###########
# Git helpers
###########
git_diff() {
  git diff --no-ext-diff -w "$@" | vim -R -
}

git-cd() {
  if git rev-parse --show-toplevel >/dev/null 2>&1; then
    cd "$(git rev-parse --show-toplevel)"
  else
    echo "Not in a Git repository."
  fi
}

#########
# kube ctx reset
#########

kubectx-reset() {
  kubectl config unset current-context
}

###########
# Misc exports
###########
if command -v brew >/dev/null 2>&1; then
  eval "$(brew shellenv)"
fi

if command -v yubikey-agent >/dev/null 2>&1; then
  SSH_AUTH_SOCK="$(brew --prefix)/var/run/yubikey-agent.sock"
elif [[ "$OSTYPE" == "linux-gnu"* ]] && [[ -S "$XDG_RUNTIME_DIR/ssh-agent.socket" ]]; then
  SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
fi

export SSH_AUTH_SOCK

export VAULT_ADDR=https://vault.ops.gke.gitlab.net
export VAULT_PROXY_ADDR=socks5://localhost:18200
export GO111MODULE=on

EDITOR=$(which nvim)
VISUAL=$EDITOR
FCEDIT=$EDITOR
PAGER=$(which less)
export EDITOR VISUAL FCEDIT PAGER

LESS="-f-R-P?f[%f]:[STDIN].?m(file %i of %m)?x[Next\: %x]. .?lb [line %lb?L/%L]..?e(END) :?pB [%pB\%]..%t"
RI='--format ansi'
export LESS RI
###########
# mise, direnv, atuin (zsh versions)
###########
command -v mise >/dev/null && eval "$(mise activate zsh)"
command -v direnv >/dev/null && eval "$(direnv hook zsh)"
command -v atuin >/dev/null && eval "$(atuin init zsh --disable-up-arrow)"

# kubectl
command -v kubectl >/dev/null && source <(kubectl completion zsh)

###########
# fzf
###########
if [[ ! "$PATH" == */opt/homebrew/opt/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/opt/homebrew/opt/fzf/bin"
fi

# ###########
# # Predictive completions
# ###########
#
# # zsh-autosuggestions (predictive ghost text from history)
# if [[ -r /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
# 	source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
# 	ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8' # dim gray for suggestions
# fi
#
# # zsh-syntax-highlighting (color commands as you type)
# if [[ -r /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
# 	source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# fi
#
# # Key bindings for accepting suggestions
# bindkey '^ ' autosuggest-accept                # Ctrl+Space accepts full suggestion
# bindkey '^P' history-beginning-search-backward # Up (like fish shell)
# bindkey '^N' history-beginning-search-forward  # Down (like fish shell)
