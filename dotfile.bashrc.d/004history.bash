h() {
    ls ~/.bash_histories/*/* | sort | xargs grep -i "$1"
}
