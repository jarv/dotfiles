#!/usr/bin/env bash

abspath () { 
    case "$1" in 
        /*)
            printf "%s\n" "$1"
            ;; 
        *)
            printf "%s\n" "$PWD/$1"
            ;; esac; 
}
DIR=$(dirname $0)
DOTLINKS=$(find $DIR -maxdepth 1 -name "dotfile.*")
for file in $DOTLINKS; do
    link="$HOME/$(echo $(basename $file) | sed s/dotfile//)"
    echo $link
    if [[ -L "$link" ]]; then
        echo "removing $link"
        rm -f "$link"
    elif [[ -r "$link" ]];then
        echo "backing up ${link}"
        mv $link{,.bak}
    fi
    echo "creating symlink $link"
    ln -s $(abspath $file) $link
done
bash -c "cd $DIR && git submodule update --init"

# some utiltiies 

case `uname -s` in
    [Ll]inux)
        command -v puppet-lint &>/dev/null || {
            sudo apt-get install -y puppet-lint
        }
        command -v vim  &>/dev/null || {
            sudo apt-get install -y vim 
        }
        command -v ctags  &>/dev/null || {
            sudo apt-get install -y ctags 
        }
        command -v pep8  &>/dev/null || {
            sudo apt-get install -y pep8 
        }
        break
        ;;
esac
