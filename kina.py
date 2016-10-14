import urllib.request
import datetime
from bs4 import BeautifulSoup


def assigner (arg):
    return BeautifulSoup(urllib.request.urlopen("http://www.filmweb.pl/showtimes/Pozna%C5%84/" + arg[0]), "html.parser")

# Multikina Malta
def seanse(adressUrl):
    kino = assigner(adressUrl)
    kinoDiv = kino.find("ul", "cinema-films")
    array = []
    for child in kinoDiv.children:
        timeArray = []
        title = child.find("a", "filmTitle").contents[0]
        for item in child.find("ul", "hoursList").find_all("li"):
            timeArray.append(item.contents[0])
        arrayTemp = []
        arrayTemp.append(title)
        arrayTemp.append(" ".join(timeArray))
        array.append(" / ".join(arrayTemp))
    return array
