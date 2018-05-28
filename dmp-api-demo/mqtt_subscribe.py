#!/usr/bin/python
#-*- enconding=utf-8 -*-

import requests
import json
import paho.mqtt.client as mqtt
import paho.mqtt.publish as publish
import paho.mqtt.subscribe as subscribe
import sys
#Change value of my_headers to your project Key
DEVICE_KEY='YOUR_KEY'
DEVICE_ID=YOUR_ID
my_headers = {'CK':DEVICE_KEY}
SENSOR_ID="button"
hostname="iot.cht.com.tw"
topic="/v1/device/5601185176/sensor/button/rawdata"
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

