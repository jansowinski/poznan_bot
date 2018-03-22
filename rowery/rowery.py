import redis
import json
import prm

client = redis.StrictRedis(host='redis', port=6379, db=0)

while True:
    location_to_process = client.rpop('rowery')
    if location_to_process != None:
        message = json.loads(location_to_process.decode("utf-8"))
        data = prm.stations_from_coords([message['lat'], message['lng']], 5)

        response = '🚲 *Najbliższe stacje od Ciebie o* ' + data[0][-1] +'*: *  \n\n'
        cond = ['2', '3', '4']

        for item in data:
            if item[1] == '1':
                grammar_message = ' rower'
            elif item[1] in cond:
                grammar_message = ' rowery'
            else:
                grammar_message = ' rowerów'

            response = str(response) + str(item[2]) + ' : ' + str(item[3]) + grammar_message + '\n'

        client.set(message['id'], response)
