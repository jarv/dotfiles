#!/bin/bash

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
DOTLINKS=$(find $DIR -maxdepth 1 -name "dotfile.*" -type f | grep -v "swp")
DOTDIRS=$(find $DIR -maxdepth 1 -name "dotfile.*.d" -type d)
LINKS="$DOTLINKS $DOTDIRS"
for file in $LINKS; do
    link="$HOME/$(echo $(basename $file) | sed s/dotfile//)"
    echo $link
    if [[ -L "$link" ]];then
        echo "skipping $file"
    else
        if [[ -r "$link" ]];then
            echo "backing up ${link}"
            mv $link{,.bak}
        fi
        echo "creating symlink $link"
        ln -s $(abspath $file) $link
    fi
done
