#!/bin/bash
#################################################################################################
# title         :git-checkout.sh                                                                #
# description   :checkout git detached HEAD                                                     #
# author        :Jakobus Schürz                                                                 #
# changes by    :Jakobus Schürz                                                                 #
# created       :17.01.2019                                                                     #
# updated       :                                                                               #
# version       :1.0                                                                            #
# usage         :./git-checkout 	                                                        #
# notes         :                                                                               #
#################################################################################################

case $1 in
    -h)
        # Headless repo local
        PRE="origin/"
        ;;
    *)
        PRE=""
        ;;
esac
git fetch -p || exit 1

if git diff-index --exit-code HEAD --; then
    cat << EOF >> ../logs/git.log
    $(date) 
    no changes in local repo
EOF
    #echo "checkout origin/master as detached HEAD"
    git checkout ${PRE}master || exit 2
else
    echo "Ich habe lokale Änderungen festgestellt"
    echo "um die Änderung zurückzusetzen bitte"
    echo
    echo "  git checkout \$FILENAME"
    echo
    echo "oder"
    echo
    echo "  git checkout ."
    echo
    echo "ausführen"
    echo
    echo "Die Änderungen sind:"; 
    git diff-index HEAD --|awk '{print $5, $6}'
    git diff-index -p HEAD --
    exit 3

fi

exit 0

