#!/bin/bash

#Settings
#Node Name (e.g. Mina1)
nodeName=Mina1
#Custom API (if required)
graphqlApi=http://localhost:3085/graphql
#Time to load a node (min)
loadMin=30
#Reboot Command (edit for docker)
restartCmd='systemctl --user restart mina'
#Commands after restart (on/off)
directions=off
cmd[1]='mina client set-snark-work-fee 0.000005'
#Restart the node if less than an hour is left before the block? (on/off)
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
		uptime=$(eval "echo $(date -ud "@$uptimeSecs" +'$((%s/3600/24))d %H:%M:%S')")
		let "stuck=(unvalidatedBlockHeight-1)"
		let "loadSec=(loadMin*60)"
		nextBlock
	else
		echo $(date +'%d.%m.%Y %H:%M:%S') Connection Error >> ~/mrestart/${nodeName}.log
		python3 alert.py error "${nodeName}"
	fi
}

function nextBlock() {
	if [ -z "$nextBlockTime" ]; then
		if [ "$syncStatus" = 'BOOTSTRAP' ]; then
			timeToBlock='Syncing'
			height
		else
			timeToBlock='None in this epoch'
			echo $timeToBlock
			height
		fi
	else
		let "secsToBlock=(nextBlockTime/1000-currentTime)"
		timeToBlock=$(eval "echo $(date -ud "@$secsToBlock" +'$((%s/3600/24))d %H:%M:%S')")
		height
	fi
}

function height() {
	if [ "$blockHeight" = 'null' ]; then
		blockHeight='Syncing'
	fi
	if [ "$unvalidatedBlockHeight" -eq '0' ]; then
		unvalidatedBlockHeight='Syncing'
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
		#If the node is not lagging behind
		if [ "$blockHeight" -ge "$stuck" ]; then
			#Things are good
			if [ "$uptimeSecs" -lt "$loadSec" ]; then
				echo $(date +'%d.%m.%Y %H:%M:%S') Node is synced. Работает менее $loadMin min. Alert >> ~/mrestart/${nodeName}.log
				info
				if [ "$directions" = 'on' ]; then
					echo $(date +'%d.%m.%Y %H:%M:%S') Additional commands >> ~/mrestart/${nodeName}.log
					cmdq=$(echo ${#cmd[@]})

					#Cycle of command execution
					for ((i=1; i<=cmdq; i++)); do
					#Command number
					let "n=0+$i"
					${cmd[$n]} >> ~/mrestart/${nodeName}.log
					done
				fi
			fi
		else
			echo $(date +'%d.%m.%Y %H:%M:%S') Node falling behind. When is the block? >> ~/mrestart/${nodeName}.log
			if [ "$uptimeSecs" -gt "$loadSec" ]; then
				if [ "$timeToBlock" = 'None in this epoch' ]; then
					echo $(date +'%d.%m.%Y %H:%M:%S') Block not ín this epoch. Notify and restart >> ~/mrestart/${nodeName}.log
					canBeRestarted
				else
					if [ "$secsToBlock" -gt '3600' ]; then
						echo $(date +'%d.%m.%Y %H:%M:%S') Block ín this epoch. More than an hour to the block. Notify and restart >> ~/mrestart/${nodeName}.log
						canBeRestarted
					else
						if [ "$1hrestart" = 'on' ]; then
							echo $(date +'%d.%m.%Y %H:%M:%S') Block ín this epoch. Less than an hour to the block. Notify and restart >> ~/mrestart/${nodeName}.log
							canBeRestarted
						else
							echo $(date +'%d.%m.%Y %H:%M:%S') Block ín this epoch. Less than an hour to the block. Alert >> ~/mrestart/${nodeName}.log
							cantBeRestarted
						fi
					fi
				fi
			else
				echo $(date +'%d.%m.%Y %H:%M:%S') The node is synced. Работает менее $loadMin min. Lags behind. Alert >> ~/mrestart/${nodeName}.log
				info
			fi
		fi
	else
		if [ "$uptimeSecs" -gt "$loadSec" ]; then
			echo $(date +'%d.%m.%Y %H:%M:%S') Node is not synced. Работает более $loadMin min. Notify and restart >> ~/mrestart/${nodeName}.log
			canBeRestarted
		else
			echo $(date +'%d.%m.%Y %H:%M:%S') Node is not synced. Работает менее $loadMin min. Alert >> ~/mrestart/${nodeName}.log
			info
		fi
	fi
}

start
