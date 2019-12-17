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

[ -z "${SGIT+x}" ] && SGIT=git
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
$SGIT fetch origin -p  2>>"${SERVERCONFIG_LOGFILE}"|| { echo fetch failed; exit 1; }

if $SGIT diff-index --ignore-submodules --exit-code HEAD -- >> "${SERVERCONFIG_LOGFILE}" ; then
    cat << EOF >> "${SERVERCONFIG_LOGFILE}"
Check for local changes:
    no changes in local repo
    $SGIT checkout repo ${PRE}master
EOF
    #echo "checkout origin/master as detached HEAD"
    $SGIT checkout ${PRE}master 1>>"${SERVERCONFIG_LOGFILE}" 2>>"${SERVERCONFIG_LOGFILE}"|| exit 2
    $SGIT merge FETCH_HEAD 1>>"${SERVERCONFIG_LOGFILE}" 2>>"${SERVERCONFIG_LOGFILE}"|| exit 3
else
    cat << EOF >> "${SERVERCONFIG_LOGFILE}"
Check for local changes:
    Ich habe lokale Änderungen festgestellt
    um die Änderung zurückzusetzen bitte

      $SGIT checkout \$FILENAME

    oder um alle lokalen Änderungen auf einmal zurückzusetzen:

      $SGIT checkout .

    ausführen

    Die Änderungen sind:
EOF
    $SGIT diff-index HEAD --|awk '{print $5, $6}' >>  "${SERVERCONFIG_LOGFILE}"
    $SGIT diff-index -p HEAD -- >> "${SERVERCONFIG_LOGFILE}"

    echo "Lokale Änderungen festgestellt: Siehe Logfile ${SERVERCONFIG_LOGFILE}" >&2
cat << EOF >> "${SERVERCONFIG_LOGFILE}"

+-----ENDE $(date) ---------------------------------+
 
EOF
    exit 4

fi

cat << EOF >> "${SERVERCONFIG_LOGFILE}"

+-----update submodules $(date) ---------------------------------+
 
EOF
rc=0
## Update/init submodules
#$SGIT submodule update --remote --merge 2>>"${SERVERCONFIG_LOGFILE}"|| { echo update submodules failed: continue ; }
#$SGIT submodule init 1>>"${SERVERCONFIG_LOGFILE}" 2>&1|| { echo update submodules failed; exit 1; }
#$SGIT submodule sync 1>>"${SERVERCONFIG_LOGFILE}" 2>&1|| { echo sync submodules failed; exit 1; }
#$SGIT submodule foreach "$SGIT branch -u origin/master master"  1>>"${SERVERCONFIG_LOGFILE}" 2>&1|| { echo set-upstream submodules failed; exit 1; }
#$SGIT submodule update --recursive --remote --merge 1>>"${SERVERCONFIG_LOGFILE}" 2>&1|| { echo update submodules failed; exit 1; }

#echo "update submodules" >&2
$SGIT submodule init 1>>"${SERVERCONFIG_LOGFILE}" 2>&1|| { echo update submodules failed on ini; rc=5; }
$SGIT submodule sync 1>>"${SERVERCONFIG_LOGFILE}" 2>&1|| { echo sync submodules failed on sync; rc=6;  }
$SGIT submodule foreach "git checkout master"  1>>"${SERVERCONFIG_LOGFILE}" 2>&1|| { echo checkout master submodules failed on set upstream; rc=7;  }
$SGIT submodule foreach "git branch -u origin/master master"  1>>"${SERVERCONFIG_LOGFILE}" 2>&1|| { echo set-upstream submodules failed on set upstream; rc=8;  }
$SGIT submodule update --recursive --remote --merge 1>>"${SERVERCONFIG_LOGFILE}" 2>&1|| { echo update submodules failed on update; rc=9;  }
#echo "submodules updated" >&2

cat << EOF >> "${SERVERCONFIG_LOGFILE}"

+-----ENDE $(date) ---------------------------------+
 
EOF
exit $rc

