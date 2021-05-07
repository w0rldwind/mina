#!/bin/bash

#Настройки
#Имя ноды (например Mina1)
nodeName=Mina
#Настройка api
graphqlApi=http://localhost:3085/graphql
#Время на загрузку ноды (мин)
loadMin=30
#Команда перезагрузки
restartCmd='docker restart mina'
#Команды после перезапуска (on/off)
directions=off
cmd[1]='docker exec -it mina mina client set-snark-work-fee 0'
#Перезапускать ноду, если до блока осталось меньше часа?(on/off)
hrestart=off

function start() {
	data=$(curl -d '{"query": "{daemonStatus{blockchainLength,highestUnvalidatedBlockLengthReceived,uptimeSecs,peers,syncStatus,nextBlockProduction{times{startTime}}}}"}' -H 'Content-Type: application/json' $graphqlApi)
	checkConn=$(echo $data | grep -o "data")

	if [ "$checkConn" = 'data' ]; then
		blockHeight=$(echo $data | jq . | grep -oP '(?<="blockchainLength": )[^,]*')
		unvalidatedBlockHeight=$(echo $data | jq . | grep -oP '(?<="highestUnvalidatedBlockLengthReceived": )[^,]*')
		uptimeSecs=$(echo $data | jq . | grep -oP '(?<="uptimeSecs": )[^,]*')
		peers=$(echo $data | jq '.data.daemonStatus.peers' | grep -o "{}" | wc -w)
		syncStatus=$(echo $data | jq . | grep -oP '(?<="syncStatus": ")[^"]*')
		nextBlockTime=$(echo $data | jq '.data.daemonStatus.nextBlockProduction' | grep -oP '(?<="startTime": ")[^"]*')

		currentTime=$(date +%s)
		uptime=$(eval "echo $(date -ud "@$uptimeSecs" +'$((%s/3600/24))д %H:%M:%S')")
		let "stuck=(unvalidatedBlockHeight-1)"
		let "loadSec=(loadMin*60)"
		nextBlock
	else
		echo $(date +'%d.%m.%Y %H:%M:%S') Ошибка соединения >> ~/mrestart/${nodeName}.log
		python3 alert.py error
	fi
}

function nextBlock() {
	if [ -z "$nextBlockTime" ]; then
		if [ "$syncStatus" = 'BOOTSTRAP' ]; then
			timeToBlock='загрузка'
			height
		else
			timeToBlock='не в этой эпохе'
			echo $timeToBlock
			height
		fi
	else
		let "secsToBlock=(nextBlockTime/1000-currentTime)"
		timeToBlock=$(eval "echo $(date -ud "@$secsToBlock" +'$((%s/3600/24))д %H:%M:%S')")
		height
	fi
}

function height() {
	if [ "$blockHeight" = 'null' ]; then
		blockHeight='загрузка'
	fi
	if [ "$unvalidatedBlockHeight" -eq '0' ]; then
		unvalidatedBlockHeight='загрузка'
	fi
	checkStatus
}

function info() {
	python3 alert.py succeeded info "${nodeName}" "${blockHeight}" "${unvalidatedBlockHeight}" "${uptime}" "${peers}" "${syncStatus}" "${timeToBlock}"
}

function canBeRestarted() {
	python3 alert.py succeeded canBeRestarted "${nodeName}" "${blockHeight}" "${unvalidatedBlockHeight}" "${uptime}" "${peers}" "${syncStatus}" "${timeToBlock}"
	eval $restartCmd
}

function cantBeRestarted() {
	python3 alert.py succeeded cantBeRestarted "${nodeName}" "${blockHeight}" "${unvalidatedBlockHeight}" "${uptime}" "${peers}" "${syncStatus}" "${timeToBlock}"
}

function checkStatus() {
	if [ "$syncStatus" = 'SYNCED' ]; then
		#Если нода не отстает
		if [ "$blockHeight" -ge "$stuck" ]; then
			#Всё хорошо
			if [ "$uptimeSecs" -lt "$loadSec" ]; then
				echo $(date +'%d.%m.%Y %H:%M:%S') Нода синхронизирована. Работает менее $loadMin мин. Оповещение >> ~/mrestart/${nodeName}.log
				info
				if [ "$directions" = 'on' ]; then
					echo $(date +'%d.%m.%Y %H:%M:%S') Дополнительные команды >> ~/mrestart/${nodeName}.log
					cmdq=$(echo ${#cmd[@]})

					#Цикл выполнения команд
					for ((i=1; i<=cmdq; i++)); do
					#Номер команды
					let "n=0+$i"
					${cmd[$n]} >> ~/mrestart/${nodeName}.log
					done
				fi
			fi
		else
			echo $(date +'%d.%m.%Y %H:%M:%S') Нода отстала. Когда блок? >> ~/mrestart/${nodeName}.log
			if [ "$uptimeSecs" -gt "$loadSec" ]; then
				if [ "$timeToBlock" = 'не в этой эпохе' ]; then
					echo $(date +'%d.%m.%Y %H:%M:%S') Блок не в этой эпохе. Оповещение и перезагрузка >> ~/mrestart/${nodeName}.log
					canBeRestarted
				else
					if [ "$secsToBlock" -gt '3600' ]; then
						echo $(date +'%d.%m.%Y %H:%M:%S') Блок в этой эпохе. До блока более часа. Оповещение и перезагрузка >> ~/mrestart/${nodeName}.log
						canBeRestarted
					else
						if [ "$1hrestart" = 'on' ]; then
							echo $(date +'%d.%m.%Y %H:%M:%S') Блок в этой эпохе. До блока менее часа. Оповещение и перезагрузка >> ~/mrestart/${nodeName}.log
							canBeRestarted
						else
							echo $(date +'%d.%m.%Y %H:%M:%S') Блок в этой эпохе. До блока менее часа. Оповещение >> ~/mrestart/${nodeName}.log
							cantBeRestarted
						fi
					fi
				fi
			else
				echo $(date +'%d.%m.%Y %H:%M:%S') Нода синхронизирована. Работает менее $loadMin мин. Отстает по блокам. Оповещение >> ~/mrestart/${nodeName}.log
				info
			fi
		fi
	else
		if [ "$uptimeSecs" -gt "$loadSec" ]; then
			echo $(date +'%d.%m.%Y %H:%M:%S') Нода не синхронизирована. Работает более $loadMin мин. Оповещение и перезагрузка >> ~/mrestart/${nodeName}.log
			canBeRestarted
		else
			echo $(date +'%d.%m.%Y %H:%M:%S') Нода не синхронизирована. Работает менее $loadMin мин. Оповещение >> ~/mrestart/${nodeName}.log
			info
		fi
	fi
}

start
