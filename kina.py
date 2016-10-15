import urllib.request
import datetime
from bs4 import BeautifulSoup

urls = {"browarUrl" : ["Multikino+Stary+Browar-633", "Multikino Stary Browar"],
"apolloUrl" : ["Apollo-70", "Kino Apollo"],
"bulgarska19Url" : ["Bu%C5%82garska+19-1618", "Kino Bułgarska 19"],
"charlieUrl" : ["Charlie+Monroe+Kino+Malta-1499", "Kino Charlie Monroe"],
"kinepolisUrl" : ["Cinema+City+Kinepolis-624", "Cinema City Kinepolis"],
"plazaUrl" : ["Cinema+City+Plaza-568", "Cinema City Plaza"],
"multikino51Url" : ["Multikino+51-203", "Multikino 51"],
"multikinoMaltaUrl" : ["Multikino+Malta-1434","Multikino Malta"],
"multikinoBrowarUrl" : ["Multikino+Stary+Browar-633", "Multikino Stary Browar"],
"muzaUrl": ["Muza-75", "Kino Muza"],
"palacoweUrl" : ["Nowe+Kino+Pa%C5%82acowe-1854", "Nowe Kino Pałacowe"],
"rialtoUrl" : ["Rialto-78", "Kino Rialto"]}


# sprawdza poprawność zmiennych które dostaje i wysyła go dalej

def seanse(nazwaKina="wszystkie", day=0):
    global urls
    if int(day) > 7 or int(day) < 0:
        day = 0
    kinoUrl = setKino(nazwaKina)
    if kinoUrl == "0":
        return wszystkie(urls, str(day))
    else:
        return returner(assigner(kinoUrl[0], str(day)), kinoUrl[1])


# Dostaje nazwę kina, zwraca array z [0] - stringiem z fragmentem linka, [1] - stringiem z nazwą kina
def setKino(kino):
    global urls
    kino = str(kino)
    return {
        "browar" : urls["browarUrl"],
        "apollo" : urls["apolloUrl"],
        "bulgarska" : urls["bulgarska19Url"],
        "charlie" : urls["charlieUrl"],
        "kinepolis" : urls["kinepolisUrl"],
        "plaza" : urls["plazaUrl"],
        "51" : urls["multikino51Url"],
        "malta" : urls["multikinoMaltaUrl"],
        "Browar" : urls["multikinoBrowarUrl"],
        "muza" : urls["muzaUrl"],
        "palacowe" : urls["palacoweUrl"],
        "rialto" : urls["rialtoUrl"],
        "wszystkie" : "0",
    }[kino]

# parsuje dokumeny na podstawie fragmentu linka który dostaje (urlLink) i dnia
def assigner (urlLink, day):
    return BeautifulSoup(urllib.request.urlopen("http://www.filmweb.pl/showtimes/Pozna%C5%84/" + urlLink + "?day="+ str(day)), "html.parser")


# zwraca repertuar na podstawie sparsowanego dokumentu który dostaje (assigned)

def returner(assigned, nazwaKina):
    kinoDiv = assigned.find("ul", "cinema-films")
    array = []
    array.append(nazwaKina+"\n")
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

# zwraca wszystkie repertuary na podstawie danego dnia (day)

def wszystkie(urls, day):
    array = []
    for key, value in urls.items():
        a = returner(assigner(value[0], str(day)), value[1])
        array.append("\n\n" +"\n".join(a))
    return array
