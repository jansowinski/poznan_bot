import redis
import json
import prm

client = redis.StrictRedis(host='redis', port=6379, db=0)

while True:
    location_to_process = client.rpop('rowery')
    if location_to_process != None:
        message = json.loads(location_to_process.decode("utf-8"))
        data = prm.stations_from_coords([message['lat'], message['lng']], 5)

        response = '🚲 *Najbliższe stacje od Ciebie o* ' + str(data[0]['time']) +'*: *  \n\n'
        cond = ['2', '3', '4']

        for item in data:
            if item['bikes'] == '1':
                grammar_message = ' rower'
            elif item['bikes'] in cond:
                grammar_message = ' rowery'
            else:
                grammar_message = ' rowerów'

            response = str(response) + str(item['label']) + ' : ' + str(item['bikes']) + grammar_message + '\n'

        client.set(message['id'], response)
