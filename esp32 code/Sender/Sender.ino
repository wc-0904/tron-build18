#include <WiFi.h>
#include <esp_now.h>

// Define direction button pins
#define UP_BUTTON_PIN D2
#define DOWN_BUTTON_PIN D3
#define LEFT_BUTTON_PIN D4
#define RIGHT_BUTTON_PIN D5

// Define logical HIGH pin
#define HIGH_PIN D6

uint8_t receiverMAC[] = {0x3C, 0xDC, 0x75, 0x6C, 0x22, 0x10}; // Receiver's MAC

// Define direction struct
typedef struct {
  bool upPressed;
  bool downPressed;
  bool leftPressed;
  bool rightPressed;
} Message;

Message outgoingData;

void setup() {
  Serial.begin(115200);

  // Direction Pins are Input
  pinMode(UP_BUTTON_PIN, INPUT_PULLDOWN);
  pinMode(DOWN_BUTTON_PIN, INPUT_PULLDOWN);
  pinMode(LEFT_BUTTON_PIN, INPUT_PULLDOWN);
  pinMode(RIGHT_BUTTON_PIN, INPUT_PULLDOWN);
  
  // High pin set to digital HIGH
  pinMode(HIGH_PIN, OUTPUT);
  digitalWrite(HIGH_PIN, HIGH);

  // ESPNOW Protocol Setup
  WiFi.mode(WIFI_STA);

  if (esp_now_init() != ESP_OK) {
    Serial.println("ESP-NOW init failed");
    return;
  }

  esp_now_peer_info_t peer = {};
  memcpy(peer.peer_addr, receiverMAC, 6);
  peer.channel = 0;
  peer.encrypt = false;

  esp_now_add_peer(&peer);

  Serial.println("Sender ready");
}

void loop() {
  // Set direction bools based on button reads
  bool up_pressed = (digitalRead(UP_BUTTON_PIN) == HIGH);
  bool down_pressed = (digitalRead(DOWN_BUTTON_PIN) == HIGH);
  bool left_pressed = (digitalRead(LEFT_BUTTON_PIN) == HIGH);
  bool right_pressed = (digitalRead(RIGHT_BUTTON_PIN) == HIGH);

  // Assign struct data accordingly
  outgoingData.upPressed = up_pressed;
  outgoingData.downPressed = down_pressed;
  outgoingData.leftPressed = left_pressed;
  outgoingData.rightPressed = right_pressed;

  // Conditional prints
  if (up_pressed) Serial.println("Sending up...");
  if (down_pressed) Serial.println("Sending down...");
  if (left_pressed) Serial.println("Sending left....");
  if (right_pressed) Serial.println("Sending right...");

  esp_now_send(receiverMAC, (uint8_t *) &outgoingData, sizeof(outgoingData));

  delay(50); // debounce / reduce spam
}
