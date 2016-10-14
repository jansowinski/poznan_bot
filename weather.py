import datetime

def dateSetter():
    if hourNum() == "18":
        now = datetime.date.fromordinal(datetime.date.today().toordinal()-1).strftime('%Y%m%d')
    else:
        now = datetime.datetime.today().strftime('%Y%m%d')
    return now

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
