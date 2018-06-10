/*For Demostrating MQTT operation. Led turned on or off by received command,
which is from MQTT broker in IoT Platform 
Author: Bruce Chiu
Date: August 20th,2016*/
const int ledPin=2;
byte serialCmd=0;
boolean ledState=LOW;
void setup() {
  // put your setup code here, to run once:
  pinMode(ledPin,OUTPUT);
  Serial.begin(9600);
}

void loop() {
  // put your main code here, to run repeatedly:
  if(Serial.available()>0){
    serialCmd=Serial.read();
    if(serialCmd=='H'){
        ledState=HIGH;
        Serial.println("Led turned on");
    }
    else if(serialCmd=='L'){
        ledState=LOW;
        Serial.println("Led turned off");
    }
    else{
      Serial.println("Unknown Command");
    }
    
  }
  digitalWrite(ledPin,ledState);
}
