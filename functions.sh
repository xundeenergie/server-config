create_symlinks() {

    SCONFDIR="$1"
    DIR="$(basename ${SCONFDIR})"
    cd  "${SCONFDIR}"
    git config credential.helper 'cache --timeout=300'
    #Anlegen von Symlinks
    rm -rf ~/.vimrc ~/.vim ~/bashrc_add ~/.gitconfig
    ln -sf "${DIR}/vimrc" ~/.vimrc
    ln -sf "${DIR}/vim" ~/.vim
    ln -sf "${DIR}/.gitconfig" ~/.gitconfig
    ln -sf "${DIR}/bashrc_add" ~/bashrc_add

    git config core.hooksPath .githooks
    find .git/hooks -type l -exec rm {} \; && find .githooks -type f -exec ln -sf ../../{} .git/hooks/ \;

    cd ~-

}

