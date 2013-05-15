boto() {
    config="$HOME/.boto.${1}"
    if [[ ! -f $config ]]; then
        echo -e "${_BRED}$config does not exist!${_NORM}"
        return
    fi
    BOTO_NAME="$1"
    BOTO_CONFIG="$config"
}
