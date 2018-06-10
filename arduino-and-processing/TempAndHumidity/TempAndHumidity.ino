//TempAndHumidity, Sensing by Pin8
int DHpin = 8; 
byte dat[5]; 
byte read_data() { 
  byte data; 
  for(int i=0; i<8; i++) 
  { 
    if(digitalRead(DHpin) == LOW) 
    { 
      while(digitalRead(DHpin) == LOW); //等待50us；
      delayMicroseconds(30); //判斷高電位的持續時間，以判定資料是‘0’還是‘1’；
      if(digitalRead(DHpin) == HIGH) 
        data |= (1<<(7-i)); //高位在前，低位元在後；
      while(digitalRead(DHpin) == HIGH); //資料‘1’，等待下一位的接收； 
        } 
      } 
      return data; 
    } 
    
    void start_test() 
    { 
      digitalWrite(DHpin,LOW); //拉低匯流排，發開始信號； 
      delay(30); //延時要大於18ms，以便DHT11能檢測到開始信號；
      digitalWrite(DHpin,HIGH); 
      delayMicroseconds(40); //等待DHT11響應；
        pinMode(DHpin,INPUT); 
        while(digitalRead(DHpin) == HIGH); 
        delayMicroseconds(80); //DHT11發出響應，拉低匯流排80us； 
        if(digitalRead(DHpin) == LOW); 
        delayMicroseconds(80); //DHT11拉高匯流排80us後開始發送資料； 
        for(int i=0;i<4;i++) //接收溫濕度資料，校驗位元不考慮；
        dat[i] = read_data();
        pinMode(DHpin,OUTPUT); 
        digitalWrite(DHpin,HIGH); //發送完一次資料後釋放匯流排，等待主機的下一次開始信號； 
      } 
    void setup() 
  { 
    Serial.begin(9600); 
    pinMode(DHpin,OUTPUT); 
  } 
  void loop() 
  { 
     start_test(); 
     Serial.print('H');
     Serial.print(','); 
     Serial.print(dat[0], DEC); //顯示濕度的整數位元； 
     Serial.print(',');
     Serial.print(dat[2], DEC); //顯示溫度的整數位元；
     Serial.println(',');
     delay(700); 
   }

