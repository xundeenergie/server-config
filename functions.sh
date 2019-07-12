create_symlinks() {

    SCONFDIR="$1"
    DIR="$(basename ${SCONFDIR})"
    cd  "${SCONFDIR}"
    #echo "DIR SCONFDIR $DIR $SCONFDIR"
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

sshs() {
    MKTMPCMD="mktemp /tmp/${USER}.bashrc.XXXXXXXX.conf"
    TMPBASHCONFIG=$($MKTMPCMD)
    FILELIST=( "${SCONF}/functions.sh" "${SCONF}/aliases" "${HOME}/.aliases" "${SCONF}/PS1" )
    for f in ${FILELIST[*]}; do
        if [ -e $f ]; then
            echo add $f to tmpconfig
            cat "$f" >> "${TMPBASHCONFIG}";
        fi
    done
    
    if [ $# -ge 1 ]; then
        if [ -e "${TMPBASHCONFIG}" ] ; then
            REMOTETMPBASHCONFIG=$(ssh $@ "$MKTMPCMD")
            REMOTETMPVIMCONFIG=$(ssh $@ "$MKTMPCMD")
            # Add additional aliases to bashrc for remote-machine
            cat << EOF >> "${TMPBASHCONFIG}"
alias vi='vim -u ${REMOTETMPVIMCONFIG}'
alias vim='vim -u ${REMOTETMPVIMCONFIG}'
alias vimdiff='vimdiff -u ${REMOTETMPVIMCONFIG}'
EOF
            ssh $@ "cat > ${REMOTETMPBASHCONFIG}" < "${TMPBASHCONFIG}"
            ssh $@ "cat > ${REMOTETMPVIMCONFIG}" < "${SCONF}/vimrc"
          
            ssh -t $@ "bash --rcfile ${REMOTETMPBASHCONFIG}; rm -f ${REMOTETMPBASHCONFIG} ${REMOTETMPVIMCONFIG}"
            rm "${TMPBASHCONFIG}"
        else
            echo "${TMPBASHCONFIG} does not exist. Use »ssh $@«"
        fi
    else
        ssh
    fi
}


if [ -f "${SCONF}/vimrc" ]; then
    svi () { sudo vim -u "${SCONF}/vimrc" $@; }
fi

showbashrc () {
    awk -F "\000" '{print $3}' /proc/$$/cmdline
}
