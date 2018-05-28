import requests
#Change value of my_headers to your project Key
DEVICE_KEY='YOUR_KEY'
my_headers = {'CK':DEVICE_KEY}
r=requests.get('https://iot.cht.com.tw/iot/v1/device',headers=my_headers)
print(r.text)
