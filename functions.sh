# Initialize variables, if not set
[ -z ${TMUX_SESSION_DIRS+x} ] && TMUX_SESSION_DIRS=( ~/.config/tmux/sessions ~/.local/share/tmux/sessions ~/.tmux/sessions)
[ -z ${SETPROXY_CREDS_DIRS+x} ] && SETPROXY_CREDS_DIRS=(~/.config/proxycreds.d)
[ -z ${KERBEROS_CONFIG_DIRS+x} ] && KERBEROS_CONFIG_DIRS=(~/.config/kerberos-conf.d)

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

get_first_config () {
    # usage: 
    #           get_first_config <array_with_config_dirs> configfilename_without_.config
    # returns the first occurance of configfilename in all config_dirs 

    CONFIG_DIR_ARRAY=$1
    echo $# 1>&2
    case $# in
        0|1|2)
            echo "Too few arguments" 1>&2
            echo are you sure, $1 is defined? 1>&2
            return 1
            ;;
        3)
            [ -z ${CONFIG_DIR_ARRAY} ] && return 1
            CONF=$(find ${CONFIG_DIR_ARRAY[*]} -mindepth 1 -name "$1.conf" -print -quit 2>/dev/null )
            [ -z ${CONF+x} ] && { echo "No config found in config-dirs" 1>&2; return 2; }
            ;;
        *)
            echo "Too many arguments" 1>&2
            return 3
            ;;
    esac

}

setproxy () {
#    set -x
#    case $# in
#        0)
#            echo too few arguments
#            return
#            ;;
#        1)
#            [ -z ${SETPROXY_CREDS_DIRS} ] && return 1
#            SESS=($(find ${SETPROXY_CREDS_DIRS[*]} -mindepth 1 -name "$1.conf" 2>/dev/null ))
#            ;;
#        *)
#            echo to many arguments
#            return
#            ;;
#    esac
    #[ -e ${SESS[0]} ] && . ${SESS[0]}

    CONFIG=$(get_first_config SETPROXY_CREDS_DIRS ${SETPROXY_CREDS_DIRS} $@)
    ret=$?
    [ $ret -gt 0 ] && return $ret

    if [ -e ${CONFIG[0]} ]; then
        echo "${CONFIG[0]} existing"
        source "${CONFIG[0]}"
        export PROXY_CREDS="${PROXY_USER}:${PROXY_PASS}@"
    else
        echo "${CONFIG[0]} not existing"
        export PROXY_CREDS=""
    fi

    export {http,https,ftp}_proxy="http://${PROXY_CREDS}${PROXY_SERVER}:${PROXY_PORT}"
#    set +x
}

kinit-custom () {

    CONFIG=$(get_first_config KERBEROS_CONFIG_DIRS ${KERBEROS_CONFIG_DIRS} $@)

    ret=$?
    [ $ret -gt 0 ] && return $ret

    echo CONFIG: ${CONFIG[*]}

    if [ -e ${CONFIG[0]} ]; then
        echo "${CONFIG[0]} existing"
        source "${CONFIG[0]}"
    else
        echo "${CONFIG[0]} not existing"
        return 1
    fi

    [ -z ${PKEY+x} ] || return 2
    pass "${PKEY}" 1>/dev/null 2>&1 || return 3
    local KERBEROS_PASSWORD=$(pass "${PKEY}" | head -n1)
    local KERBEROS_USER=$(pass "${PKEY}" | grep login | sed -e 's/^login: //' )
    echo KERBEROS_PASSWORD: $KERBEROS_PASSWORD
    echo KERBEROS_USER: $KERBEROS_USER

    if [ -z ${KERBEROS_USER+x} ];then
        echo "no kerberos user found -> exit"
        return 4
    else
        ${KINIT} -R "${KERBEROS_USER}@${REALM}" <<!
${KERBEROS_PASSWORD}
!
    fi
}

unsetproxy () {
    unset {http,https,fpt}_proxy
    unset PROXY_{CREDS,USER,PASS,SERVER,PORT}
}

git-mergedetachedheadtomaster () {
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

sshserverconfig() {

    SSH="/usr/bin/ssh"
    echo $@
    ssh -t -o VisualHostKey=no $@ "cat > ~/bashrc_add" < "${SERVERCONFIG_BASE}/bashrc_add"
    CMD="$SSH -t $@"
    $CMD /bin/bash << EOF
    [ -e /etc/bashrc ] && .  /etc/bashrc
    [ -e /etc/bash.bashrc ] && . /etc/bash.bashrc
    echo "modify ~/.bashrc"
    if grep -q bashrc_add ~/.bashrc ;then
        sed -i -e '/bashrc_add/d' ~/.bashrc
    fi
    echo
    printf "%s" "[ -f bashrc_add ] && . bashrc_add" | tee -a ~/.bashrc
    echo

EOF

}
sshs() {

    MKTMPCMD="mktemp /tmp/${USER}.bashrc.XXXXXXXX.conf"
    VIMMKTMPCMD="mktemp /tmp/${USER}.vimrc.XXXXXXXX.conf"
    TMPBASHCONFIG=$($MKTMPCMD)
    FILELIST=( "${SERVERCONFIG_BASE}/functions.sh" "${SERVERCONFIG_BASE}/aliases" "${HOME}/.aliases" "${SERVERCONFIG_BASE}/PS1" "${SERVERCONFIG_BASE}/bash_completion.d/*" )

    # Read /etc/bashrc or /etc/bash.bashrc (depending on distribution) and /etc/profile.d/*.sh first
    cat << EOF >> "${TMPBASHCONFIG}"
    SSHS=true
    [ -e /etc/bashrc ] && BASHRC=/etc/bashrc
    [ -e /etc/bash.bashrc ] && BASHRC=/etc/bash.bashrc
    . \$BASHRC

    for i in /etc/profile.d/*.sh; do
        if [ -r "$i" ];then
            if [ "$PS1" ]; then
                . "$i"
            else
                . "$i" >/dev/null
            fi
        fi
    done
EOF

    for f in ${FILELIST[*]}; do
        if [ -e $f ]; then
            echo add $f to tmpconfig
            cat "$f" >> "${TMPBASHCONFIG}";
        fi
    done
    
    if [ $# -ge 1 ]; then
        if [ -e "${TMPBASHCONFIG}" ] ; then
            RCMD="bash --noprofile --norc -c "
           REMOTETMPBASHCONFIG=$(ssh -t -o VisualHostKey=no $@ "$MKTMPCMD"| tr -d '[:space:]' )
           REMOTETMPVIMCONFIG=$(ssh -t -o VisualHostKey=no $@ "$VIMMKTMPCMD"| tr -d '[:space:]')
#           REMOTETMPBASHCOMPLETIONCONFIG=$(ssh -t -o VisualHostKey=no $@ "$BASHCOMPLETIONMKTMPCMD"| tr -d '[:space:]')

           # Add additional aliases to bashrc for remote-machine
           cat << EOF >> "${TMPBASHCONFIG}"
alias vi='vim -u ${REMOTETMPVIMCONFIG}'
alias vim='vim -u ${REMOTETMPVIMCONFIG}'
alias vimdiff='vimdiff -u ${REMOTETMPVIMCONFIG}'
export LS_OPTIONS="${LS_OPTIONS}"
export VIMRC="${REMOTETMPVIMCONFIG}"
export BASHRC="${REMOTETMPBASHCONFIG}"
title "$USER@$HOSTNAME: $PWD"

EOF

           ssh -t -o VisualHostKey=no $@ "cat > ${REMOTETMPBASHCONFIG}" < "${TMPBASHCONFIG}"
           ssh -t -o VisualHostKey=no $@ "cat > ${REMOTETMPVIMCONFIG}" < "${SERVERCONFIG_BASE}/vimrc"
           RCMD="
           trap \"rm -f ${REMOTETMPBASHCONFIG} ${REMOTETMPVIMCONFIG}\" EXIT " ;
           ssh -t $@ "$RCMD; bash --rcfile ${REMOTETMPBASHCONFIG}"
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
    if [ -z ${BASHRC+x} ] ; then
        echo "bash uses default"
    else
        cat /proc/$$/cmdline | xargs -0 echo|awk '{print $3}'
        #echo $BASHRC

    fi
}

catbashrcfile () {
    if [ -z ${BASHRC+x} ] ; then
        echo "bash uses default"
    else
        cat $(cat /proc/$$/cmdline | xargs -0 echo|awk '{print $3}')
        #echo $BASHRC

    fi
}

getvimrcfile () {
    if [ -z ${VIMRC+x} ] ; then
        echo "vim uses default"
    else
        echo $VIMRC
    fi
}

catvimrcfile () {
    if [ -z ${VIMRC+x} ] ; then
        echo "vim uses default"
    else
        cat $VIMRC
    fi
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
        done |sed -s -e 's/\.$//' > ~/.dsh/group/hetzner-servers
}

function tmuxx() {
    case $# in
        1)
            SESS=($(find ${TMUX_SESSION_DIRS[*]} -mindepth 1 -name "$1.session" 2>/dev/null ))
            ;;
        *)
            echo no session specified return
            ;;
    esac
    TMUX='/usr/bin/tmux'
    $TMUX -f ~/.tmux.conf new-session -d
    [ -e ${SESS[0]} ] && $TMUX source-file ${SESS[0]}
    $TMUX attach-session -d
}


gnome-shell-extensions-enable-defaults () { 
    if [ -f ~/.config/gnome-shell-extensions-default.list ]; then
        for i in $(cat ~/.config/gnome-shell-extensions-default.list); do 
            #gnome-shell-extension-tool -e $i;
            gnome-extensions enable $i;
        done; 
    fi
}

