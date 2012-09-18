function workon() {

    projects="mitx_all edx"
    . $HOME/.rvmrc
    if [[ -r "$rvm_path/scripts/rvm" ]]; then
        . "$rvm_path/scripts/rvm"
    else
        echo "\E[31m Warning: '$rvm_path/scripts/rvm' doesn't exist \E[0m"
    fi
    
    for proj in $projects; do

        if [[ $proj == $1 ]]; then

            if [[ -r "$HOME/$proj/python/bin/activate" ]]; then
                . "$HOME/$proj/python/bin/activate"
                prompt_proj="$proj"
            else
                echo "virtualenv script doesn't exist in $HOME/$proj!"
                return
            fi
            break
        fi
    done
    
    if [[ ! $prompt_proj ]]; then
        echo "Project not found, select one of -> $projects"
    fi

}
