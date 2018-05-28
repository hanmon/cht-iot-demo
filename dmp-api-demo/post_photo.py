import requests
import json
import sys
#Change value of my_headers to your project Key
DEVICE_KEY='YOUR_KEY'
DEVICE_ID=YOUR_ID
my_headers = {'CK':DEVICE_KEY}
uri="https://iot.cht.com.tw/iot/v1/device/"+str(DEVICE_ID)+"/snapshot"
if len(sys.argv)>1:
	img_file=sys.argv[1]
	meta_data={'id':'photo','value':[img_file]}
	files={'file':open(img_file,'rb'),'meta':json.dumps(meta_data)}
	r=requests.post(uri,headers=my_headers,files=files)
	print(r.text)
else:
    print("Insufficent argument.")
