# runs the activation script for rvm if it exists
if [[ -r $HOME/.rvmrc ]]; then
    source $HOME/.rvmrc
fi
if [[ -r "$rvm_path/scripts/rvm" ]]; then
    . "$rvm_path/scripts/rvm"
fi
