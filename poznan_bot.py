import urllib.request
import datetime
import telegram
import logging
from bs4 import BeautifulSoup
import galeria
import kina



rialtoUrl = "http://www.kinorialto.poznan.pl/"
muzaUrl = "http://kinomuza.pl/repertuar"
maltaUrl = "https://multikino.pl/pl/repertuar/poznan-malta"
browarUrl = "https://multikino.pl/pl/repertuar/poznan-stary-browar"
piecJedenUrl = "https://multikino.pl/pl/repertuar/poznan-multikino-51"
arsenalUrl = "http://www.arsenal.art.pl/wystawa/"

# zamekUrl = "http://www.zamek.poznan.pl/news,pl,5177.html"
# charlieUrl = "http://www.kinomalta.pl/"


# Passing today's date to url

def hourNum():
    hourNow = int(datetime.datetime.today().strftime('%H'))

    if hourNow >= 7 and hourNow < 13:
        return "00"
    elif hourNow >= 13 and hourNow < 19:
        return "06"
    elif hourNow >= 19 or (hourNow  >= 0 and hourNow < 1):
        return "12"
    elif hourNow >= 1 and hourNow < 7:
        return "18"
    else:
        return "00"

def urlMaker():
    urlAdress = "http://www.meteo.pl/um/metco/mgram_pict.php?ntype=0u&fdate=" + dateSetter() + hourNum() + "&row=400&col=180&lang=pl"
    return urlAdress

def nameSetter():
    return "pogoda.jpg" #+ dateSetter() + hourNum() + ".jpg"
# BOT

from telegram.ext import Updater
from telegram.ext import CommandHandler

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
    bot.sendMessage(chat_id = update.message.chat_id, text = "KINO MUZA:\n\n" +"\n".join(kina.muza(muzaUrl)))

kino_muza_handler = CommandHandler('kino_muza', kino_muza)
dispatcher.add_handler(kino_muza_handler)

def kino_rialto (bot, update):
    global rialtoUrl
    bot.sendMessage(chat_id = update.message.chat_id, text = "KINO RIALTO:\n\n" +"\n".join(kina.rialto(rialtoUrl)))

kino_rialto_handler = CommandHandler('kino_rialto', kino_rialto)
dispatcher.add_handler(kino_rialto_handler)

def kino_51 (bot, update):
    global piecJedenUrl
    bot.sendMessage(chat_id = update.message.chat_id, text ="MULTIKINO 51:\n\n" + "\n".join(kina.multikino(piecJedenUrl)))

kino_51_handler = CommandHandler('kino_51', kino_51)
dispatcher.add_handler(kino_51_handler)

def kino_browar (bot, update):
    global browarUrl
    bot.sendMessage(chat_id = update.message.chat_id, text ="MULTIKINO BROWAR:\n\n" + "\n".join(kina.multikino(browarUrl)))

kino_browar_handler = CommandHandler('kino_browar', kino_browar)
dispatcher.add_handler(kino_browar_handler)

def kino_malta (bot, update):
    global maltaUrl
    bot.sendMessage(chat_id = update.message.chat_id, text = "MULTIKINO MALTA:\n\n" + "\n".join(kina.multikino(maltaUrl)))

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


# Main function

# array = file.write("# Kino\n\ncreated at " + datetime.datetime.today().strftime('%H:%M:%S / %d.%m.%Y') + "\n\n## Muza\n\n")
#
#     (element + "\n")
# file.write("\n\n## Rialto\n\n")
# for element in rialto(rialtoUrl):
#     file.write(element + "\n")
# file.write("\n\n## Multikino 51\n\n")
# for element in multikino(piecJedenUrl):
#     file.write(element + "\n")
# file.write("\n\n## Multikino Stary Browar\n\n")
# for element in multikino(browarUrl):
#     file.write(element + "\n")
# file.write("\n\n## Multikino Malta\n\n")
# for element in multikino(maltaUrl):
#     file.write(element + "\n")
# file.write("\n# Pogoda\n\n![](pogoda.jpg)")

# Charlie monroe
#
# charlie = assigner(charlieUrl)
# charlieDiv = charlie.find("table", "border-collapse: collapse; width: 563px; height: 342px;")
# print("=================")
# print("|Charlie Monroe:|")
# print("=================")
# for child in muzaDiv.children:
#     childTime = child.find("time")
#     if childTime == -1:
#         pass
#     else:
#         childTiltle = child.find("h4")
#         print(childTiltle.contents[0].contents[0], " ||| ", childTime.contents[0])
