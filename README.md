# mina restarter
```
apt update
apt install python3-pip
pip3 install pyTelegramBotAPI
```
```
cd
mkdir mrestart && cd mrestart

nano m.sh

nano alert.py

chmod +x m.sh
chmod +x alert.py

crontab -e

*/5 * * * * cd ~/mrestart && ./m.sh

chmod +x id.py

python3 id.py
```
