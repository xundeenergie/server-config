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