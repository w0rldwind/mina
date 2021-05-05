#!/usr/bin/python3
# -*- coding: utf-8 -*-

import telebot

token='12345678'

bot = telebot.TeleBot(token)

@bot.message_handler(content_types=['text'])
def info(message):

	if message.text.lower() == 'id':
		telid = message.from_user.id
		bot.send_message(message.chat.id, 'Telegram ID: ''' + str(telid) + '')

bot.polling()
