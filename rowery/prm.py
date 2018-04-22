import requests
import xml.etree.ElementTree as ET
import math
from math import sin, cos, sqrt, atan2, radians
import time

city_numbs = {
    'Poznan' : [192, 394],
    'Wroclaw' : [148],
    'Warszawa' : [210, 372],
    'Opole' : [202],
    'Bialystok' : [245],
    'Konstancin Jeziora' : [247],
    # Lublin i Świdnik zostały połączone - ta sama taryfa
    'Lublin/Swidnik' : [251, 331],
    'Grodzisk Mazowiecki' : [255],
    'Radom' : [400, 401],
    'Lodz' : [330],
    'Szczecin' : [346],
    'Gliwice' : [393],
    'Stalowa Wola' : [339],
    'Czestochowa' : [450],
    'Kolobrzeg' : [422],
    'Szamotuly' : [446],
    'Ostrow Wielkopolski' : [452],
    'Piaseczno' : [461],
    }

url_base = 'https://nextbike.net/maps/nextbike-official.xml?city='

# ściąga i parsuje dane xml 
def download_parse_data(url):
    xml_string = requests.get(url).text
    root  = ET.fromstring(xml_string)
    return root


# dla danego miasta pobiera odpowiednie dane dla jednego/dwóch kodów
# zwraca je do jednego pliku z wszystkimi właściwościami
def merge_data(city):
    url_numbs = city_numbs[city]
    properties_of_stations = []
    for numb in url_numbs:
        url = url_base + str(numb)
        xml_file = download_parse_data(url)
        properties_of_stations = properties_of_stations + get_properties_of_stations(xml_file)
    return properties_of_stations


# zwraca właściwości stacji
def get_properties_of_stations(xml_file):
    data = []
    for item in xml_file.iter('place'):
        data.append({
            'uid' : item.attrib['uid'],
            'id' : item.attrib['number'],
            'lat' : item.attrib['lat'],
            'lng' : item.attrib['lng'],
            'label' : item.attrib['name'],
            'bikes' : item.attrib['bikes'],
            'free_racks' : item.attrib['free_racks'],
            'rack_locks' : item.attrib['rack_locks'],
            'time' : time.strftime("%H:%M")
        })
    return data


# zwraca uid najbliższych stacji, max_distance w [m]
def get_closest_stops(coords, properties_of_stations):
    closest_stations = []
    # promień ziemi
    R = 6373.0
    lat_1 = radians(coords[0])
    lng_1 = radians(coords[1])
    for item in properties_of_stations:
        array = []
        lat_2 = radians(float(item['lat']))
        lng_2 = radians(float(item['lng']))
        d_lat = lat_2 -lat_1
        d_lng = lng_2 - lng_1
        # obliczenia odległości między punktem a stacjami
        a = sin(d_lat / 2) ** 2 + cos(lat_1) * cos(lat_2) * sin(d_lng /2) ** 2
        c = 2 * atan2(sqrt(a), sqrt(1 - a))
        distance = round(R * c * 100) * 10
        array.append({
            'uid' : item['uid'],
            'label' : item['label'],
            'distance' : distance,
            'bikes' : item['bikes'],
            'time' : item['time'],
            })
        closest_stations = closest_stations + array
    closest_stations_sorted = sorted(closest_stations, key=lambda x: x['distance'])
    return closest_stations_sorted


# zwrócenie odpowiedniej liczby stacji, zawsze conajmniej 3
def prepare_message(closest_stations_sorted, num_of_stations, max_distance):
    sort_closest_stations = []
    index = 0
    for station in closest_stations_sorted:
        if station['distance'] <= max_distance:
            sort_closest_stations.append(station)
            index =+ 1
            if index > 4:
                pass
    message = [x for x in sort_closest_stations[:5]]
    if message == []:
        message = [x for x in closest_stations_sorted[:3]]
    if (len(message) == 1) or (len(message) == 2):
        message = [x for x in closest_stations_sorted[:3]]
    return message


# główna pętla, jej wywołanie wywułuje wszystkie funkcje powyżej
def stations_from_coords(city, coords, num_of_stations=5, max_distance=1200):
    try:
        properties_of_stations = merge_data(city)
        closest_stations_sorted = get_closest_stops(coords, properties_of_stations)
        message = prepare_message(closest_stations_sorted, num_of_stations, max_distance)
    except:
        message = 'Błąd systemu'
    return message