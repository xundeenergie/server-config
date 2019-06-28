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

LOGDIR="./logs"
LOGFILE="${LOGDIR}/git.log"
[ -d "${LOGDIR}" ] || mkdir -p "${LOGDIR}"

cat << EOF >> "${LOGFILE}"
+-----BEGINN $(date) -------------------------------+
EOF

case $1 in
    -h)
        # Headless repo local
        PRE="origin/"
        ;;
    *)
        PRE=""
        ;;
esac
git fetch -p  2>>"${LOGFILE}"|| { echo fetch failed; exit 1; }
#git submodule update --remote --merge 2>>"${LOGFILE}"|| { echo update submodules failed: continue ; }
git submodule init 2>>"${LOGFILE}"|| { echo update submodules failed; exit 1; }
git submodule update --recursive --remote --merge 2>>"${LOGFILE}"|| { echo update submodules failed; exit 1; }

if git diff-index --ignore-submodules --exit-code HEAD -- >/dev/null ; then
    cat << EOF >> "${LOGFILE}"
Check for local changes:
    no changes in local repo
EOF
    #echo "checkout origin/master as detached HEAD"
    git checkout ${PRE}master 1>>"${LOGFILE}" 2>>"${LOGFILE}"|| exit 2
else
    cat << EOF >> "${LOGFILE}"
Check for local changes:
    Ich habe lokale Änderungen festgestellt
    um die Änderung zurückzusetzen bitte

      git checkout \$FILENAME

    oder um alle lokalen Änderungen auf einmal zurückzusetzen:

      git checkout .

    ausführen

    Die Änderungen sind:
EOF
    git diff-index HEAD --|awk '{print $5, $6}' >>  "${LOGFILE}"
    git diff-index -p HEAD -- >> "${LOGFILE}"

    echo "Lokale Änderungen festgestellt: Siehe Logfile $(pwd)/${LOGFILE}" >&2
cat << EOF >> "${LOGFILE}"

+-----ENDE $(date) ---------------------------------+
 
EOF
    exit 3

fi

cat << EOF >> "${LOGFILE}"

+-----ENDE $(date) ---------------------------------+
 
EOF
exit 0

