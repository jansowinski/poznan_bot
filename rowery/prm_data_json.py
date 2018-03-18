import json
import requests
import math
import os.path

# domyślna nazwa słownika z właściwościami stacji PRM
dict_file = 'dictionary_properties_of_stations.json'

# otwiera plik .json zapisany w tym samym folderze (jeśli użyta opcja ściągania danych ze strony nie należy korzystać), należy podać nazwę pliku z rozszerzeniem
def get_data_from_file(name):
    page = open(name, 'r')
    content = page.read()
    page_content = json.loads(content)
    page.close()
    return page_content


# funkcja pobiera dane z strony internetowej Miasta Poznań
def get_data_from_internet():
    url = 'http://www.poznan.pl/mim/plan/map_service.html?mtype=pub_transport&co=stacje_rowerowe'
    page = requests.get(url)
    page_content = page.json()
    return page_content


# zwraca listę słowników z id stacji, czasem oraz ilością rowerów i wolnych zamków
def get_usage_of_stations(stations):
    usage_of_stations = []
    for element in stations:
        usage_of_stations.append({
            'id' : element['id'],
            'time' : element['properties']['updated'],
            'label' : element['properties']['label'],
            'bike_racks' : element['properties']['bike_racks'],
            'bikes' : element['properties']['bikes'],
            'free_racks' : element['properties']['free_racks']
        })
    return usage_of_stations


# zwraca słownik id stacji, nazwę, szerokość oraz długość geograficzną, liczbę zamków
def get_properties_of_station(page_content):
    properties_of_stations = []
    stations = page_content['features']
    for element in stations:
        properties_of_stations.append({
            'id' : element['id'],
            'label' : element['properties']['label'],
            'bike_racks' : element['properties']['bike_racks'],
            'latitude' : element['geometry']['coordinates'][1],
            'longitude' : element['geometry']['coordinates'][0]
        })
    return properties_of_stations


# zapisuje dane do pliku w tym samym folderze
def save_to_file(name, jsonData):
    with open(name, 'w') as outfile:
        json.dump(jsonData, outfile, sort_keys = True, indent = 4, ensure_ascii = True)


# tworzy nowy plik z właściwościami stacji i zapisuje je w pliku .json
def get_properties_of_stations_to_file():
    page_content = get_data_from_internet()
    stations = page_content['features']
    properties_of_stations = get_properties_of_station(page_content)
    save_to_file(dict_file, properties_of_stations)


# zwraca id najbliższych stacji PRM, coord: współrzędne do wyszkuania, stop_num: liczba zwróconych stacji
def get_closest_stop(coord, num_of_stations):
    differenece_array = []
    for item in properties_of_stations:
        array = []
        lat_difference = coord[0] - item['latitude']
        lng_difference = coord[1] - item['longitude']
        distance = math.sqrt((lat_difference * lat_difference) + (lng_difference * lng_difference))
        array.append(item['id'])
        array.append(distance)
        differenece_array.append(array)

    differenece_array = sorted(differenece_array, key=lambda station: station[1])
    differenece_array = [x[0] for x in differenece_array[:num_of_stations]]
    return differenece_array


#zwraca listę list najbliższych stacji:
# kolejnosć: Nazwa, ilość rowerów, ilość wolnych zamków, ilość wszystkich zamków
def get_closest_stations(coord, num_of_stations):
    # zwraca id najbliższych stacji
    closest_stations = get_closest_stop(coord, num_of_stations)

    # zwraca użycie wszystkich stacji
    page_content = get_data_from_internet()
    stations = page_content['features']
    usage_of_stations = get_usage_of_stations(stations)

    # ostateczne dane, tak wiem, nazwa debilna
    final_array = []
    #
    for close_stop in closest_stations:
        for item in usage_of_stations:
            if close_stop == item['id']:
                array = []
                array.append(item['label'])
                array.append(item['bikes'])
                array.append(item['free_racks'])
                array.append(item['bike_racks'])
                final_array.append(array)

    return final_array


###POCZĄTEK PORGRAMU###

# sprawdza czy istnieje słownik z właściwościami stacji na dysku, jak nie to go tworzy
if os.path.isfile(dict_file):
    pass
else:
    get_properties_of_stations_to_file()

# czyta słownik z właściwościami stacjami zapisany na dysku
properties_of_stations = get_data_from_file(dict_file)

# coordy dla których wybiera najbliższe stacje
# coord = [52.409925, 16.922754]

# pokazuje najbliższe stacje
# kolejnosć: Nazwa, ilość rowerów, ilość wolnych zamków, ilość wszystkich zamków

# ilość wolnych i wszystkich zamków powinna być przedstawiona np: 6/10
# pozwala to określić czy jest możliwosć oddania roweru prosto to zamka
# get_closest_stations(coord, 5)