#!/usr/bin/python
#-*- enconding=utf-8 -*-

import requests
import json
import paho.mqtt.client as mqtt
import paho.mqtt.publish as publish
import paho.mqtt.subscribe as subscribe
import sys
import configparser
#Read project key from config file(config.ini)
config=configparser.ConfigParser()
config.read('config.ini')
PROJECT_KEY=config['KEY']['PROJECT_KEY']
DEVICE_KEY=config['KEY']['DEVICE_KEY']
DEVICE_ID=config['ID']['DEVICE_ID']

my_headers = {'CK':DEVICE_KEY}
SENSOR_ID='led'
hostname="iot.cht.com.tw"
topic='/v1/device/'+DEVICE_ID+'/sensor/'+SENSOR_ID+'/rawdata'
print(topic)
auth={
        'username':DEVICE_KEY,
        'password':DEVICE_KEY
        }

def on_message(client, userdata, message):
	print("%s %s" % (message.topic,message.payload))
try:
	subscribe.callback(on_message,topics=topic,hostname=hostname,auth=auth)

except KeyboardInterrupt:
        print("\ninterrupt received, exiting...")

