//透過A0讀入光敏電阻的分壓，並透過串列埠輸出其數值
const int sensorPin = 0;
int value = 0;
void setup()
{
  Serial.begin(9600);
}
void start_test() {
  value = analogRead(sensorPin);
}

void loop()
{
  start_test();
  Serial.print('H');
  Serial.print(',');
  Serial.print(value); //顯示濕度的整數位元；
  Serial.print(',');
  Serial.print(0); //顯示溫度的整數位元；
  Serial.println(',');
  delay(700);
}

