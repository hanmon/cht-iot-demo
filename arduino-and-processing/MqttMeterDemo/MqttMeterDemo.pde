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
SensorData sensorData;
ArrayList sensorDataArray;

float svgHeight=140,svgWidth=100;
final String host = "iot.cht.com.tw";
final int port = 1883;
final String apiKey = "DKZ05PSWHBYF2KX929";  // 
//final String apiKey = "DKXWBU4X490GZB0AT7";  //Test Device KEY
//final String topic = "";
String deviceId = "5355373363"; //Device ID of power meter
//String deviceId = "5584414030";//Test Device ID
//String sensorId = "instantaneousVA";
String sensorId = "switch";
String topicString = "/v1/device/" + deviceId + "/sensor/+/rawdata";
String sensor_id[]={"instantaneousVA","lastGasp","event","current_date_and_time"
                    ,"LoadProfile","Midnight","Alt"};
//String sensor_id[]={"Humidity","switch","temperature"};                    

void setup() {
  //carShape=loadShape("liakad-car-front.svg");
  //bulbOn=loadShape("bulbOn.svg");
  //bulbOff=loadShape("bulbOff.svg");
  //PFont font=createFont("Noto Sans CJK",20);
  //textFont(font,20);
  //loadFont("/usr/share/fonts/NotoSansCJK-Regular/NotoSansCJK-Regular.ttc");
  powerImg=loadImage("power-thumb.png");
  sensorData=new SensorData();
  size(800, 600);
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
  image(powerImg,width/2,height/2,powerImg.width/4,powerImg.height/4);
  textAlign(CENTER);
  textSize(20);
  fill(#030303);
  //if(sensorData.sensorId.toString().equals("instantaneousVA")){
    text("DEVICE ID:"+sensorData.deviceId,width/2,height/2+powerImg.height/8+20);
    text("SENSOR ID:"+sensorData.sensorId,width/2,height/2+powerImg.height/8+40);
    text("VALUE:"+sensorData.value,width/2,height/2+powerImg.height/8+60);
  //}
  
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
        if(json.getString("id").equals("instantaneousVA")){
          sensorData.sensorId=new StringBuffer(json.getString("id"));
          sensorData.deviceId=new StringBuffer(json.getString("deviceId"));
          JSONArray jsonArray=json.getJSONArray("value");
          println(jsonArray.toString());
          sensorData.value=new StringBuffer(jsonArray.get(0).toString());
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
    for(String sid:sensor_id){
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
   SensorData(){
      sensorId=new StringBuffer("--");
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
}