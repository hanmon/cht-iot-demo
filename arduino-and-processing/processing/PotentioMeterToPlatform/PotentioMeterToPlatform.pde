import processing.serial.*;
import java.util.*;
import java.text.*;
import com.cht.iot.service.api.*;

PShape carShape;
Serial serialPort; // Create object from Serial class
int tempValue=0,sensor1Value=0,sensor2Value=0,cSensor1Value=0,cSensor2Value=0; // Data received from the serial port
//float targetRadius=0,radius=0;
float svgHeight=0,svgWidth=0,targetHeight=0,targetWidth=0;
final char HEADER='H';  //Arduino訊息標頭

final String host = "iot.cht.com.tw";
final int port = 80;
final int timeout = 5000;
final String apiKey = "";  // CHANGE TO YOUR PROJECT API KEY
final String deviceId = "";
//final String sensorIdH = "DHT11_Humidity";
//final String sensorIdT = "DHT11_Temp";
//final String sensorIdP=  "Photoresistor";
final String sensorIdV=  "PotentioMeter";
final OpenRESTfulClient client = new OpenRESTfulClient(host, port, apiKey);
int radius,prevTime,presentTime,randomNum;
float angle=0,targetAngle=0,easing=0.1,voltageValue;

void setup() {
  //carShape=loadShape("liakad-car-front.svg");
  //carShape=loadShape("GT500.svg");
  size(440, 440);
  frameRate(30);
  strokeWeight(2);
  String arduinoPort = Serial.list()[2];
  serialPort = new Serial(this, arduinoPort, 9600);
  background(#0C6C04);
  radius=width*3/8;
  targetAngle=PI;
  prevTime = millis();
}

void draw() {
  background(#0C6C04);
  if ( serialPort.available() > 0) { // If data is available,
    String message=serialPort.readStringUntil('\r');
    //println(message);
    if(message!=null){
      String[] data=message.split(",");
      if(data[1]!= null && data[2]!=null){
                sensor1Value=Integer.parseInt(data[1]);
                sensor2Value=Integer.parseInt(data[2]);
                println("數值1:"+sensor1Value+",數值2:"+sensor2Value); 
          }
    }
  }
  strokeWeight(20);
  stroke(255);
  randomNum=(int)random(0,1023);
  angle+=(targetAngle-angle)*easing;
  //line(0,height*2/3,width,height*2/3);
  line(width/2,height*2/3,width/2-radius*cos(angle),height*2/3-radius*sin(angle));
  presentTime=millis();
  voltageValue=Float.parseFloat(nf(map(sensor1Value,0,1023,0,5),1,1));
  textSize(50);
  
  text("Value:"+voltageValue+"V", width/4, height*2/3+80); 
  fill(255);
  
  if(presentTime-prevTime>2000){
      targetAngle=map(sensor1Value,0,1023,0,PI);
      prevTime=presentTime;
  }

   if (sensor1Value!=cSensor1Value)  //若資料的值有改變
  {
    Thread t=new Thread(new Runnable() {
      public void run() {
        setDataPointCht(voltageValue,deviceId,sensorIdV); //傳資料到CHT Platform
      }
    }
    );
    t.start();
  }

  cSensor1Value=sensor1Value;  //將最新數值記錄在變數
  cSensor2Value=sensor2Value;  //將最新數值記錄在變數
}

void setDataPointCht(float val, String deviceId, String sensorId) {

  //String value = "0";
  Date dNow = new Date( );//宣告Date物件並實體化
  SimpleDateFormat ft = new SimpleDateFormat ("yyyy-MM-dd'T'HH:mm:ss.SSS000Z"); //將欲上傳之時間資訊格式化(年月日時分秒)
  System.out.println("Current Date: " + ft.format(dNow));//在console印出目前時間
  try {
    client.saveRawdata(deviceId, sensorId, String.valueOf(val));
  }
  catch (Exception e) {
    System.out.println("Sth. wrong!"+e.toString());
  }
}