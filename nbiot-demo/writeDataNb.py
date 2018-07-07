# coding=utf-8
import serial
import Adafruit_DHT

DEVICE_ID=''
DEVICE_KEY=''
sensor=Adafruit_DHT.DHT22
pin=24
ip_address=''
port=''
apn=''
humidity, temperature = Adafruit_DHT.read_retry(sensor, pin)
if humidity is not None and temperature is not None:
    print('Temp={0:0.1f}*  Humidity={1:0.1f}%'.format(temperature, humidity))
else:
    print('Failed to get reading. Try again!')
    sys.exit(1)


ser = serial.Serial(port='/dev/ttyUSB0',baudrate=115200,parity=serial.PARITY_NONE,stopbits=serial.STOPBITS_ONE,bytesize=serial.EIGHTBITS)  # open serial port
print(ser.name)         # check which port was really used
#ser.write('EGT_I\r'.encode('utf-8'))     # write a string
ser.write('EGT_0'+DEVICE_KEY+'\r\n'.encode())     # write a string
print(ser.readline())
ser.write('EGT_1'+DEVICE_ID+'\r\n'.encode())     # write a string
print(ser.readline())
ser.write('EGT_2'+str(temperature)+'\r\n'.encode())     # write a string
print(ser.readline())
ser.write('EGT_i'+ip_address+'\r\n'.encode())     # write a string
print(ser.readline())
ser.write('EGT_p'+port+'\r\n'.encode())     # write a string
print(ser.readline())
ser.write('EGT_N'+apn+'\r\n'.encode())     # write a string
print(ser.readline())
ser.write('EGT_I'+'\r\n'.encode())     # write a string
print(ser.readline())
#for line in ser.read():
#    print(ser.readline()) 

#ser.write('\r')
#ser.write('\n')
print('EGT_s\r\n'.encode())
while True:
    line = ser.readline() 
    print line

ser.close() 
