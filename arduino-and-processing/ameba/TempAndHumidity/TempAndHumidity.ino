//TempAndHumidity, Sensing by Pin8
#include "DHT.h"
#define DHTPIN 2
#define DHTTYPE DHT11   // DHT 11
//int DHpin = 8;
DHT dht(DHTPIN, DHTTYPE);// Initialize DHT sensor.
void setup()
{
  Serial.begin(9600);
  dht.begin();
  Serial.println("Temp and Humidity Test");

}
void loop()
{
  float h = dht.readHumidity();
  float t = dht.readTemperature();
  if (isnan(h) || isnan(t) ) {
    Serial.println("Failed to read from DHT sensor!");
    return;
  }
  else {
    Serial.print('H');
    Serial.print(',');
    Serial.print(int(h)); //顯示濕度的整數位元；
    Serial.print(',');
    Serial.print(int(t)); //顯示溫度的整數位元；
    Serial.println(',');

  }
  delay(3000);
}

