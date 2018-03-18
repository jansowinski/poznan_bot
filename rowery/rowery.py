import json
import requests
import math
import os.path
import redis

client = redis.StrictRedis(host='redis', port=6379, db=0)
client.lpush('rowery', '{"id":"1", "lat":52.469690, "lng":16.953519}')

while True:
    location_to_process = client.rpop('rowery')
    if location_to_process != None:
        print(json.loads(location_to_process.decode("utf-8")))