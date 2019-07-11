create_symlinks() {

    SCONFDIR="$1"
    DIR="$(basename ${SCONFDIR})"
    cd  "${SCONFDIR}"
    echo "DIR SCONFDIR $DIR $SCONFDIR"
    git config credential.helper 'cache --timeout=300'
    #Anlegen von Symlinks
    rm -rf ~/.vimrc ~/.vim ~/bashrc_add ~/.gitconfig ~/.tmux.conf ~/.tmux
    ln -sf "${DIR}/vimrc" ~/.vimrc
    ln -sf "${DIR}/vim" ~/.vim
    ln -sf "${DIR}/.gitconfig" ~/.gitconfig
    ln -sf "${DIR}/bashrc_add" ~/bashrc_add
    ln -sf "${DIR}/tmux" ~/.tmux
    ln -sf "${DIR}/tmux/tmux.conf" ~/.tmux.conf

    git config core.hooksPath .githooks
    find .git/hooks -type l -exec rm {} \; && find .githooks -type f -exec ln -sf ../../{} .git/hooks/ \;

    cd ~-

}

setproxy () {
    set -x
    unsetproxy
    if [ -f ~/.config/proxycreds_"${1}" ]; then
        echo proxycreds_$1 exist: $?
        source ~/.config/proxycreds_"${1}"
        export PROXY_CREDS="${PROXY_USER}:${PROXY_PASS}@"
    else
        echo proxycreds_$1 not exist: $?
        export PROXY_CREDS=""
    fi

    export {http,https,ftp}_proxy="http://${PROXY_CREDS}${PROXY_SERVER}:${PROXY_PORT}"
    set +x
}

unsetproxy () {
    unset {http,https,fpt}_proxy
    unset PROXY_{CREDS,USER,PASS,SERVER,PORT}
}

if [ -e "${SCONF}/bashrc_local" ]; then
        . "${SCONF}/bashrc_local"
fi

git-mergedetachedheadtomaster () {
    r=$(git show-ref --heads|awk '{print $1}')
    echo branch: $r
    git checkout master 
    git merge $r
}

git-pushdetachedhead () {
    git push origin HEAD:master

}


pathmunge () {
    case ":${PATH}:" in
        *:"$1":*)
            ;;
        *)
            if [ "$2" = "after" ] ; then
                PATH=$PATH:$1
            else
                PATH=$1:$PATH
            fi
    esac
}

mkcd () {
    mkdir -p "$1"
    cd "$1"
}
