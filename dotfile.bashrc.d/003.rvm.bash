# runs the activation script for rvm if it exists
source $HOME/.rvmrc
if [[ -r "$rvm_path/scripts/rvm" ]]; then
    . "$rvm_path/scripts/rvm"
else
    echo -e "$_BRED Warning: '$rvm_path/scripts/rvm' doesn't exist $_NORM"
fi
