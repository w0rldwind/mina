#!/usr/bin/python3
# -*- coding: utf-8 -*-

import telebot
import sys

tgid=123456789
token='123456789'

bot = telebot.TeleBot(token)

#print (sys.argv[1]) соединение
#print (sys.argv[2]) After restart / Restart / проверка ноды
#print (sys.argv[3]) Node name
#print (sys.argv[4]) Node Block Height
#print (sys.argv[5]) Network Block Height
#print (sys.argv[6]) Uptime
#print (sys.argv[7]) Peers
#print (sys.argv[8]) Status
#print (sys.argv[9]) Next Block

if sys.argv[1] == 'succeeded':
	if sys.argv[2] == 'info':
		msg = bot.send_message(tgid, 'Node: ' + sys.argv[3] + '\nNode Block Height: ' + sys.argv[4] + '\nNetwork Block Height: ' + sys.argv[5] + '\nUptime: ' + sys.argv[6] + '\nPeers: ' + sys.argv[7] + '\nStatus: ' + sys.argv[8] + '\nNext Block: ' + sys.argv[9] + '')
	elif sys.argv[2] == 'canBeRestarted':
		msg = bot.send_message(tgid, 'Node: ' + sys.argv[3] + '\nNode Block Height: ' + sys.argv[4] + '\nNetwork Block Height: ' + sys.argv[5] + '\nUptime: ' + sys.argv[6] + '\nPeers: ' + sys.argv[7] + '\nStatus: ' + sys.argv[8] + '\nNext Block: ' + sys.argv[9] + '\nRestart in progress...')
	elif sys.argv[2] == 'cantBeRestarted':
		msg = bot.send_message(tgid, 'Node: ' + sys.argv[3] + '\nNode Block Height: ' + sys.argv[4] + '\nNetwork Block Height: ' + sys.argv[5] + '\nUptime: ' + sys.argv[6] + '\nPeers: ' + sys.argv[7] + '\nStatus: ' + sys.argv[8] + '\nNext Block: ' + sys.argv[9] + '\nLess than 1hr to the block, Restart is retricted. Check Node!')
else:
	msg = bot.send_message(tgid, 'No connection to the node ' + sys.argv[2] + '. Probably node is restarting.')
