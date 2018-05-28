#!/usr/bin/python
#-*- enconding=utf-8 -*-

import requests
import json
import paho.mqtt.client as mqtt
import paho.mqtt.publish as publish
import paho.mqtt.subscribe as subscribe
import sys
#Change value of DEVICE_KEY,DEVICE_ID to yours
DEVICE_KEY='YOUR_KEY'
DEVICE_ID=YOUR_ID
hostname="iot.cht.com.tw"
port=1883
topic_base_uri="/v1/device/"+str(DEVICE_ID)+"/sensor/"
sensor_id=["button","humidity","temperature","pm1","pm2_5","pm10"]
topic_wildcard="/v1/device/"+str(DEVICE_ID)+"/sensor/#"
topic_list=[]
for sid in sensor_id:
	topic_list.append((topic_base_uri+str(sid)+"/rawdata",0))	
print("Subscribed to topics including:")
for topic in topic_list:
	print(topic)
auth={
        'username':DEVICE_KEY,
        'password':DEVICE_KEY
        }
def on_message(client,userdata,message):
	print("Received message '" + str(message.payload) + "' on topic '"
        + message.topic + "' with QoS " + str(message.qos))
def on_connect(client, userdata, flags, rc):
    print("Connection returned result: "+str(rc))

mqtt_client=mqtt.Client()
mqtt_client.message_callback_add("#",on_message)
mqtt_client.username_pw_set(username=auth['username'],password=auth['password'])
mqtt_client.on_connect = on_connect
try:
	connect_result=mqtt_client.connect(hostname,port,60)
	mqtt_client.subscribe(topic_list,0)
	mqtt_client.loop_forever()

except KeyboardInterrupt:
	print("\ninterrupt received, exiting...")
