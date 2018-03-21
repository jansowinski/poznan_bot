import requests
import xml.etree.ElementTree as ET
import json
import os
import math
import time

file_temp_name = 'temp/prm_data_temp.xml'
file_name = 'temp/prm_data.xml'
file_properties_of_stations = 'temp/prm_properties_of_stations.json'


# pobiera dane z strony internetowej NextBike dla Poznania i zapisuje do pliku
def download_data():
    url = 'https://nextbike.net/maps/nextbike-official.xml?city=192'
    page = requests.get(url).text
    save_to_file(file_temp_name, page)

# zwraca dane z pliku .json
def get_json_data_from_file(file_name):
    page = open(file_name, 'r')
    content = page.read()
    feedback = json.loads(content)
    page.close()
    return feedback

# otwiera i zwraca zawartość pliku
def open_file(name):
    file = open(name, 'r', encoding='utf8')
    feedback = file.read()
    file.close()
    return feedback

# zapisuje dane do pliku - należy podać nazwę z roszerzeniem oraz dane
def save_to_file(name, data):
    file = open(name, 'w', encoding='utf8')
    file.write(str(data))
    file.close()

# parsuje plik do xml-a i zwraca zawartość
def parse_xml(file_name):
    tree  = ET.parse(file_name)
    root = tree.getroot()
    return root

# zmienia zewnętrzne cudzysłowy w apostrofy dla niektórych atrybutów:
# potrzebne do poprawnego parsowania
def change_characters():
    content = open_file(file_temp_name).split()
    page = ''
    for word in content:
        if 'show_bike_types' in word:
            continue
        if 'bounds' in word:
            word = word[:8].replace('"', '\'') + word[8:]
            word = word[:-1]
            word = word + "'"
        if 'bike_types' in word:
            word = word[:12].replace('"', '\'') + word[12:]
            word = word[:-1]
            word = word + "'"
        page = page + ' ' + word
    #wywalenie nagłówka z wersją xml i kodowanie - wywala parser
    page = page[40:]
    save_to_file(file_name, page)


# zwraca listę słowników z uid, id, oraz ilością rowerów i wolnych zamków
def get_usage_of_stations(file_name):
    # parsuje plik xml do zmiennej
    root = parse_xml(file_name)
    usage_of_stations = []
    for item in root.iter('place'):
        usage_of_stations.append({
            'uid' : item.attrib['uid'],
            'id' : item.attrib['number'],
            'label' : item.attrib['name'],
            'bike_racks' : item.attrib['bike_racks'],
            'bikes' : item.attrib['bikes'],
            'free_racks' : item.attrib['free_racks']
        })
    return usage_of_stations


# tworzy plik json który zawiera podstawowe dane na temat stacji
def get_properties_of_stations_to_file(file_name):
    download_data()
    change_characters()
    # parsuje plik xml do zmiennej
    root = parse_xml(file_name)

    properties_of_stations = []
    for item in root.iter('place'):
        properties_of_stations.append({
            'uid' : item.attrib['uid'],
            'id' : item.attrib['number'],
            'label' : item.attrib['name'],
            'bike_racks' : item.attrib['bike_racks'],
            'lat' : item.attrib['lat'],
            'lng' : item.attrib['lng']
        })
    with open(file_properties_of_stations, 'w') as file:
        json.dump(properties_of_stations, file, sort_keys = True, indent = 4, ensure_ascii = True)


def get_closest_stops(coords, num_of_stations):
    # czyta słownik z właściwościami stacjami zapisany na dysku
    properties_of_stations = get_json_data_from_file(file_properties_of_stations)

    closest_stations = []
    for item in properties_of_stations:
        array = []
        lat_diff = coords[0] - float(item['lat'])
        lng_diff = coords[1] - float(item['lng'])
        distance = math.sqrt((lat_diff * lat_diff) + (lng_diff * lng_diff))
        array.append(item['uid'])
        array.append(distance)
        closest_stations.append(array)

    closest_stations = sorted(closest_stations, key=lambda station: station[1])
    closest_stations = [x[0] for x in closest_stations[:num_of_stations]]
    return closest_stations


def get_closest_stations_properties(closest_stations):
    # zwraca się o aktualne wykorzystanie stacji
    usage_of_stations = get_usage_of_stations(file_name)

    final_array = []
    for stop in closest_stations:
        for item in usage_of_stations:
            if stop == item['uid']:
                array = []
                array.append(item['label'])
                array.append(item['bikes'])
                array.append(item['free_racks'])
                array.append(item['bike_racks'])
                array.append(time.strftime("%H:%M"))
                final_array.append(array)
    return final_array

def stations_from_coords(coords, num_of_stations=5):
    if os.path.isfile(file_properties_of_stations):
        pass
    else:
        get_properties_of_stations_to_file(file_name)

    download_data()
    change_characters()

    closest_stations = get_closest_stops(coords, num_of_stations)
    closest_stations_properties = get_closest_stations_properties(closest_stations)
    return closest_stations_properties

