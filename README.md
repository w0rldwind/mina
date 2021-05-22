# mina restarter

Перезагрузка ноды:
* при отставании
* при статусах CONNECTING, LISTENING, OFFLINE, BOOTSTRAP, CATCHUP (если нода работает дольше отведенного на загрузку времени, настройка в файле m.sh)


Загрузка
---
```
cd
mkdir mrestart && cd mrestart
wget https://raw.githubusercontent.com/w0rldwind/mina/main/m.sh
wget https://raw.githubusercontent.com/w0rldwind/mina/main/alert.py
wget https://raw.githubusercontent.com/w0rldwind/mina/main/id.py

chmod +x m.sh
chmod +x alert.py
chmod +x id.py
```

Подготовка
---
```
apt update
apt install python3-pip
pip3 install pyTelegramBotAPI
apt install jq
```

1. Регистрация бота у [@BotFather](https://t.me/BotFather)
2. Добавить токен в alert.py и id.py
3. Запустить `python3 id.py` и написать своему боту "ID". Полученный id добавить в alert.py
4. Добавление в планировщик
```
crontab -e
*/5 * * * * cd ~/mrestart && ./m.sh
```

Настройки в файле m.sh
---

* Имя ноды
* Настройка api
* Время на загрузку ноды
* Команда перезагрузки

