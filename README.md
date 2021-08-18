# mina restarter

**translation in progress, DO NOT use**

Перезагрузка ноды:
* при отставании
* при статусах CONNECTING, LISTENING, OFFLINE, BOOTSTRAP, CATCHUP (если нода работает дольше отведенного на загрузку времени, настройка в файле m.sh)


Download scripts
---
```
cd
mkdir mrestart && cd mrestart
wget https://raw.githubusercontent.com/Kakashi010/mina/main/m.sh
wget https://raw.githubusercontent.com/Kakashi010/mina/main/alert.py
wget https://raw.githubusercontent.com/Kakashi010/mina/main/id.py

chmod +x m.sh
chmod +x alert.py
chmod +x id.py
```

Install & Configure
---
```
apt update
apt install python3-pip
pip3 install pyTelegramBotAPI
apt install jq
```

1. Register a bot with [@BotFather](https://t.me/BotFather)
2. Add bot token to `alert.py` and `id.py`
3. Run `python3 id.py` and write "**ID**" to your bot. Add the received **ID** to alert.py (`tgid`)
4. Setup a scheduler
   - Insert the below line in `crontab -e`
```
*/5 * * * * cd ~/mrestart && ./m.sh
```


Settings in file- m.sh
---

* Edit Node name as you prefer
* Customize api (if required)
* Edit the "time" required to load a node
* Add reboot and additional commands

Thanks to [w0rldwind](https://github.com/w0rldwind) for the original scripts!
