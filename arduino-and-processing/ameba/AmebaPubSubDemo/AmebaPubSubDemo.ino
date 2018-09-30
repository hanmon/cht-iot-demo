
/*
  CHT IoT Client example

  It connects to an CHT IoT server by MQTT:
  - publishes publishHBPayload to publishHBTopic
  - publishes publishRawPayload to publishRawTopic
  - subscribes to subscribeLedTopic to parse data for turn on or turn off LED (You may change definition of ledPin to other pin number you want)
*/
#define ARDUINOJSON_ENABLE_PROGMEM 0
#include <WiFi.h>
#include <PubSubClient.h>
//#include <math.h>
#include <ArduinoJson.h>


//define the pin to control led
#define ledPin 13

// Update these variables with values suitable for your network.
//char ssid[] = "BMW EE-809";     // your Wi-Fi SSID (name)
//char pass[] = "7218bmwee809";  // your Wi-Fi Encryption Key
char ssid[] = "boo";     // your Wi-Fi SSID (name)
char pass[] = "@a123456";  // your Wi-Fi Encryption Key
int status  = WL_IDLE_STATUS;    // the Wifi radio's status
int heartBeatTimer = 5000;      //heatbeat timer, unit:msec
int rawTimer = 10000;         //raw data timer, unit:msec
char mqttServer[]     = "iot.cht.com.tw";
const char* mqttClientId   = "amebaClient2";
const char* DEVICE_KEY     = "DK2RWEZT75170U2UYZ";   //your api key
char publishHBTopic[]   = "/v1/device/7802015565/heartbeat"; //device id here should be then same in your project
char publishHBPayload[] = "{\"pulse\":\"10000\"}";
char publishRawTopic[]   = "/v1/device/7802015565/rawdata"; //device id here should be then same in your project
char publishRawPayload[200];
char subscribeLedTopic[] = "/v1/device/7802015565/sensor/led/rawdata";  //sensor id here should be then same in your project
long previousHBTime = 0;          // previous HB previous time
long previousRawTime = 0;         // previous Raw previous time
int ledState = 0;                // led value(1:high,0:off)


WiFiClient wifiClient;
PubSubClient client(wifiClient);

//MQTT callback function
void callback(char* topic, byte* payload, unsigned int length) {
  StaticJsonBuffer<200> jsonBuffer;
  char* buffer = (char*)malloc(length);
  memcpy(buffer, payload, length);
  JsonObject& root = jsonBuffer.parseObject(buffer);
  // Test if parsing succeeds.
  if (!root.success()) {
    Serial.println("parseObject() failed");
    return;
  }
  const char* id=root["id"];
  const char* time=root["time"];
  const char* value=root["value"][0];

  Serial.println("Parsed JSON Object:");
  Serial.println(id);
  Serial.println(time);
  Serial.println(value);

  digitalWrite(ledPin,(*value=='1'?HIGH:LOW));
  free(buffer);
}


//Send heartbeat msg task
void hbTask() {
  if (millis() - previousHBTime > heartBeatTimer) {
    previousHBTime = millis();
    client.publish(publishHBTopic, publishHBPayload);
    Serial.println("Publish HB Topic...");
  }
}

//Send raw msg task
void rawTask() {
  StaticJsonBuffer<200> doc1; //allocated for JSON document
  StaticJsonBuffer<200> doc2; //allocated for JSON document
  JsonObject& root1 = doc1.createObject();
  JsonObject& root2 = doc2.createObject();
  String output1, output2;
  if (millis() - previousRawTime > rawTimer) {
    previousRawTime = millis();
    //float tmp = getTemp();
    float h = getHumidityValue();
    float t = getTemperatureValue();
    if (isnan(h) || isnan(t) ) {
      Serial.println("Failed to read from DHT sensor!");
      return;
    }
    else {
      Serial.print("Humidity:");
      Serial.println(String(int(h)));
      Serial.print("Temperature:");
      Serial.println(String(int(t)));
      root1["id"] = "humidity";
      JsonArray& value1 = root1.createNestedArray("value");
      value1.add(String(h));
      root2["id"] = "temperature";
      JsonArray& value2 = root2.createNestedArray("value");
      value2.add(String(t));
      String output1, output2;
      //      serializeJson(doc1, output1);
      //      serializeJson(doc2, output2);
      root1.printTo(output1);
      root2.printTo(output2);
      String mqttMessage = "[" + output1 + "," + output2 + "]";
      //Serial.print("mqttMessage:");
      //Serial.println(mqttMessage);
      mqttMessage.toCharArray(publishRawPayload, mqttMessage.length() + 1);
      Serial.print("publishRawPayload:");
      Serial.println(publishRawPayload);
      int result = client.publish(publishRawTopic, publishRawPayload);
      result == 1 ? Serial.println("MQTT publish succeeded") : Serial.println("MQTT publish failed");
      Serial.println("");
    }
  }
}



void reconnect() {
  // Loop until we're reconnected
  while (!client.connected()) {
    Serial.println("");
    Serial.println("Attempting MQTT connection...");
    // Attempt to connect
    if (client.connect(mqttClientId, DEVICE_KEY, DEVICE_KEY)) {
      Serial.println("connected");
      // ... and resubscribe
      client.subscribe(subscribeLedTopic);
      Serial.print("Subscribe LED topic is:");
      Serial.println(subscribeLedTopic);

      // Once connected, publish an announcement...
      client.publish(publishHBTopic, publishHBPayload);
      Serial.print("Public HB payload is:");
      Serial.println(publishHBPayload);

    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      // Wait 5 seconds before retrying
      delay(5000);
    }
  }
}

void setup()
{
  Serial.begin(9600);
  //initializing DHT Sensor
  initDHTSensor();

  while (status != WL_CONNECTED) {
    Serial.print("Attempting to connect to SSID: ");
    Serial.println(ssid);
    // Connect to WPA/WPA2 network. Change this line if using open or WEP network:
    status = WiFi.begin(ssid, pass);

    // wait 10 seconds for connection:
    delay(10000);
  }

  client.setServer(mqttServer, 1883);
  client.setCallback(callback);

  // Allow the hardware to sort itself out
  delay(1500);
  Serial.print("ARDUINOJSON_VERSION_MAJOR = ");
  Serial.println(ARDUINOJSON_VERSION_MAJOR);
  // initialize digital pin 13 as an output.
  pinMode(ledPin, OUTPUT);
}

void loop()
{
  if (!client.connected()) {
    reconnect();
  }
  client.loop();

  //run timer task
  //hbTask();
  rawTask();
}
