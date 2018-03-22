import requests
import xml.etree.ElementTree as ET
import math
import time

# ściąga i parsuje dane xml 
def download_parse_data():
    url = 'https://nextbike.net/maps/nextbike-official.xml?city=192'
    xml_string = requests.get(url).text
    root  = ET.fromstring(xml_string)
    return root


# zwraca właściwości stracji (niezmienne)
def get_properties_of_stations(xml_file):
    properties_of_stations = []
    for item in xml_file.iter('place'):
        properties_of_stations.append({
            'uid' : item.attrib['uid'],
            'id' : item.attrib['number'],
            'label' : item.attrib['name'],
            'bike_racks' : item.attrib['bike_racks'],
            'lat' : item.attrib['lat'],
            'lng' : item.attrib['lng']
        })
    return properties_of_stations


# zwraca uid najbliższych stacji
def get_closest_stops(coords, properties_of_stations, num_of_stations):
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


# zwraca właściwości najbliższych stacji
def get_usage_of_stations(xml_file, closest_stations):
    usage_of_stations = []
    for item in xml_file.iter('place'):
        for stop in closest_stations:
            if stop == item.attrib['uid']:
                usage_of_stations.append({
                    'uid' : item.attrib['uid'],
                    'id' : item.attrib['number'],
                    'label' : item.attrib['name'],
                    'bikes' : item.attrib['bikes'],
                    'free_racks' : item.attrib['free_racks'],
                    'bike_racks' : item.attrib['bike_racks'],
                    'time' : time.strftime("%H:%M")
                })
    return usage_of_stations


# główna pętla, jej wywołanie wywułuje wszystkie funkcje powyżej
def stations_from_coords(coords, num_of_stations=5):
    xml_file = download_parse_data()
    properties_of_stations = get_properties_of_stations(xml_file)
    closest_stations = get_closest_stops(coords, properties_of_stations, num_of_stations)
    usage_of_stations = get_usage_of_stations(xml_file, closest_stations)

    return usage_of_stations