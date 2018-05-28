import requests
import json
#Change value of my_headers to your project Key
DEVICE_KEY='YOUR KEY'
my_headers = {'CK':DEVICE_KEY}
r=requests.get('https://iot.cht.com.tw/iot/v1/device/5617381522/sensor/temperature/rawdata',headers=my_headers)
print(r.text)
j=json.loads(r.text)
print j['value'][0]
