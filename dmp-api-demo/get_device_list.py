import requests
#installing configparser pacakge for python2
import configparser
import json
#Read project key from config file(config.ini)
config=configparser.ConfigParser()
config.read('config.ini')
PROJECT_KEY=config['KEY']['PROJECT_KEY']
#print('Using PROJECT_KEY:'+PROJECT_KEY)        

#Send HTTP request with header 'CK'
headers = {'CK':PROJECT_KEY}
r=requests.get('https://iot.cht.com.tw/iot/v1/device',headers=headers)
print(r.text)
