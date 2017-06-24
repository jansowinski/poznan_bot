import urllib.request
import datetime
import telegram
import logging
from bs4 import BeautifulSoup
import galeria
import kina
import weather
import weather_by_location
import json
from telegram.ext import Updater
from telegram.ext import CommandHandler
from telegram.ext import MessageHandler
from telegram.ext import Filters
from galeria import arsenalUrl


print(json.loads(open('token').read()))
token_string = json.loads(open('token').read())['test']
# token_string = open('token').read().rstrip('\n')

updater = Updater(token=token_string) 

dispatcher = updater.dispatcher

logging.basicConfig(format='%(asctime)s - %(name)s - %(levelname)s - %(message)s', level=logging.INFO)

def start(bot, update):
    bot.sendMessage(chat_id = update.message.chat_id, text = "POGODA:\n/pogoda\n\nREPERTUARY:\n/kino *<nazwa> **<ilość dni od dzisia>\n(np. /kino muza 1)\n\nObsługiwane kina (komendy, jak nazwy tutaj):\nbrowar\n51\nmalta\nkinepolis\nplaza\ncharlie\npalacowe\nmuza\nrialto\nbulgarska\napollo\nwszystkie")



def echo(bot, update):
    loc_lon = str(round(update.to_dict()["message"]["location"]["longitude"], 2))
    loc_lat = str(round(update.to_dict()["message"]["location"]["latitude"], 2))
    bot.sendMessage(chat_id = update.message.chat_id, text = weather_by_location.chart(loc_lat, loc_lon))


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


def pogoda (bot, update):
    bot.sendMessage(chat_id = update.message.chat_id, text = weather.urlMaker())

def arsenal (bot, update):
    global arsenalUrl
    bot.sendMessage(chat_id = update.message.chat_id, text = "GALERIA ARSENAŁ:\n\n" + "\n".join(galeria.arsenal(arsenalUrl)))


arsenal_handler = CommandHandler('arsenal', arsenal)
dispatcher.add_handler(arsenal_handler)

pogoda_handler = CommandHandler('pogoda', pogoda)
dispatcher.add_handler(pogoda_handler)

kino_handler = CommandHandler('kino', kino, pass_args=True)
dispatcher.add_handler(kino_handler)

location_handler = MessageHandler([Filters.location], echo)
dispatcher.add_handler(location_handler)

start_handler = CommandHandler('start', start)
dispatcher.add_handler(start_handler)

updater.start_polling()