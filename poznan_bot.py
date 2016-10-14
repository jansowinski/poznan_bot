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


browarUrl = ["Multikino+Stary+Browar-633", "Multikino Stary Browar"]
apolloUrl = ["Apollo-70", "Kino Apollo"]
bulgarska19Url = ["Bułgarska+19-1618", "Kino Bułgarska 19"]
charlieUrl = ["Charlie+Monroe+Kino+Malta-1499", "Kino Charlie Monroe"]
kinepolisUrl = ["Cinema+City+Kinepolis-624", "Cinema City Kinepolis"]
plazaUrl = ["Cinema+City+Plaza-568", "Cinema City Plaza"]
multikino51Url = ["Multikino+51-203", "Multikino 51"]
multikinoMaltaUrl = ["Multikino+Malta-1434","Multikino Malta"]
multikinoBrowarUrl = ["Multikino+Stary+Browar-633", "Multikino Stary Browar"]
muzaUrl= ["Muza-75", "Kino Muza"]
palacoweUrl = ["Nowe+Kino+Pałacowe-1854", "Nowe Kino Pałacowe"]
rialtoUrl = ["Rialto-78", "Kino Rialto"]


updater = Updater(token='261419062:AAFe2GkE3xUgDf3ZdMu7qmgCf9CLOTWgg6E')

dispatcher = updater.dispatcher

logging.basicConfig(format='%(asctime)s - %(name)s - %(levelname)s - %(message)s', level=logging.INFO)

def start(bot, update):
    bot.sendMessage(chat_id = update.message.chat_id, text = "POGODA: /pogoda\nREPERTUARY: /kino\n/kino_51 - Multikino 51\n/kino_browar - Multikino Stary Browar\n/kino_malta - Multikino Malta\n/kino_muza - Muza\n/kino_rialto - Rialto")

start_handler = CommandHandler('start', start)
dispatcher.add_handler(start_handler)

updater.start_polling()

def kino_muza (bot, update):
    global muzaUrl
    bot.sendMessage(chat_id = update.message.chat_id, text = muzaUrl[1] + "\n\n" +"\n".join(kina.seanse(muzaUrl)))

kino_muza_handler = CommandHandler('kino_muza', kino_muza)
dispatcher.add_handler(kino_muza_handler)

def kino_rialto (bot, update):
    global rialtoUrl
    bot.sendMessage(chat_id = update.message.chat_id, text = rialtoUrl[1] + "\n\n" +"\n".join(kina.seanse(rialtoUrl)))

kino_rialto_handler = CommandHandler('kino_rialto', kino_rialto)
dispatcher.add_handler(kino_rialto_handler)

def kino_51 (bot, update):
    global multikino51Url
    bot.sendMessage(chat_id = update.message.chat_id, text = multikino51Url[1] + "\n\n" + "\n".join(kina.seanse(multikino51Url)))

kino_51_handler = CommandHandler('kino_51', kino_51)
dispatcher.add_handler(kino_51_handler)

def kino_browar (bot, update):
    global multikinoBrowarUrl
    bot.sendMessage(chat_id = update.message.chat_id, text = multikinoBrowarUrl[1] + "\n\n" + "\n".join(kina.seanse(multikinoBrowarUrl)))

kino_browar_handler = CommandHandler('kino_browar', kino_browar)
dispatcher.add_handler(kino_browar_handler)

def kino_malta (bot, update):
    global multikinoMaltaUrl
    bot.sendMessage(chat_id = update.message.chat_id, text = multikinoMaltaUrl[1] + "\n\n" + "\n".join(kina.seanse(multikinoMaltaUrl)))

kino_malta_handler = CommandHandler('kino_malta', kino_malta)
dispatcher.add_handler(kino_malta_handler)

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

def kino (bot, update):
    global rialtoUrl
    global muzaUrl
    global maltaUrl
    global browarUrl
    global piecJedenUrl
    bot.sendMessage(chat_id = update.message.chat_id, text = "MULTIKINO MALTA:\n\n" + "\n".join(kina.multikino(maltaUrl)))
    bot.sendMessage(chat_id = update.message.chat_id, text = "MULTIKINO BROWAR:\n\n" + "\n".join(kina.multikino(browarUrl)))
    bot.sendMessage(chat_id = update.message.chat_id, text = "MULTIKINO 51:\n\n" + "\n".join(kina.multikino(piecJedenUrl)))
    bot.sendMessage(chat_id = update.message.chat_id, text = "KINO RIALTO:\n\n" + "\n".join(kina.rialto(rialtoUrl)))
    bot.sendMessage(chat_id = update.message.chat_id, text = "KINO MUZA:**\n\n" + "\n".join(kina.muza(muzaUrl)), parse_mode=telegram.ParseMode.MARKDOWN)

kino_handler = CommandHandler('kino', kino)
dispatcher.add_handler(kino_handler)
