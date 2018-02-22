# server-config

Damit auf einem neuen Server meine persönlichen Alias und Bash-Promt, wie auch verschiedene andere Befehle (vim in sudo mit der vimrc des Benutzers) zur Verfügung stehen, muss als erstes nach dem ersten Login folgendes ausgeführt werden:

```
wget https://git.ebcont.com/jakobus.schuerz/server-config/raw/master/bashrc_add
vi .bashrc
```
Dies lädt die Datei bashrc_add ins Home-Verzeichnis. 

Die Default .bashrc muss am Ende um folgende Zeilen ergänzt werden:
```
# User specific aliases and function
[ -f bashrc_add ] && . bashrc_add
```
damit diese heruntergeladene Datei beim nächsten Login oder aufruf von bash gesourced wird.
Diese Datei clont dieses Repo nach $HOME oder pullt es, wenn das Repo schon vorhanden ist.

Damit ist auch schon alles erledigt

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
