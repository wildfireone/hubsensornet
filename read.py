#!/usr/bin/python
from influxdb import InfluxDBClient
from psutil import cpu_percent, virtual_memory
from time import sleep
from socket import gethostname
from re import search

p, s = None, None
end, dbname = "pihost", "test"

# determine whether we should import adafruit lib
if (search(r'pitest\d', gethostname(), 0)):
    from Adafruit_DHT import DHT11, read_retry
    s = DHT11
    p = 4


def temp():
    with open('/sys/class/thermal/thermal_zone0/temp') as f:
        return int(f.read()[:2])

def log(stat):
    with open('/tmp/read.py.log', 'w') as f:
        print >> f, stat

log("searching for database")
db = None
while db is None:
    # create db client
    db = InfluxDBClient(host=end, database=dbname)
    try:
        # if there is no db running on endpoint this will error
        db.get_list_database()
    except KeyboardInterrupt:
        exit
    except Exception as e:
        db = None
        sleep(60)

log("database found sending data")
while db is not None:
    h, t = None, None
    if s is not None:
        h, t = read_retry(s, p)

    # if the h, t objects exists
    if h is not None and t is not None:
        # create a message containing telemetry
        msg1 = [{
            'measurement': 'atmos',
            'tags': {
                "host": gethostname()
            },
            'fields': {
                'cpu_usage': float("%.2f" % cpu_percent()),
                'mem_usage': float("%.2f" % virtual_memory().percent),
                'cpu_temp': temp(),
                'temp': float("%.2f" % t),
                'humi': float("%.2f" % h)
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
            'cpu_usage': float("%.2f" % cpu_percent()),
            'mem_usage': float("%.2f" % virtual_memory().percent),
            'cpu_temp': temp()
        }}]

    # write to db
    db.write_points(msg)
    sleep(20)
