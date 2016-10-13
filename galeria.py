import urllib.request
import datetime
import logging
from bs4 import BeautifulSoup

arsenalUrl = "http://www.arsenal.art.pl/wystawa/"

def assigner (arg):
    return BeautifulSoup(urllib.request.urlopen(arg), "html.parser")

def timeChecker (arg):
    standarizedArg = arg.replace(" ", "").lower()
    if "godz" not in standarizedArg:
        today = datetime.datetime.today()
        currentDay = int(today.strftime('%d'))
        currentMonth = int(today.strftime('%m'))
        passedDay = int(standarizedArg[11:13])
        passedMonth = int(standarizedArg[14:16])
        if currentMonth < passedMonth:
            return True
        elif currentMonth == passedMonth and currentDay < passedDay:
            return True
        else:
            return False
    else:
        return False

def arsenal(adressUrl):
    galeria = assigner(adressUrl)
    galeriaDiv = galeria.find("section", "content category")
    array = []
    for child in galeriaDiv.children:
        if child == "\n": continue
        title = child.find("h1")
        if title in {None, -1}: continue
        onDisplay = child.find("p", "czasZdarzenia")

        if timeChecker(onDisplay.contents[0]) == True:
            array.append(title.contents[0])
            array.append(onDisplay.contents[0])
    return array
