import urllib.request
import datetime
import telegram
import logging
from bs4 import BeautifulSoup
import galeria
import kina
import pogoda
from telegram.ext import Updater
from telegram.ext import CommandHandler

updater = Updater(token='261419062:AAFe2GkE3xUgDf3ZdMu7qmgCf9CLOTWgg6E')

dispatcher = updater.dispatcher

logging.basicConfig(format='%(asctime)s - %(name)s - %(levelname)s - %(message)s', level=logging.INFO)

def start(bot, update):
    bot.sendMessage(chat_id = update.message.chat_id, text = "POGODA: /pogoda\nREPERTUARY: /kino <dzien> <nazwa> (np. '/kino 1 muza')")

start_handler = CommandHandler('start', start)
dispatcher.add_handler(start_handler)

updater.start_polling()

def kino (bot, update, args):
    if len(args) == 0:
        args.append(0)
    if len(args) == 1:
        args.append("wszystkie")
    global muzaUrl
    bot.sendMessage(chat_id = update.message.chat_id, text = "\n\n" +"\n".join(kina.seanse(args[0], args[1])))

kino_handler = CommandHandler('kino', kino, pass_args=True)
dispatcher.add_handler(kino_handler)

#
def pogoda (bot, update):
    global maltaUrl
    bot.sendMessage(chat_id = update.message.chat_id, text = urlMaker())

pogoda_handler = CommandHandler('pogoda', pogoda)
dispatcher.add_handler(pogoda_handler)

def arsenal (bot, update):
    global arsenalUrl
    bot.sendMessage(chat_id = update.message.chat_id, text = "GALERIA ARSENAŁ:\n\n" + "\n".join(galeria.arsenal(arsenalUrl)))

arsenal_handler = CommandHandler('arsenal', arsenal)
dispatcher.add_handler(arsenal_handler)

# def kino (bot, update):
#     global rialtoUrl
#     global muzaUrl
#     global maltaUrl
#     global browarUrl
#     global piecJedenUrl
#     bot.sendMessage(chat_id = update.message.chat_id, text = "MULTIKINO MALTA:\n\n" + "\n".join(kina.multikino(maltaUrl)))
#     bot.sendMessage(chat_id = update.message.chat_id, text = "MULTIKINO BROWAR:\n\n" + "\n".join(kina.multikino(browarUrl)))
#     bot.sendMessage(chat_id = update.message.chat_id, text = "MULTIKINO 51:\n\n" + "\n".join(kina.multikino(piecJedenUrl)))
#     bot.sendMessage(chat_id = update.message.chat_id, text = "KINO RIALTO:\n\n" + "\n".join(kina.rialto(rialtoUrl)))
#     bot.sendMessage(chat_id = update.message.chat_id, text = "KINO MUZA:**\n\n" + "\n".join(kina.muza(muzaUrl)), parse_mode=telegram.ParseMode.MARKDOWN)
#
# kino_handler = CommandHandler('kino', kino)
# dispatcher.add_handler(kino_handler)
