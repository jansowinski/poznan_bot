import urllib.request
from datetime import datetime
from bs4 import BeautifulSoup

zanieczyszczenia_url = 'http://powietrze.poznan.wios.gov.pl/dane-pomiarowe/automatyczne/stacja/1/parametry/8-5-12-3-11-9-10-13-4-1-6-15/dzienny/13.12.2016'
def now():
    return datetime.now().hour
print(now())

def zanieczysczenia():
    return BeautifulSoup(urllib.request.urlopen(zanieczyszczenia_url))

print(zanieczysczenia())