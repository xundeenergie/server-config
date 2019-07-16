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
#    set -x
    unsetproxy
    if [ -f ~/.config/proxycreds_"${1}" ]; then
        echo proxycreds_$1 existing
        source ~/.config/proxycreds_"${1}"
        export PROXY_CREDS="${PROXY_USER}:${PROXY_PASS}@"
    else
        echo proxycreds_$1 not existing
        export PROXY_CREDS=""
    fi

    export {http,https,ftp}_proxy="http://${PROXY_CREDS}${PROXY_SERVER}:${PROXY_PORT}"
#    set +x
}

unsetproxy () {
    unset {http,https,fpt}_proxy
    unset PROXY_{CREDS,USER,PASS,SERVER,PORT}
}

if [ -e "${SCONF}/bashrc_local" ]; then
        . "${SCONF}/bashrc_local"
fi

# DEBUG 1
# DEBUG 2
git-mergedetachedheadtomaster () {
#    set -x
#    r=$(git show-ref --heads|awk '{print $1}')
#    echo branch: $r
#    git checkout master 
#    git merge $r
#    set +x
    git checkout -b tmp
    git branch -f master tmp
    git branch -d tmp
    git push origin master
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
    VIMMKTMPCMD="mktemp /tmp/${USER}.vimrc.XXXXXXXX.conf"
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
            REMOTETMPBASHCONFIG=$(ssh -o VisualHostKey=no $@ "$MKTMPCMD")
            REMOTETMPVIMCONFIG=$(ssh -o VisualHostKey=no $@ "$VIMMKTMPCMD")
            # Add additional aliases to bashrc for remote-machine
            cat << EOF >> "${TMPBASHCONFIG}"
alias vi='vim -u ${REMOTETMPVIMCONFIG}'
alias vim='vim -u ${REMOTETMPVIMCONFIG}'
alias vimdiff='vimdiff -u ${REMOTETMPVIMCONFIG}'
export VIMRC="${REMOTETMPVIMCONFIG}"
EOF
            ssh -o VisualHostKey=no $@ "cat > ${REMOTETMPBASHCONFIG}" < "${TMPBASHCONFIG}"
            ssh -o VisualHostKey=no $@ "cat > ${REMOTETMPVIMCONFIG}" < "${SCONF}/vimrc"
          
            ssh -t $@ "bash --rcfile ${REMOTETMPBASHCONFIG}; rm -f ${REMOTETMPBASHCONFIG} ${REMOTETMPVIMCONFIG}"
            rm "${TMPBASHCONFIG}"
        else
            echo "${TMPBASHCONFIG} does not exist. Use »ssh $@«"
        fi
    else
        ssh
    fi
}

VIMRC="${SCONF}/vimrc"

svi () { 
    if [ -f ${VIMRC} ]; then
        sudo vim -u "${VIMRC}" $@; 
    else
        sudo vim $@
    fi
}

getbashrcfile () {
    cat /proc/$$/cmdline | xargs -0 echo|awk '{print $3}'
}
