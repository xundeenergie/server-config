create_symlinks() {

    SCONFDIR="$1"
    DIR="$(basename ${SCONFDIR})"
    pwd
    cd  "${SCONFDIR}"
    pwd
    #Anlegen von Symlinks
    rm -rf ~/.vimrc ~/.vim ~/bashrc_add ~/.gitconfig
    ln -sf "${DIR}/vimrc" ~/.vimrc
    ln -sf "${DIR}/vim" ~/.vim
    ln -sf "${DIR}/.gitconfig" ~/.gitconfig
    ln -sf "${DIR}/bashrc_add" ~/bashrc_add
    cd ~-

}

