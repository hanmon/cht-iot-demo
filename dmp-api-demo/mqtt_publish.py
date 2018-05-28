#!/usr/bin/python
#-*- enconding=utf-8 -*-

import requests
import json
import paho.mqtt.client as mqtt
import paho.mqtt.publish as publish
import sys
#Change value of my_headers to your project Key
DEVICE_KEY='YOUR_KEY'
my_headers = {'CK':DEVICE_KEY}
DEVICE_ID=5601185176
SENSOR_ID="button"
host="iot.cht.com.tw"
uri="https://iot.cht.com.tw/iot/v1/device/"+str(DEVICE_ID)+"/sensor/"+SENSOR_ID+"/rawdata"
topic="/v1/device/5601185176/rawdata"
print(topic)
if len(sys.argv)>1:
	payload=json.dumps([{"id":SENSOR_ID,"value":[sys.argv[1]]}])

	print(payload)
	auth={
	'username':"DK0CY1HEHS0TGYRHT2",
	'password':"DK0CY1HEHS0TGYRHT2"
	}
	user,password="DK0CY1HEHS0TGYRHT2","DK0CY1HEHS0TGYRHT2"
	mqttc=mqtt.Client()
	mqttc.username_pw_set(user,password)
	result=mqttc.connect(host,port=1883,keepalive=60)
	print(result)
	result=mqttc.publish(topic,"%s"%payload)
	print(result)
else:
	print("Insufficient argement.")
