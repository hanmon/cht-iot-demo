import processing.serial.*;
import java.util.*;
import java.text.*;
import com.cht.iot.service.api.*;

PShape carShape;
Serial serialPort; // Create object from Serial class
int tempValue=0,humidityValue=0,cTempValue=0,cHumidityValue=0; // Data received from the serial port
float angle;
float easing=0.05;
//float targetRadius=0,radius=0;
float svgHeight=0,svgWidth=0,targetHeight=0,targetWidth=0;
final char HEADER='H';  //Arduino訊息標頭

final String host = "iot.cht.com.tw";
final int port = 80;
final int timeout = 5000;
final String apiKey = "";  // CHANGE TO YOUR PROJECT API KEY
final String deviceId = "";
final String sensorIdH = "Humidity";
final String sensorIdT = "Temp";
final OpenRESTfulClient client = new OpenRESTfulClient(host, port, apiKey);

void setup() {
  //carShape=loadShape("liakad-car-front.svg");
  carShape=loadShape("GT500.svg");
  size(440, 440);
  frameRate(30);
  strokeWeight(2);
  String arduinoPort = Serial.list()[2];
  serialPort = new Serial(this, arduinoPort, 9600);
  background(#8CFCF2);
}

void draw() {
  background(#8CFCF2);
  if ( serialPort.available() > 0) { // If data is available,
    String message=serialPort.readStringUntil('\r');
    //println(message);
    if(message!=null){
      String[] data=message.split(",");
      if(data[1]!= null && data[2]!=null){
                humidityValue=Integer.parseInt(data[1]);
                tempValue=Integer.parseInt(data[2]);
                println("溫度:"+tempValue+",濕度"+humidityValue); 
          }
    }
  }
  textSize(160);
  fill(#030CFF);
  text(humidityValue+" %",width/20,height*4/10);
  strokeWeight(20);
  stroke(255);
  line(0+width/10,height/2,width-width/10,height/2); 
  if(tempValue>28){
    fill(#FF0318);  //顯示紅色
  }
  else{
    fill(#030CFF);  //顯示藍色
  }
  text(tempValue+"°C",width/20,height*9/10);
   
   // read it and store it in val
  // Convert the values to set the radius
  //targetHeight = map(val, 0, 51, height,height/2);
  //targetWidth = map(val,0,51,width,width/2);
  //svgHeight+=(targetHeight-svgHeight)*easing;
  //svgWidth+=(targetWidth-svgWidth)*easing;
  //fill(102);
  //shapeMode(CENTER);
  //shape(carShape,width/2,height/2,svgWidth,svgHeight);
  //fill(255);
  //textSize(70);
  //text(int(val),width/2,height/2);
   if (tempValue!=cTempValue)  //若資料的值有改變
  {
    Thread t=new Thread(new Runnable() {
      public void run() {
        setDataPointCht(tempValue,deviceId,sensorIdT); //傳資料到CHT Platform
      }
    }
    );
    t.start();
  }
  if (humidityValue!=cHumidityValue)  //若資料的值有改變
  {
    Thread t=new Thread(new Runnable() {
      public void run() {
        setDataPointCht(humidityValue,deviceId,sensorIdH); //傳資料到CHT Platform
      }
    }
    );
    t.start();
  }
  cHumidityValue=humidityValue;  //將最新的濕度數值記錄在變數
  cTempValue=tempValue;  //將最新的溫度數值記錄在變數
}


//void setDataPoint(float val) {
//  String v1, v2;
//  Date dNow = new Date( );//宣告Date物件並實體化
//  SimpleDateFormat ft = new SimpleDateFormat ("yyyy-MM-dd'T'HH:mm:ss.SSS000Z"); //將欲上傳之時間資訊格式化(年月日時分秒)
//  System.out.println("Current Date: " + ft.format(dNow));//在console印出目前時間
//  try {
//    Datapoint dp1 = new Datapoint();//宣告Datapoint物件並實體化(Xively Library中的類別)
//    dp1.setAt(ft.format(dNow));//設定Datapoint的時間
//    v1=String.valueOf(val);
//    dp1.setValue(v1);//設定Datapoint的值
//    DatapointRequester requester = XivelyService.instance().datapoint(feedId, channelName);//宣告DatapointRequester物件並實體化
//    requester.create(dp1);//將datapoint資料透過HTTP POST傳到Xively
//  }
//  catch (Exception e) {
//    System.out.println("Sth. wrong!"+e.toString());
//  }
//}


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