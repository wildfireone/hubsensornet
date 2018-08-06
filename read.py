#!/usr/bin/python3
from influxdb import InfluxDBClient
from psutil import cpu_percent, virtual_memory
from time import sleep
from socket import gethostname
from re import search

p, s = None, None

# determine endpoint based on assumed net topology
if (gethostname() == "pihost"):
    end = "localhost"
elif (search(r'pitest\d', gethostname(), 0)):
    end = "pihost.local"
    from Adafruit_DHT import DHT11, read_retry
    s = DHT11
    p = 4
else:
    end = "pihost"


def temp():
    with open('/sys/class/thermal/thermal_zone0/temp') as f:
        r = f.read()[:2]
    return r


db = None
while db is None:
    # create db client
    db = InfluxDBClient(host=end, database="test")
    try:
        # if there is no db running on endpoint this will error
        db.get_list_database()
    except KeyboardInterrupt:
        exit
    except Exception as e:
        db = None
        sleep(60)

print("database found sending data")
while db is not None:
    h, t = None, None
    if s is not None:
        h, t = read_retry(s, p)

    if h is not None and t is not None:
        # print('temp={0:0.1f}*C humid={1:0.1f}%'.format(t, h))
        msg1 = [{
            'measurement': 'atmos',
            'tags': {
                "host": gethostname()
            },
            'fields': {
                'cpu_usage': cpu_percent(),
                'mem_usage': virtual_memory().percent,
                'cpu_temp': temp(),
                'temp': t,
                'humi': h
            }
        }]
        db.write_points(msg1)
    # create json message
    msg = [{
        'measurement': 'usage',
        'tags': {
            "host": gethostname()
        },
        'fields': {
            'cpu_usage': cpu_percent(),
            'mem_usage': virtual_memory().percent,
            'cpu_temp': temp()
        }}]

    # write to db
    db.write_points(msg)
    sleep(5)
