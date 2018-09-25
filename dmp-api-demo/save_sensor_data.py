import requests
#installing configparser pacakge for python2
import configparser
import json
import numpy as np
import time

#Read project key from config file(config.ini)
config=configparser.ConfigParser()
config.read('config.ini')
DEVICE_KEY=config['KEY']['DEVICE_KEY']
#print('Using PROJECT_KEY:'+PROJECT_KEY)        
DEVICE_ID=7802015565
apiURL='http://iot.cht.com.tw/iot/v1/device/'+str(DEVICE_ID)+'/rawdata'


#Send HTTP request with header 'CK'
headers = {'CK':DEVICE_KEY,'Content-Type':'application/json'}
#body=[{"id":"temperature","value":[np.random.randint(20,30)]}]
i=0
try:
    while 1:
        body=[{"id":"temperature","value":[np.random.randint(20,30)]}]
        r=requests.post(apiURL,headers=headers,data=json.dumps(body))
        print(r.text)
        print('The '+str(i)+' time post:'+json.dumps(body))
        i=i+1
        time.sleep(3)
except KeyboardInterrupt:
    print('End')

