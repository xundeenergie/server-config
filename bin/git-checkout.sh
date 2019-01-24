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

LOGFILE=./logs/git.log
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
    cat << EOF >> "${LOGFILE}"

+-------------------------------------------------+
$(date) 
no changes in local repo
EOF
    #echo "checkout origin/master as detached HEAD"
    git checkout ${PRE}master || exit 2
else
    cat << EOF >> "${LOGFILE}"
    Ich habe lokale Änderungen festgestellt
    um die Änderung zurückzusetzen bitte

      git checkout \$FILENAME

    oder

      git checkout .

    ausführen

    Die Änderungen sind:
EOF
    git diff-index HEAD --|awk '{print $5, $6}' |tee -a "${LOGFILE}"
    git diff-index -p HEAD --|tee -a "${LOGFILE}"

    exit 3

fi

exit 0

