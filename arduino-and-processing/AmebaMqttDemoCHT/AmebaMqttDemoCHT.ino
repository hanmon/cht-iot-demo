/*
  CHT IoT Client example

  It connects to an CHT IoT server by MQTT:
  - publishes publishHBPayload to publishHBTopic
  - publishes publishRawPayload to publishRawTopic
  - subscribes to subscribeLEDTopic to parse data for turn on or turn off LED (You may change definition of ledPin to other pin number you want)
*/

#include <WiFi.h>
#include <PubSubClient.h>
#include <math.h>
#include <ArduinoJson.h>
#include "DHT.h"
#define DHTPIN 2
// Uncomment whatever type you're using!
#define DHTTYPE DHT11   // DHT 11
//#define DHTTYPE DHT22   // DHT 22  (AM2302), AM2321
//#define DHTTYPE DHT21   // DHT 21 (AM2301)

//define the pin to control led
#define ledPin 13

// Update these variables with values suitable for your network.
char ssid[] = "your Wi-Fi SSID";     // your Wi-Fi SSID (name)
char pass[] = "your Wi-Fi Key";  // your Wi-Fi Encryption Key
int status  = WL_IDLE_STATUS;    // the Wifi radio's status
int heartBeatTimer = 5000;      //heatbeat timer, unit:msec
int rawTimer = 10000;         //raw data timer, unit:msec
char mqttServer[]     = "iot.cht.com.tw";
const char* mqttClientId   = "amebaClient";
const char* DEVICE_KEY     = "your_api_key";   //your api key
char publishHBTopic[]   = "/v1/device/your_device_id/heartbeat"; //device id here should be then same in your project
char publishHBPayload[] = "{\"pulse\":\"10000\"}";
char publishRawTopic[]   = "/v1/device/your_device_id/rawdata"; //device id here should be then same in your project
char publishRawPayload[200];
char subscribeLEDTopic[] = "/v1/device/your_device_id/sensor/LED1/csv";  //sensor id here should be then same in your project
long previousHBTime = 0;          // previous HB previous time
long previousRawTime = 0;         // previous Raw previous time
int ledState = 0;                // led value(1:high,0:off)


WiFiClient wifiClient;
PubSubClient client(wifiClient);
DHT dht(DHTPIN, DHTTYPE);// Initialize DHT sensor.

//MQTT callback function
void callback(char* topic, byte* payload, unsigned int length) {
  char *p = (char*)payload;
  char *str;
  int element_cnt = 0;

  Serial.print("MQTT Message arrived [");
  Serial.print(topic);
  Serial.print("] ");
  for (int i = 0; i < length; i++) {
    Serial.print((char)payload[i]);
  }
  Serial.println();

  //check LED topic or not
  if (strcmp(topic, subscribeLEDTopic) == 0) {
    while ((str = strtok_r(p, ",", &p)) != NULL) { // delimiter is the semicolon
      element_cnt++;

      //check LED command is 0 or 1
      if (element_cnt == 4) {
        if (str[0] == '0') {
          Serial.println("Turn off LED");
          digitalWrite(ledPin, LOW);    // turn the LED off by making the voltage LOW
        } else if (str[0] == '1') {
          Serial.println("Turn on LED");
          digitalWrite(ledPin, HIGH);   // turn the LED on (HIGH is the voltage level)
        }
      }
    }
  }


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
  StaticJsonDocument<200> doc1; //allocated for JSON document
  StaticJsonDocument<200> doc2; //allocated for JSON document
  JsonObject root1 = doc1.to<JsonObject>();
  JsonObject root2 = doc2.to<JsonObject>();
  if (millis() - previousRawTime > rawTimer) {
    previousRawTime = millis();
    //float tmp = getTemp();
    float h = dht.readHumidity();
    float t = dht.readTemperature();
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
      JsonArray value1 = root1.createNestedArray("value");
      value1.add(String(h));
      root2["id"] = "temperature";
      JsonArray value2 = root2.createNestedArray("value");
      value2.add(String(t));
      String output1, output2;
      serializeJson(doc1, output1);
      serializeJson(doc2, output2);
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
      client.subscribe(subscribeLEDTopic);
      Serial.print("Subscribe LED topic is:");
      Serial.println(subscribeLEDTopic);

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
  dht.begin(); //begin analyzing DHT signal

  Serial.print("DHT Sensor Type:");
  Serial.println(DHTTYPE);
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
  hbTask();
  rawTask();
}
