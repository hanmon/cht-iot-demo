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

PShape bulbOff,bulbOn;
Serial serialPort; // Create object from Serial class
float val=0,pval=0; // Data received from the serial port
boolean ledStatus=false;

float svgHeight=140,svgWidth=100;
final String host = "iot.cht.com.tw";
final int port = 1883;
final String apiKey = "";  // CHANGE TO YOUR PROJECT API KEY
String deviceId = "";
String sensorId = "LED";

void setup() {
  //carShape=loadShape("liakad-car-front.svg");
  bulbOn=loadShape("bulbOn.svg");
  bulbOff=loadShape("bulbOff.svg");
  size(440, 440);
  frameRate(30);
  strokeWeight(2);
  String arduinoPort = Serial.list()[2];
  serialPort = new Serial(this, arduinoPort, 9600);
  background(#033BFF);
  try{
  LedControlMqttTest();
  }
  catch (Exception e){
    e.printStackTrace();
  }
}

void draw(){
  
  background(#033BFF);
  shapeMode(CENTER);
  if(ledStatus==false)
  {
    shape(bulbOff,width/2,height/2,svgWidth,svgHeight);
    serialPort.write('L');
  }
  else {
    shape(bulbOn,width/2,height/2,svgWidth,svgHeight);
    serialPort.write('H');
  }
}


void LedControlMqttTest() throws Exception{
    MqttClientPersistence mcp = new MqttDefaultFilePersistence(System.getProperty("java.io.tmpdir")); // should not be null
    MqttClient client = new MqttClient("tcp://iot.cht.com.tw:1883", "noname", mcp);
    client.setCallback(new MqttCallback() {
      
      public void messageArrived(String topic, MqttMessage message) throws Exception {
        String m = new String(message.getPayload());
        
        System.out.println(m);
        
        if (m.contains("\"value\":[\"1\"]")) {
          System.out.println("Got one");
          ledStatus=true;
          
        } else {
          System.out.println("Got zero");
          ledStatus=false;

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
    
    client.subscribe("/v1/device/" + deviceId + "/sensor/" + sensorId + "/rawdata");  
}