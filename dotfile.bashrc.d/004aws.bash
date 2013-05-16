aws() {
    unset BOTO_NAME
    unset BOTO_CONFIG
    unset AWS_CREDENTIAL_FILE
    config="$HOME/.boto.${1}"
    aws="$HOME/.aws.${1}"
    if [[ ! -f $config ]]; then
        echo -e "${_BRED}$config does not exist!${_NORM}"
        return
    fi
    if [[ ! -f $aws ]]; then
        echo -e "${_BRED}$aws does not exist!${_NORM}"
        return
    fi

    export AWS_NAME="$1"
    export BOTO_CONFIG="$config"
    export AWS_CREDENTIAL_FILE="$aws"
}
