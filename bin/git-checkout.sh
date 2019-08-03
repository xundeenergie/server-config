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

SERVERCONFIG_LOGDIR="./logs"
SERVERCONFIG_LOGFILE="${SERVERCONFIG_LOGDIR}/git.log"
[ -d "${SERVERCONFIG_LOGDIR}" ] || mkdir -p "${SERVERCONFIG_LOGDIR}"

cat << EOF >> "${SERVERCONFIG_LOGFILE}"
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
git fetch origin -p  2>>"${SERVERCONFIG_LOGFILE}"|| { echo fetch failed; exit 1; }
#git submodule update --remote --merge 2>>"${SERVERCONFIG_LOGFILE}"|| { echo update submodules failed: continue ; }
git submodule init 1>>"${SERVERCONFIG_LOGFILE}" 2>&1|| { echo update submodules failed; exit 1; }
git submodule sync 1>>"${SERVERCONFIG_LOGFILE}" 2>&1|| { echo sync submodules failed; exit 1; }
git submodule foreach "git branch -u origin/master master"  1>>"${SERVERCONFIG_LOGFILE}" 2>&1|| { echo set-upstream submodules failed; exit 1; }
git submodule update --recursive --remote --merge 1>>"${SERVERCONFIG_LOGFILE}" 2>&1|| { echo update submodules failed; exit 1; }

if git diff-index --ignore-submodules --exit-code HEAD -- >/dev/null ; then
    cat << EOF >> "${SERVERCONFIG_LOGFILE}"
Check for local changes:
    no changes in local repo
EOF
    #echo "checkout origin/master as detached HEAD"
    git checkout ${PRE}master 1>>"${SERVERCONFIG_LOGFILE}" 2>>"${SERVERCONFIG_LOGFILE}"|| exit 2
else
    cat << EOF >> "${SERVERCONFIG_LOGFILE}"
Check for local changes:
    Ich habe lokale Änderungen festgestellt
    um die Änderung zurückzusetzen bitte

      git checkout \$FILENAME

    oder um alle lokalen Änderungen auf einmal zurückzusetzen:

      git checkout .

    ausführen

    Die Änderungen sind:
EOF
    git diff-index HEAD --|awk '{print $5, $6}' >>  "${SERVERCONFIG_LOGFILE}"
    git diff-index -p HEAD -- >> "${SERVERCONFIG_LOGFILE}"

    echo "Lokale Änderungen festgestellt: Siehe Logfile ${SERVERCONFIG_LOGFILE}" >&2
cat << EOF >> "${SERVERCONFIG_LOGFILE}"

+-----ENDE $(date) ---------------------------------+
 
EOF
    exit 3

fi

cat << EOF >> "${SERVERCONFIG_LOGFILE}"

+-----ENDE $(date) ---------------------------------+
 
EOF
exit 0

