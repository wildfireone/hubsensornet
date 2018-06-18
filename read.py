#!/usr/bin/python3
from influxdb import InfluxDBClient
from psutil import cpu_percent, virtual_memory
from time import sleep
from socket import gethostname
from re import search

# determine endpoint based on assumed net topology
if (gethostname() == "pihost"):
    end = "localhost"
elif (search(r'pitest\d', gethostname(), 0)):
    end = "pihost.local"
else:
    end = "pihost"

# create db client
db = InfluxDBClient(host=end, database="test")

while True:
    # create json message
    msg = [{
        'measurement': 'usage',
        'fields': {
            'host': gethostname(),
            'cpu': cpu_percent(),
            'mem': virtual_memory().percent
        }}]

    # write to db
    db.write_points(msg)
    sleep(5)
