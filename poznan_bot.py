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
from telegram.ext import MessageHandler
from telegram.ext import Filters
from galeria import arsenalUrl

token_string = open('token').read().rstrip('\n')

updater = Updater(token=token_string) #(poznan_bot)
#updater = Updater(token='303754093:AAGCVT4cx0-h21NDKboRxnJzenxiqDxkAOA') #(janko_bot)


dispatcher = updater.dispatcher

logging.basicConfig(format='%(asctime)s - %(name)s - %(levelname)s - %(message)s', level=logging.INFO)

def start(bot, update):
    bot.sendMessage(chat_id = update.message.chat_id, text = "POGODA:\n/pogoda\n\nREPERTUARY:\n/kino *<nazwa> **<ilość dni od dzisia>\n(np. /kino muza 1)\n\nObsługiwane kina (komendy, jak nazwy tutaj):\nbrowar\n51\nmalta\nkinepolis\nplaza\ncharlie\npalacowe\nmuza\nrialto\nbulgarska\napollo\nwszystkie")

start_handler = CommandHandler('start', start)
dispatcher.add_handler(start_handler)

updater.start_polling()



def echo(bot, update):
    loc_lon = str(round(update.to_dict()["message"]["location"]["longitude"], 2))
    loc_lat = str(round(update.to_dict()["message"]["location"]["latitude"], 2))
    yr = "http://api.met.no/weatherapi/locationforecast/1.9/"
    bot.sendMessage(chat_id = update.message.chat_id, text = yr + "?lat=" + loc_lat + ";lon=" + loc_lon)

location_handler = MessageHandler([Filters.location], echo)
dispatcher.add_handler(location_handler)


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
    bot.sendMessage(chat_id = update.message.chat_id, text = weather.urlMaker())

pogoda_handler = CommandHandler('pogoda', pogoda)
dispatcher.add_handler(pogoda_handler)

def arsenal (bot, update):
    global arsenalUrl
    bot.sendMessage(chat_id = update.message.chat_id, text = "GALERIA ARSENAŁ:\n\n" + "\n".join(galeria.arsenal(arsenalUrl)))

arsenal_handler = CommandHandler('arsenal', arsenal)
dispatcher.add_handler(arsenal_handler)
