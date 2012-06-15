# .bashrc

umask 022
join_dirs()
{
    for STRING in $*; do
        [[ -d $STRING ]] && JOINED=$JOINED:$STRING
    done

    echo $JOINED | sed -e 's/^://'
}

PATHDIRS=(
    $HOME/bin
    /usr/local/bin
    /usr/local/sbin
)

PATH=`join_dirs ${PATHDIRS[*]}`:$PATH
unset PATHDIRS

case `uname -s` in
    [Ll]inux)
        ;;
    Darwin)
        ;;
    SunOS)
        ;;
esac

# Pretty ls colors
[[ -n "`ls --version 2> /dev/null`" ]] && alias ls=`which ls`" --color=tty -F"
[[ -x "`which dircolors`" ]] && eval `dircolors`

EDITOR=`which vim`
VISUAL=$EDITOR
FCEDIT=$EDITOR
PAGER=`which less`
FIGNORE=.o:~

LESS="-f-R-P?f[%f]:[STDIN].?m(file %i of %m)?x[Next\: %x]. .?lb [line %lb?L/%L]..?e(END) :?pB [%pB\%]..%t"
RI='--format ansi'
GREP_OPTIONS='--color=auto'

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
    maggie)
        PAREN_COLOR="\[${_GRN}\]"
        MC="\[${_BGRN}\]"
        DC="\[${_BLU}\]"
        ;;
    terminus)
        PAREN_COLOR="\[${_BLU}\]"
        MC="\[${_CYN}\]"
        DC="\[${_BLU}\]"
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

case $TERM in
    [Ex]term*) TITLE_WINDOW="\[\033]0;\h :: \w\007\]" ;;
    *)         TITLE_WINDOW='' ;;
esac

# Some things need to be computed.
prompt_cmd() {
    # Compute RETVAL
    FAIL=$?
    if [[ $FAIL -eq 0 ]]; then
        PS1RETVAL="${OP}${DC}0${CP}"
    else
        PS1RETVAL="${OP}\[${_BRED}\]${FAIL}${CP}"
    fi

    history -a  # Save last user cmd to bash_history
    command -v git &>/dev/null && {
        GIT=${_RED}$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/')
    }

    PS1="${TITLE_WINDOW}${PS1HOST}${PS1RETVAL}${GIT}${PS1DIR}${PS1END}"
}

PROMPT_COMMAND=prompt_cmd
PS1="${TITLE_WINDOW}${PS1HOST}${PS1RETVAL}${PS1DATE}${PS1TIME}${PS1TTY}${PS1DIR}${PS1END}"

export PATH PS1 EDITOR VISUAL PAGER LESS FCEDIT SEPATH MANPATH TERM GREP_OPTIONS RI HISTFILESIZE HISTFILE HISTIGNORE
export MODULEBUILDRC PERL_MM_OPT PERL5LIB PYTHONPATH
