if [[ $(uname -m) == "armv5tejl" ]]; then
    PATH="/opt/bin:/opt/sbin:$PATH"
    PKG_CONFIG_PATH="/opt/lib/pkgconfig:$PKG_CONFIG_PATH"
    export PATH PKG_CONFIG_PATH
fi


