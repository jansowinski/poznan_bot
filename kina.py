import urllib.request
import datetime
from bs4 import BeautifulSoup

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

def assigner (arg, day):
    return BeautifulSoup(urllib.request.urlopen("http://www.filmweb.pl/showtimes/Pozna%C5%84/" + arg + "?day="+ str(day)), "html.parser")

def setKino(kino):
    global browarUrl, apolloUrl, bulgarska19Url, charlieUrl, kinepolisUrl, plazaUrl, multikino51Url, multikinoMaltaUrl, multikinoBrowarUrl, muzaUrl, palacoweUrl, rialtoUrl
    kino = str(kino)
    return {
        "palacowe" : palacoweUrl,
        "browar" : browarUrl,
        "apollo" : apolloUrl,
        "bulgarska" : bulgarska19Url,
        "charlie" : charlieUrl,
        "kinepolis" : kinepolisUrl,
        "plaza" : plazaUrl,
        "51" : multikino51Url,
        "malta" : multikinoMaltaUrl,
        "Browar" : multikinoBrowarUrl,
        "muza" : muzaUrl,
        "palacowe" : palacoweUrl,
        "rialto" : rialtoUrl,
        "wszystkie" : rialtoUrl,
    }[kino]

# Multikina Malta
def seanse(day=0, nazwaKina="wszystkie"):
    if int(day) > 7 or int(day) < 0:
        day = 0
    kinoArray = setKino(nazwaKina)
    kino = assigner(kinoArray[0], str(day))
    kinoDiv = kino.find("ul", "cinema-films")
    array = []
    array.append(kinoArray[1]+"\n")
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
