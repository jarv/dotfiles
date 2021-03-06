if [[ $(uname -m) == "armv5tejl" ]]; then
    PREFIX=/opt
    PATH="$PREFIX/bin:$PREFIX/sbin:$PATH"
    PKG_CONFIG_PATH="/opt/lib/pkgconfig:$PKG_CONFIG_PATH"
    C_INCLUDE_PATH="$PREFIX/include:$C_INCLUDE_PATH"
    LIBRARY_PATH="$PREFIX/lib:$LIBRARY_PATH"
    LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
    export PATH PKG_CONFIG_PATH C_INCLUDE_PATH LIBRARY_PATH LD_LIBRARY_PATH
fi
