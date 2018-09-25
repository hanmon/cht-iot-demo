#!/usr/bin/python
#-*- enconding=utf-8 -*-

import requests
import json
import paho.mqtt.client as mqtt
import paho.mqtt.publish as publish
import sys
import configparser
#Change value of my_headers to your project Key
config=configparser.ConfigParser()
config.read('config.ini')
PROJECT_KEY=config['KEY']['PROJECT_KEY']
DEVICE_KEY=config['KEY']['DEVICE_KEY']
my_headers = {'CK':DEVICE_KEY}
DEVICE_ID=config['ID']['DEVICE_ID']
SENSOR_ID='temperature'
host="iot.cht.com.tw"
uri="https://iot.cht.com.tw/iot/v1/device/"+str(DEVICE_ID)+"/sensor/"+SENSOR_ID+"/rawdata"
topic="/v1/device/"+DEVICE_ID+"/rawdata"
print(topic)
if len(sys.argv)>1:
	payload=json.dumps([{"id":SENSOR_ID,"value":[sys.argv[1]]}])

	print(payload)
	#auth={
	#'username':str(PROJECT_KEY)
	#'password':str(PROJECT_KEY)
	#}
	user,password=str(DEVICE_KEY),str(DEVICE_KEY)
	mqttc=mqtt.Client()
	mqttc.username_pw_set(user,password)
	result=mqttc.connect(host,port=1883,keepalive=60)
	print(result)
	result=mqttc.publish(topic,"%s"%payload)
	print(result)
else:
	print("Insufficient argement.")
