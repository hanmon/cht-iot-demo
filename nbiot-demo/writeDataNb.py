# coding=utf-8
import serial
import Adafruit_DHT
import time

DEVICE_ID='5993646118'
DEVICE_KEY='DK133ZH2M79WXX2WU0'
SENSOR_NAME=Adafruit_DHT.DHT22
SENSOR_ID='temperature'
pin=24
ipa='61.216.74.128'
port='5683'
apn='internet.iot'
def getSensorValue():
    humidity, temperature = Adafruit_DHT.read_retry(SENSOR_NAME, pin)
    if humidity is not None and temperature is not None:
#    print('Temp={0:0.1f}*  Humidity={1:0.1f}%'.format(temperature, humidity))
        return humidity,temperature
    else:
        print('Failed to get reading. Try again!')
        sys.exit(1)

def storeSensorData(sensor_id,sensorData):
    ser.write('EGT_2'+str(sensor_id)+'\r\n'.encode())     # write a string
    print(ser.readline())
    ser.write('EGT_4'+'["'+str(sensorData)+'"]'+'\r\n'.encode())     # write a string
    print 'EGT_4'+'["'+str(sensorData)+'"]'+'\r\n'
    print(ser.readline())
    



ser = serial.Serial(port='/dev/ttyUSB0',baudrate=115200,parity=serial.PARITY_NONE,stopbits=serial.STOPBITS_ONE,bytesize=serial.EIGHTBITS,timeout=2)  # open serial port
def setBasicModuleParam(device_key,device_id,sensor_id,ipa,port,apn):
    print(ser.name)         # check which port was really used
    #ser.write('EGT_I\r'.encode('utf-8'))     # write a string
    ser.write('EGT_0'+DEVICE_KEY+'\r\n'.encode())     # write a string
    print('Set API KEY '+ser.readline())
    ser.write('EGT_1'+DEVICE_ID+'\r\n'.encode())     # write a string
    print('Set Device KEY '+ser.readline())
    ser.write('EGT_2'+str(sensor_id)+'\r\n'.encode())     # write a string
    print('Set Sensor ID='+sensor_id+' '+ser.readline())
    ser.write('EGT_i'+ipa+'\r\n'.encode())     # write a string
    print('Set IP address '+ser.readline())
    ser.write('EGT_p'+port+'\r\n'.encode())     # write a string
    print('Set port '+ser.readline())
    ser.write('EGT_N'+apn+'\r\n'.encode())     # write a string
    print('Set apn name '+ser.readline())
  #  print(ser.readline())
    lines=ser.readlines()
    for line in lines:
        print line
    ser.write('EGT_s\r\n'.encode())
    print('NB-IoT status:')
    lines=ser.readlines()
    for line in lines:
        print line
try:
    setBasicModuleParam(DEVICE_KEY,DEVICE_ID,SENSOR_ID,ipa,port,apn);
    while True:
      humidity,temperature=getSensorValue()
      print('Temp={0:0.1f}*  Humidity={1:0.1f}%'.format(temperature,humidity))
      storeSensorData('temperature',round(temperature,2))
      time.sleep(3)
      storeSensorData('humidity',round(humidity,2))
      time.sleep(3)
      #storeSensorData('humidity',humidity)
except KeyboardInterrupt: 
    print 'KeyboardInterrupt';
ser.close() 
