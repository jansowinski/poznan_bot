import datetime
import urllib.request
from bs4 import BeautifulSoup

def chart(loc_lat, loc_lon):
    api_url = "http://api.met.no/weatherapi/locationforecastlts/1.3/?lat=" + loc_lat + ";lon=" + loc_lon

    weather_object = urllib.request.urlopen(api_url).read()
    weather_object = BeautifulSoup(weather_object, features="xml")
    print(weather_object)
    return weather_object.contents[0]