import urllib.request
import datetime
import telegram
import logging
from bs4 import BeautifulSoup
import galeria
import kina
import weather
from telegram.ext import Updater
from telegram.ext import CommandHandler

updater = Updater(token='261419062:AAFe2GkE3xUgDf3ZdMu7qmgCf9CLOTWgg6E')

dispatcher = updater.dispatcher

logging.basicConfig(format='%(asctime)s - %(name)s - %(levelname)s - %(message)s', level=logging.INFO)

def start(bot, update):
    bot.sendMessage(chat_id = update.message.chat_id, text = "POGODA:\n/pogoda\n\nREPERTUARY:\n/kino *<nazwa> **<ilość dni od dzisia>\n(np. /kino muza 1)\n\nObsługiwane kina (komendy, jak nazwy tutaj):\nbrowar\n51\nmalta\nkinepolis\nplaza\ncharlie\npalacowe\nmuza\nrialto\nbulgarska\napollo\nwszystkie")

start_handler = CommandHandler('start', start)
dispatcher.add_handler(start_handler)

updater.start_polling()

def kino (bot, update, args):
    if len(args) == 0:
        args.append("wszystkie")
        args.append(0)
        for items in kina.seanse(args[0], args[1]):
            bot.sendMessage(chat_id = update.message.chat_id, text = "\n" +"".join(items))
        return None
    elif len(args) == 1:
        args.append(0)
        if args[0] == "wszystkie":
            for items in kina.seanse(args[0], args[1]):
                bot.sendMessage(chat_id = update.message.chat_id, text = "\n" +"".join(items))
            return None
    elif len(args) == 2 and args[0] == "wszystkie":
        for items in kina.seanse(args[0], args[1]):
            bot.sendMessage(chat_id = update.message.chat_id, text = "\n" +"".join(items))
        return None
    bot.sendMessage(chat_id = update.message.chat_id, text = "\n\n" +"\n".join(kina.seanse(args[0], args[1])))
    return None

kino_handler = CommandHandler('kino', kino, pass_args=True)
dispatcher.add_handler(kino_handler)


def pogoda (bot, update):
    global maltaUrl
    bot.sendMessage(chat_id = update.message.chat_id, text = weather.urlMaker())

pogoda_handler = CommandHandler('pogoda', pogoda)
dispatcher.add_handler(pogoda_handler)

def arsenal (bot, update):
    global arsenalUrl
    bot.sendMessage(chat_id = update.message.chat_id, text = "GALERIA ARSENAŁ:\n\n" + "\n".join(galeria.arsenal(arsenalUrl)))

arsenal_handler = CommandHandler('arsenal', arsenal)
dispatcher.add_handler(arsenal_handler)
