create_symlinks() {

    #echo SERVERCONFIG_BASE: $SERVERCONFIG_BASE
    SERVERCONFIG_BASEDIR="$1"
    DIR="$(basename ${SERVERCONFIG_BASEDIR})"
    cd  "${SERVERCONFIG_BASEDIR}"
    #echo "DIR SERVERCONFIG_BASEDIR $DIR $SERVERCONFIG_BASEDIR"
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

if [ -e "${SERVERCONFIG_BASE}/bashrc_local" ]; then
        . "${SERVERCONFIG_BASE}/bashrc_local"
fi

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
    git checkout master
    git branch -d tmp
    git commit -m "Merged detached head into master" .
    #git push origin master
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
    FILELIST=( "${SERVERCONFIG_BASE}/functions.sh" "${SERVERCONFIG_BASE}/aliases" "${HOME}/.aliases" "${SERVERCONFIG_BASE}/PS1" )
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
export BASHRC="${REMOTETMPBASHCONFIG}"
title "$USER@$HOSTNAME: $PWD"
echo bash-config: ${REMOTETMPBASHCONFIG}
EOF
           ssh -o VisualHostKey=no $@ "cat > ${REMOTETMPBASHCONFIG}" < "${TMPBASHCONFIG}"
           ssh -o VisualHostKey=no $@ "cat > ${REMOTETMPVIMCONFIG}" < "${SERVERCONFIG_BASE}/vimrc"
           RCMD="
           trap \"rm -f ${REMOTETMPBASHCONFIG} ${REMOTETMPVIMCONFIG}\" EXIT " ;
           #ssh -t $@ "$RCMD; title $USER@$HOST; bash --rcfile ${REMOTETMPBASHCONFIG}&"
#           read -r -d '' RCMD <<-'EOF'
#           trap "rm -f ${REMOTETMPBASHCONFIG} ${REMOTETMPVIMCONFIG}" EXIT
#EOF
           ssh -t $@ "$RCMD; bash --rcfile ${REMOTETMPBASHCONFIG}"
#           ssh -t $@ "$RCMD; \
#               bash --rcfile ${REMOTETMPBASHCONFIG}"
           #ssh -t $@ "$RCMD; bash --rcfile ${REMOTETMPBASHCONFIG}; tmux set-window-option automatic-rename 'on' 1>/dev/null"

           rm "${TMPBASHCONFIG}"
        else
           echo "${TMPBASHCONFIG} does not exist. Use »ssh $@«"
        fi
    else
        ssh
    fi
}

VIMRC="${SERVERCONFIG_BASE}/vimrc"

svi () { 
    if [ -f ${VIMRC} ]; then
        sudo vim -u "${VIMRC}" $@; 
    else
        sudo vim $@
    fi
}

vim-plugins-update () {
    vim -c "PluginUpdate" -c ":qa!"
    
}

vim-plugins-install () {
    vim -c "PluginInstall" -c ":qa!"
    
}

vim-repair-vundle () {
    if [ -z ${SERVERCONFIG_BASE+x} ]; then   
        echo "SERVERCONFIG_BASE nicht gesetzt. Eventuell noch einmal ausloggen und wieder einloggen"
    else
        cd $SERVERCONFIG_BASE
        cd vim/bundle
        rm -rf Vundle.vim
        git clone  "${GIT_GIT_PROTOCOL}${GIT_SERVER}/public/Vim/Vundle.vim.git"
        cd ~-
    fi
}

getbashrcfile () {
    cat /proc/$$/cmdline | xargs -0 echo|awk '{print $3}'
    echo $BASHRC
}

getvimrcfile () {
    echo $VIMRC
}


# Functions to set the correct title of the terminal
function title()
{
   # change the title of the current window or tab
   echo -ne "\033]0;$*\007"
}

function sshx()
{
   /usr/bin/ssh "$@"
   # revert the window title after the ssh command
   title $USER@$HOST
}

function su()
{
   /bin/su "$@"
   # revert the window title after the su command
   title $USER@$HOST
}

function usage() 
{
cat << EOF
    Keyboard-shortcuts:

    # tmux:
        C+Cursor    tmux window change size
        M+[hjkl]    tmux change splitted windows

    # vim:
        C+[hjkl]    vim change splitted windows
EOF
}

function pdsh-update-hetzner()
{
    curl -s -H "Authorization: Bearer $(pass hetzner.com/api-token | head -n1)" \
        https://api.hetzner.cloud/v1/servers \
        | /usr/bin/jq '.servers[].public_net.ipv4.ip'|sed -e 's/\"//g' \
        |while read i; do 
            dig -x $i | awk '$0 !~ /^;/ && $4 == "PTR" {print $5}' 
        done > ~/.dsh/group/hetzner-servers
}

function tmuxsplit() {
    case $# in
        1)
            SESS=($(find ${TMUX_SESSION_DIRS[*]} -mindepth 1 -name "$1.session"))
            ;;
        *)
            echo no session specified return
            ;;
    esac
    tmux new-session -d

    echo SESS: ${SESS[0]}
    [ -e ${SESS[0]} ] \
        && tmux source-file ${SESS}
    tmux attach-session -d
}
