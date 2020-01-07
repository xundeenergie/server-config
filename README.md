# server-config

Am Einfachsten ist es, das github-Repo zu forken und in .gitconfig den Namen und die Emailadresse an die eigenen Werte anzupassen. Das Repo ist öffentlich, also keine Passwörter speicher!!!

.gitconfig wird von diesem Repo beim Einrichten nach ~/.gitconfig gelinkt. Bitte beachten, dass damit eine schon vorhandene eigene Datei überschrieben wird!

Soll ein Proxy zum Einsatz kommen, so ist dieser mittels
```
git config http.proxy "http://proxy.to.use:prot/"
```
local für jedes Repo zu konfigurieren. Die globale gitconfig für den User wird auf allen eingesetzten Instanzen verteilt und versioniert!

## Installation
Damit auf einem neuen Server meine persönlichen Alias und Bash-Promt, wie auch verschiedene andere Befehle (vim in sudo mit der vimrc des Benutzers) zur Verfügung stehen, muss als erstes nach dem ersten Login folgendes ausgeführt werden:

Download von github
```
curl -o bashrc_add "https://raw.githubusercontent.com/xundeenergie/server-config/master/bashrc_add"
```
oder Download von git.schuerz.at
```
curl -o bashrc_add "https://git.schuerz.at/?p=server-config.git;a=blob_plain;f=bashrc_add;hb=HEAD"
```

## Lokale Configuration
in ~/.bashrc werden vor der Zeile zum Einbinden der Serverconfig die Variablen eingefügt um damit ein hostspezifisches Verhalten zu steuern
SERVERCONFIG_GIT_CHECKOUTSCRIPT_OPTIONS=
Mögliche Optionen:
    * -h
Verwendung: Damit kann man angeben, ob ein headless Repo erzeugt wird. Ohne -h folgt das Repo origin/master
SERVERCONFIG_GIT_REMOTE_PROTOCOL=git # git ist default
SERVERCONFIG_GIT_REMOTE_PUSH_PROTOCOL=$SERVERCONFIG_GIT_REMOTE_PROTOCOL # SERVERCONFIG_GIT_REMOTE_PROTOCOL ist default
Mögliche Optionen:
    * git - (default) Gitprotokoll ist git (Auf manchen Umgebungen kann der dazu notwenidge Port gesperrt sein)
    * http - wenn git nicht möglich ist, kann das http/https Protokoll verwendet werden. (ist langsamer als git, jedoch ist fast überall Port 80 oder 440 freigeschaltet)
    * ssh - Wenn auch schreibend auf das Repo zugegriffen werden soll, so muss Privatekey, Pubkey (und wenn konfiguriert Certifikate mit den notwendigen Principals) vorhanden sein, dann kann das ssh-Prodokoll verwendet werden.


## Einbinden von bashrc_add in die bash 

Die Default .bashrc muss am Ende um folgende Zeilen ergänzt werden:
```
vi .bashrc

# User specific aliases and function
[ -f bashrc_add ] && . bashrc_add
```
damit diese heruntergeladene Datei beim nächsten Login oder aufruf von bash gesourced wird.
Diese Datei clont dieses Repo nach $HOME oder pullt es, wenn das Repo schon vorhanden ist.

Damit ist auch schon alles erledigt

# Über ~/.bashrc manuell festlegbare Variablen und ihre Default-Werte, wenn nicht manuell gesetzt:
SERVERCONFIG_SUBPATH=server-config
SERVERCONFIG_BASE="${HOME}/${SERVERCONFIG_SUBPATH}"
SERVERCONFIG_LOGDIR="${SERVERCONFIG_BASE}/logs"
SERVERCONFIG_LOGFILE="${SERVERCONFIG_LOGDIR}/git.log"
SERVERCONFIG_GIT_TIMEOUT=5s

SERVERCONFIG_GIT_SERVER="git.schuerz.at"
SERVERCONFIG_GIT_REPO_NAME="server-config.git"
SERVERCONFIG_GIT_REPO_PATH_HTTP="/public/"
SERVERCONFIG_GIT_REPO_PATH_SSH=":public/"
SERVERCONFIG_GIT_REPO_PATH_GIT="/public/"


# Modifizierung mit Skript
Wenn das auf mehreren Hosts ausgeführt werden muss, kann man auch das in diesem Repo in bin abgelegte Skript configserver.sh verwenden.
Am besten dieses Skript nach ${HOME}/bin kopieren und ausführbar machen.

```
cp bin/configserver.sh ${HOME}/bin
chmod +x ${HOME}/bin/configserver.sh
```

Usage:
configserver.sh [<username>@]<hostname> [port] [ssh-options]

ein Hostname muss angegeben werden
Wenn kein Username angegeben wird, fragt das Skript nach einem Username. Ist der Username leer, bricht das Programm ab.

Wenn kein Port angegeben wird, wird der Standardport 22 verwendet.

Weitere ssh-Optionen sind wie in der Notation für ssh anzugeben. 
    z.B.: -i /path/to/private.key -o https://git.ebcont.com/jakobus.schuerz/server-config.git
