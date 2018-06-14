import processing.serial.*;
import java.util.*;
import java.text.*;
import java.io.FileWriter;
import com.cht.iot.service.api.*;
import com.cht.iot.persistence.entity.data.Rawdata;

import org.eclipse.paho.client.mqttv3.IMqttDeliveryToken;
import org.eclipse.paho.client.mqttv3.MqttCallback;
import org.eclipse.paho.client.mqttv3.MqttClient;
import org.eclipse.paho.client.mqttv3.MqttClientPersistence;
import org.eclipse.paho.client.mqttv3.MqttConnectOptions;
import org.eclipse.paho.client.mqttv3.MqttMessage;
import org.eclipse.paho.client.mqttv3.persist.MqttDefaultFilePersistence;

PShape bulbOff,bulbOn,carShape;
PImage powerImg;
Serial serialPort; // Create object from Serial class
float val=0,pval=0; // Data received from the serial port
boolean ledStatus=false;
//SensorData sensorData;
//ArrayList sensorDataArray;
ArrayList<SensorData> sensors;

float svgHeight=140,svgWidth=100;
final String host = "iot.cht.com.tw";
final int port = 1883;
final String apiKey = "";  //Fill your api key here
//final String apiKey = "";  //Test Device KEY
//final String topic = "";
String deviceId = ""; //Device ID 
String topicString = "/v1/device/" + deviceId + "/sensor/+/rawdata";
//String sensorId[]={"instantaneous_kva","lastGasp","event","current_date_and_time",
//                    "instantaneous_kw","LoadProfile","Midnight","Alt","tpcDelTotalWh"};
String sensorId[]={"instantaneous_kva","instantaneous_kw","tpcDelTotalWh","current_date_and_time"};

//current_date_and_time: 電表時間, instantaneous_kva:瞬時功率,instantaneous_kw: 瞬時需量,tpcDelTotalWh:總瓦時
//String sensorId[]={"Humidity","switch","temperature"};                    

void setup() {
  //carShape=loadShape("liakad-car-front.svg");
  //bulbOn=loadShape("bulbOn.svg");
  //bulbOff=loadShape("bulbOff.svg");
  //PFont font=createFont("Noto Sans CJK",20);
  //textFont(font,20);
  //loadFont("/usr/share/fonts/NotoSansCJK-Regular/NotoSansCJK-Regular.ttc");
  powerImg=loadImage("power-thumb.png");
  sensors=new ArrayList<SensorData>();
  for(String str:sensorId){
    sensors.add(new SensorData(str));
    println(str+" added");
  }
  size(1024, 768);
  frameRate(30);
  strokeWeight(2);
  //String arduinoPort = Serial.list()[2];
  //serialPort = new Serial(this, arduinoPort, 9600);
  background(#FFFFFF);
  try{
  LedControlMqttTest();
  }
  catch (Exception e){
    e.printStackTrace();
  }
}

void draw(){
  
  background(#FFFFFF);
  imageMode(CENTER);
  //image(powerImg,width/2,height/2,powerImg.width/4,powerImg.height/4);
  textAlign(CENTER);
  textSize(15);
  fill(#030303);
  for(int i=0;i<sensors.size();i++){
    SensorData s=sensors.get(i);
    if(i<5)
      s.render(powerImg.width/5,powerImg.height/5,(i%3+1)*width/4,height/5,powerImg);
    else
      s.render(powerImg.width/5,powerImg.height/5,(i%3+1)*width/4,height*3/5,powerImg);
  }

}


void LedControlMqttTest() throws Exception{
    MqttClientPersistence mcp = new MqttDefaultFilePersistence(System.getProperty("java.io.tmpdir")); // should not be null
    MqttClient client = new MqttClient("tcp://iot.cht.com.tw:1883", MqttClient.generateClientId(), mcp);
    println(MqttClient.generateClientId());
    client.setCallback(new MqttCallback() {
      
      public void messageArrived(String topic, MqttMessage message) throws Exception {
        String m = new String(message.getPayload());
        System.out.println(m);
        JSONObject json=parseJSONObject(m); 
        for(int i=0;i<sensors.size();i++){
          SensorData s=sensors.get(i);
          print(json.getString("id"));
          println(" vs."+ s.sensorId);
          if(json.getString("id").equals(s.sensorId.toString())){
            println("matched");
            //s.deviceId=
            //sensorData.sensorId=new StringBuffer(json.getString("id"));
            s.deviceId=new StringBuffer(json.getString("deviceId"));
            JSONArray jsonArray=json.getJSONArray("value");
            //println(jsonArray.toString());
            s.value=new StringBuffer(jsonArray.get(0).toString());
            sensors.set(i,s);
          }
          
        }
      
        
        
      }
      
      public void deliveryComplete(IMqttDeliveryToken token) {
      }
      
      public void connectionLost(Throwable cause) {
      }
    });
    MqttConnectOptions opts = new MqttConnectOptions();
    opts.setUserName(apiKey);
    opts.setPassword(apiKey.toCharArray());
    opts.setConnectionTimeout(5);
    opts.setKeepAliveInterval(60);    
    opts.setCleanSession(true);
    
    client.connect(opts);
    
    //client.subscribe("/v1/device/" + deviceId + "/sensor/" + sensorId + "/rawdata");
    ArrayList<String> topic_array=new ArrayList();
    for(String sid:sensorId){
        topic_array.add("/v1/device/" +deviceId + "/sensor/"+ sid + "/rawdata");
        
    }
    String[] topic_str_array=topic_array.toArray(new String[0]);
    println(topic_str_array);
    client.subscribe(topic_str_array);  
    //client.subscribe(topicString);  
    
}

class SensorData{
   StringBuffer sensorId;
   StringBuffer deviceId;
   StringBuffer time;
   StringBuffer value;
   SensorData(String sid){
      sensorId=new StringBuffer(sid);
      deviceId=new StringBuffer("--");
      time=new StringBuffer("--");
      value=new StringBuffer("--");
   }
   SensorData setSensorId(String sid){
     sensorId.replace(0,sensorId.length()-1,sid);
     return this;
   }
   SensorData setdeviceId(String did){
     sensorId.replace(0,deviceId.length()-1,did);
     return this;
   }
   SensorData setTime(String t){
     sensorId.replace(0,time.length()-1,t);
     return this;
   }
   SensorData setValue(String v){
     sensorId.replace(0,value.length()-1,v);
     return this;
   }
   
   void render(int sizeX,int sizeY,int posX,int posY,PImage img){

    image(img,posX,posY,sizeX,sizeY);
    text("DEVICE ID:"+deviceId,posX,posY+sizeY/2+sizeY/5);
    text("SENSOR ID:"+sensorId,posX,posY+sizeY/2+sizeY*2/5);
    text("VALUE:"+value,posX,posY+sizeY/2+sizeY*3/5);
   }
}

//class Sensor
//{
//    Sensor(){
      
//    }
  
//}
