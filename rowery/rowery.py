import redis
import json
import prm_data_json as prm

client = redis.StrictRedis(host='redis', port=6379, db=0)

while True:
    location_to_process = client.rpop('rowery')
    if location_to_process != None:
        message = json.loads(location_to_process.decode("utf-8"))
        data = prm.get_closest_stations([message['lat'], message['lng']], 5)
        response = '*Najbliższe stacje od Ciebie:*  \n\n'
        for item in data:
            response = str(response) + str(item[0]) + ' - liczba dostępncyh rowerów: ' + str(item[1]) + '\n'
        client.set(message['id'], response)