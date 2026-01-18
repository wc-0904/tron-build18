// Complete Instructions to Get and Change ESP MAC Address: https://RandomNerdTutorials.com/get-change-esp32-esp8266-mac-address-arduino/

#include "WiFi.h"

void setup(){
  Serial.begin(115200);
  WiFi.mode(WIFI_MODE_STA);
  Serial.println(WiFi.macAddress());
}
 
void loop() {
  Serial.println(WiFi.macAddress());
  delay(1000);
}

// void setup() {
//   Serial.begin(115200);
//   delay(3000);
//   Serial.println("ESP32-S3 OK");
// }

// void loop() {
//   Serial.println("Running...");
//   delay(1000);
// }
