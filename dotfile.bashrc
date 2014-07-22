# .bashrc

umask 022
# Generate a random password
#  $1 = number of characters; defaults to 32
#  $2 = include special characters; 1 = yes, 0 = no; defaults to 1
function gen_passwd() {
    CHAR="[:alnum:]"
    cat /dev/urandom | tr -cd "$CHAR" | head -c ${1:-16}
    echo
}
join_dirs()
{
    for STRING in $*; do
        [[ -d $STRING ]] && JOINED=$JOINED:$STRING
    done

    echo $JOINED | sed -e 's/^://'
}

PATHDIRS=(
    /usr/local/bin
    /usr/local/sbin
)

PATH=`join_dirs ${PATHDIRS[*]}`:$PATH
unset PATHDIRS

case `uname -s` in
    [Ll]inux)
        TERM="xterm-256color"
        ;;
    Darwin)
        ;;
    SunOS)
        ;;
esac

# Pretty ls colors
[[ -n "`ls --version 2> /dev/null`" ]] && alias ls=`which ls`" --color=tty -F"
[[ -x "`which dircolors`" ]] && eval `dircolors`
# alias vim="vim -p --servername $HOSTNAME"
EDITOR=`which vim`
VISUAL=$EDITOR
FCEDIT=$EDITOR
PAGER=`which less`
FIGNORE=.o:~

LESS="-f-R-P?f[%f]:[STDIN].?m(file %i of %m)?x[Next\: %x]. .?lb [line %lb?L/%L]..?e(END) :?pB [%pB\%]..%t"
RI='--format ansi'
GREP_OPTIONS='--color=auto --exclude-dir=.git'

# Source the completion file, if it exists
if [ -f /etc/bash_completion ]; then 
    . /etc/bash_completion
    # Add hostname completion to some new programs
    complete -F _known_hosts xvncviewer nc  
fi

if [ "$BASH_VERSINFO" -ge 2 ]; then
    shopt -s cdspell
    shopt -s checkwinsize
    shopt -s cmdhist
    shopt -s histappend
    shopt -s checkhash
    shopt -s no_empty_cmd_completion
    shopt -s execfail

    HISTFILESIZE=10000
    HISTDIR="$HOME/.bash_histories/`uname -n`"
    [[ ! -d $HISTDIR ]] && mkdir -p "$HISTDIR"
    HISTFILE="$HISTDIR/`date +%Y_%m`"
    # Suppress duplicates, bare "ls" and bg,fg and exit
    HISTIGNORE="&:ls:[bf]g:exit"
fi

# Colors and PS1
_NORM="\033[0m"
_BLK="\033[0;30m"
_RED="\033[0;31m"
_GRN="\033[0;32m"
_YEL="\033[0;33m"
_BLU="\033[0;34m"
_MAG="\033[0;35m"
_CYN="\033[0;36m"
_WHT="\033[0;37m"

_BBLK="\033[1;30m"
_BRED="\033[1;31m"
_BGRN="\033[1;32m"
_BYEL="\033[1;33m"
_BBLU="\033[1;34m"
_BMAG="\033[1;35m"
_BCYN="\033[1;36m"
_BWHT="\033[1;37m"


PROJ_COLOR="\[${_RED}\]"
GIT_COLOR="\[${_BBLK}\]"

case `uname -n` in
    krusty)
        PAREN_COLOR="\[${_BWHT}\]"
        MC="\[${_RED}\]" # MC is "my" color.  For logname and hostname
        DC="\[${_BLU}\]" # DC is default color.  For everything else
        ;;
    lisa)
        PAREN_COLOR="\[${_BBLU}\]"
        MC="\[${_BYEL}\]"
        DC="\[${_BCYN}\]" 
        ;;

    maggie|terminus)
        PAREN_COLOR="\[${_BLU}\]"
        MC="\[${_BCYN}\]"
        DC="\[${_CYN}\]"
        ;;

    *)
        PAREN_COLOR="\[${_WHT}\]"
        MC="\[${_BCYN}\]"
        DC="\[${_CYN}\]"
        ;;
esac 

# OP is Open Paren
OP="${PAREN_COLOR}("
# CP is Close Paren
CP="${PAREN_COLOR})"
# OB is Open Bracket
OB="${PAREN_COLOR}["
# CB is Close Bracket
CB="${PAREN_COLOR}]"
# RA is Right angle
RA="${PAREN_COLOR}>"
# LA is Left angle
LA="${PAREN_COLOR}<"



# Root Overrides
if [ `id | cut -b5` = 0 ]; then
	MC="\[${_BRED}\]"
fi

PS1HOST="${OP}${MC}\u${DC}@${MC}\h${CP}"
PS1DATE="${OP}${DC}\d${CP}"
PS1TIME="${OP}${DC}\t${CP}"
PS1TTY="${OP}${DC}$(tty)${CP}"
PS1DIR="${OP}${DC}\w${CP}"
PS1RETVAL="${OP}${DC}\${?}${CP}"
PS1END="\[$_NORM\]\r\n\[$_WHT\]\\$ "
for script in $HOME/.bashrc.d/*.bash; do
    source $script
done

# Some things need to be computed.
prompt_cmd() {

    # Compute RETVAL
    FAIL=$?
    if [[ $FAIL -eq 0 ]]; then
        PS1RETVAL="${OP}${DC}0${CP}"
    else
        PS1RETVAL="${OP}\[${_BRED}\]${FAIL}${CP}"
    fi

        #prompt_proj=$(basename $VIRTUAL_ENV)
        #PS1PROJ="${RA}${OP}${PROJ_COLOR}${prompt_proj}${CP}${LA}"
    if type -t workon > /dev/null; then
        V=$(workon)
        joined=''
        for venv in $V; do
            venv="${venv%\\n}"
            if [[ -n $VIRTUAL_ENV ]]; then
                if [[ $venv == $(basename $VIRTUAL_ENV) ]]; then
                    joined="$joined | ${_BBLU}${venv}${_BBLK}"
                else
                    joined="$joined | ${_BLK}${venv}${_BBLK}"
                fi
            else
                joined="$joined | ${_BLK}${venv}${_BBLK}"
            fi
        done
        joined=$(echo $joined | sed -e 's/^| //')
        PS1VENV="$_BBLK[ $joined ${_BBLK}]${_NORM} "
    fi

    GITBRANCH=$(__git_ps1 '%s')
    if [[ $GITBRANCH != '' ]]; then
        PS1GIT="${OB}${GIT_COLOR}${GITBRANCH}${CB}"
    else
        PS1GIT=''
    fi
    if [[ $AWS_NAME != '' ]]; then
        if [[ $AWS_NAME == 'prod' ]];then
            PS1BOTO="$_BLK- ${_RED}<<${_BRED}${AWS_NAME}${_RED}>> $_BBLK-${_NORM}"
        else
            PS1BOTO="$_BBLK- ${_GRN}${AWS_NAME} $_BBLK-${_NORM}"
        fi
    else
        PS1BOTO=''
    fi
    history -a  # Save last user cmd to bash_history
    PS1="${PS1VENV}\n${PS1BOTO}${PS1HOST}${PS1PROJ}${PS1RETVAL}${PS1GIT}${PS1DIR}${PS1END}"
}

PROMPT_COMMAND=prompt_cmd

export PATH PS1 EDITOR VISUAL PAGER LESS FCEDIT SEPATH MANPATH TERM GREP_OPTIONS RI HISTFILESIZE HISTFILE HISTIGNORE

set -o vi

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
