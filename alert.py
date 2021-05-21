#!/usr/bin/python3
# -*- coding: utf-8 -*-

import telebot
import sys

tgid=123456789
token='123456789'

bot = telebot.TeleBot(token)

#print (sys.argv[1]) соединение
#print (sys.argv[2]) после перезагрузки / перезагрузка / проверка ноды
#print (sys.argv[3]) имя ноды
#print (sys.argv[4]) высота блока ноды
#print (sys.argv[5]) высота блока сети
#print (sys.argv[6]) аптайм
#print (sys.argv[7]) пиры
#print (sys.argv[8]) статус
#print (sys.argv[9]) следующий блок

if sys.argv[1] == 'succeeded':
	if sys.argv[2] == 'info':
		msg = bot.send_message(tgid, 'Нода: ' + sys.argv[3] + '\nВысота блока ноды: ' + sys.argv[4] + '\nВысота блока сети: ' + sys.argv[5] + '\nАптайм: ' + sys.argv[6] + '\nПиры: ' + sys.argv[7] + '\nСтатус: ' + sys.argv[8] + '\nСледующий блок: ' + sys.argv[9] + '')
	elif sys.argv[2] == 'canBeRestarted':
		msg = bot.send_message(tgid, 'Нода: ' + sys.argv[3] + '\nВысота блока ноды: ' + sys.argv[4] + '\nВысота блока сети: ' + sys.argv[5] + '\nАптайм: ' + sys.argv[6] + '\nПиры: ' + sys.argv[7] + '\nСтатус: ' + sys.argv[8] + '\nСледующий блок: ' + sys.argv[9] + '\nВыполняется перезагрузка...')
	elif sys.argv[2] == 'cantBeRestarted':
		msg = bot.send_message(tgid, 'Нода: ' + sys.argv[3] + '\nВысота блока ноды: ' + sys.argv[4] + '\nВысота блока сети: ' + sys.argv[5] + '\nАптайм: ' + sys.argv[6] + '\nПиры: ' + sys.argv[7] + '\nСтатус: ' + sys.argv[8] + '\nСледующий блок: ' + sys.argv[9] + '\nДо блока менее 1ч, перезагрузка запрещена. Проверь ноду!')
else:
	msg = bot.send_message(tgid, 'Нет соединения с нодой ' + sys.argv[3] + '. Возможно нода перезагружается.')
