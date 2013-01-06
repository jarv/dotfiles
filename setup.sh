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

# some utiltiies and environment setup for a new
# Ubuntu workstation

case `uname -s` in
    [Ll]inux)
        mkdir -p $HOME/tmp
        mkdir -p $HOME/src
        cinnamon_list="/etc/apt/sources.list.d/"
        cinnamon_list+="gwendal-lebihan-dev-cinnamon-stable-quantal.list"
        if [[ ! -f $cinnamon_list ]]; then
            sudo add-apt-repository -y ppa:gwendal-lebihan-dev/cinnamon-stable
        fi
        # install apt packages
        cat $DIR/apt-packages.txt | xargs sudo apt-get install -y
        # install node
        if [[ ! -x $HOME/bin/node ]]; then
            cd $HOME/src
            git clone git://github.com/ry/node.git
            cd node
            ./configure --prefix=$HOME
            make
            make install
        fi
        if [[ ! -x $HOME/bin/npm ]]; then
            curl https://npmjs.org/install.sh | sh
        fi
        for pkg in jshint js-yaml jslint; do
            if [[ ! -d $HOME/lib/node_modules/$pkg ]]; then
                $HOME/bin/npm install $pkg -g 
            fi
        done
        # importing keyboard shortcuts
        # only tested against 12.10
        if [[ $(lsb_release -d) =~ Ubuntu\ 12.10$ ]]; then
            perl $DIR/dump-keybindings.pl -i $DIR/keyboard.txt
        fi
        # firewall
        sudo ufw allow ssh
        sudo ufw enable
        ;;
esac
