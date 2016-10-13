import urllib.request
import datetime
from bs4 import BeautifulSoup


def assigner (arg):
    return BeautifulSoup(urllib.request.urlopen(arg), "html.parser")

# Multikina Malta
def multikino(adressUrl):
    kino = assigner(adressUrl)
    kinoDiv = kino.find("ul", "list image-list")
    array = []
    for child in kinoDiv.children:
        arrayTemp = []
        if child == "\n":
            pass
        else:
            childTitle = child.find("a", "title").contents[0]
            arrayTemp.append(childTitle + " / ")
            for childTime in child.find("div", "showings").children:
                if childTime != "\n":
                    arrayTemp.append(childTime.contents[0].strip() + " ")
            array.append("".join(arrayTemp))
    return array

# RIALTO
def rialto(adressUrl):
    kino = assigner(adressUrl)
    kinoDiv = kino.find("div", "mk-accordion mk-shortcode accordion-action fancy-style ").find("ul")
    array = []
    for child in kinoDiv.children:
        array.append((child.contents[0].contents[0][6:].title() + " / " + child.contents[0].contents[0][0:5]))
    return array

# MUZA
def muza(urlAdress):
    kino = assigner(urlAdress)
    kinoDiv = kino.find("div", "poster-list")
    array = []
    for child in kinoDiv.children:
        childTime = child.find("time")
        if childTime == -1:
            pass
        else:
            childTiltle = child.find("h4")
            array.append((childTiltle.contents[0].contents[0].title() + " / " + childTime.contents[0]))
    return array

def dateSetter():
    if hourNum() == "18":
        now = datetime.date.fromordinal(datetime.date.today().toordinal()-1).strftime('%Y%m%d')
    else:
        now = datetime.datetime.today().strftime('%Y%m%d')
    return now
