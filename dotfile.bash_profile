_complete_ssh_hosts () {
        COMPREPLY=()
        cur="${COMP_WORDS[COMP_CWORD]}"
        comp_ssh_hosts=`cat ~/.ssh/known_hosts | \
                        cut -f 1 -d ' ' | \
                         sed -e s/,.*//g | \
                         grep -v ^# | \
                         uniq | \
                         grep -v "\[" ;
                         cat ~/.ssh/config | \
                         grep --color=never "^Host " | \
                         awk '{print $2}'
                   `
        COMPREPLY=( $(compgen -W "${comp_ssh_hosts}" -- $cur))
        return 0
}
[[ -r "$HOME/.bashrc" ]] && . "$HOME/.bashrc"
umask 022
set -o vi
alias ls="ls --color=tty -F"
alias ag="rg"
alias vim="nvim"
alias k="kubectl"

if [[ -s "$HOME/.rvm/scripts/rvm" ]];then
    source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
fi

shopt -s cdspell
shopt -s checkwinsize
shopt -s cmdhist
shopt -s histappend
shopt -s checkhash
shopt -s no_empty_cmd_completion
shopt -s execfail

##############
# Homedir
##############

C_INCLUDE_PATH="$HOME/include:$C_INCLUDE_PATH"
LIBRARY_PATH="$HOME/lib:$LIBRARY_PATH"
LD_LIBRARY_PATH="$HOME/lib:$LD_LIBRARY_PATH"
PKG_CONFIG_PATH="$HOME/lib/pkgconfig:$PKG_CONFIG_PATH"
export C_INCLUDE_PATH LIBRARY_PATH LD_LIBRARY_PATH PKG_CONFIG_PATH

##############
# PATH
##############

PATH=$PATH:/opt/homebrew/bin
PATH="$HOME/bin:$PATH"
PATH=$PATH:/Users/jarv/bin
PATH=$PATH:$HOME/workspace/gitlab-com-infrastructure/bin
PATH=/Users/jarv/Downloads/gcloud/google-cloud-sdk/bin:$PATH
PATH=$PATH:~/.kube/plugins/jordanwilson230
PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
PATH="$HOME/.cargo/bin:$PATH"
export PATH
[[ -r '/Users/jarv/Downloads/gcloud/google-cloud-sdk/path.bash.inc' ]] && . '/Users/jarv/Downloads/gcloud/google-cloud-sdk/path.bash.inc'
export GOPATH="/Users/jarv/go"

##################
# Bash Completions
##################

source <(kubectl completion bash)
[[ -r "$(brew --prefix bash-completion@2)/etc/profile.d/bash_completion.sh" ]] && . "$(brew --prefix bash-completion@2)/etc/profile.d/bash_completion.sh"
[[ -r '/Users/jarv/Downloads/gcloud/google-cloud-sdk/completion.bash.inc' ]] && . '/Users/jarv/Downloads/gcloud/google-cloud-sdk/completion.bash.inc'
[[ -r '/Users/jarv/lib/azure-cli/az.completion' ]] && . '/Users/jarv/lib/azure-cli/az.completion'

##################
# Git Prompt
##################

  if [ -r "$(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh" ]; then
  GIT_PROMPT_ONLY_IN_REPO=0
  GIT_PROMPT_FETCH_REMOTE_STATUS=0   # uncomment to avoid fetching remote status
  GIT_PROMPT_IGNORE_SUBMODULES=1 # uncomment to avoid searching for changed files in submodules
    GIT_PROMPT_THEME=Solarized # use theme optimized for solarized color scheme
  __GIT_PROMPT_DIR=$(brew --prefix)/opt/bash-git-prompt/share
  . "$(brew --prefix)/opt/kube-ps1/share/kube-ps1.sh"
  kubeoff
  GIT_PROMPT_END=' $(kube_ps1)\n$ '
  . "$(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh"
fi

##############
# Bash History
##############

HISTFILESIZE=10000
HISTDIR="$HOME/.bash_histories/$(uname -n)"
[[ ! -d $HISTDIR ]] && mkdir -p "$HISTDIR"
HISTFILE="$HISTDIR/$(date +%Y_%m)"
# Suppress duplicates, bare "ls" and bg,fg and exit
HISTIGNORE="&:ls:[bf]g:exit"
export HISTFILESIZE HISTDIR HISTFILE HISTIGNORE
h() {
    ls -tr ~/.bash_histories/*/* | xargs grep -i "$1"
}

#############
# RG
############

if type rg &> /dev/null; then
  FZF_DEFAULT_COMMAND='rg --files'
  FZF_DEFAULT_OPTS='-m --height 50% --border'
  export FZF_DEFAULT_COMMAND FZF_DEFAULT_OPTS
fi

##########
# Git
##########

GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWSTASHSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWUPSTREAM="verbose"
export GIT_PS1_SHOWUNTRACKEDFILES GIT_PS1_SHOWUPSTREAM GIT_PS1_SHOWSTASHSTATE GIT_PS1_SHOWDIRTYSTATE

function git_diff() {
  git diff --no-ext-diff -w "$@" | vim -R -
}

##############
# Misc exports
##############

eval "$(brew shellenv)"
export BASH_SILENCE_DEPRECATION_WARNING=1
# export DOCKER_HOST=unix://$HOME/.colima/docker.sock
SSH_AUTH_SOCK="$(brew --prefix)/var/run/yubikey-agent.sock"
export SSH_AUTH_SOCK
# export SSH_AUTH_SOCK=$HOME/.gnupg/S.gpg-agent.ssh
export VAULT_ADDR=https://vault.ops.gke.gitlab.net
export VAULT_PROXY_ADDR=socks5://localhost:18200
export FZF_DEFAULT_OPTS='--bind ctrl-d:page-down,ctrl-u:page-up'
export GO111MODULE=on
EDITOR=$(which nvim)
VISUAL=$EDITOR
FCEDIT=$EDITOR
PAGER=$(which less)
export EDITOR VISUAL FCEDIT PAGER
LESS="-f-R-P?f[%f]:[STDIN].?m(file %i of %m)?x[Next\: %x]. .?lb [line %lb?L/%L]..?e(END) :?pB [%pB\%]..%t"
RI='--format ansi'
export LESS RI

##############
# rtx (was asdf)
##############

eval "$(/opt/homebrew/bin/rtx activate bash)"

##############
# direnv
##############

eval "$(direnv hook bash)"

##############
# fzf
##############

source "$HOME/.fzf.bash"

complete -F _complete_ssh_hosts ssh
