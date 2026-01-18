#include <WiFi.h>
#include <esp_now.h>

// Define direction button pins
#define UP_PIN 4
#define DOWN_PIN 5
#define LEFT_PIN 6
#define RIGHT_PIN 7

uint8_t senderMAC[] = {0x48, 0xCA, 0x43, 0x2E, 0xDE, 0x80}; // Sender's MAC

// Define direction struct
typedef struct {
  bool upPressed;
  bool downPressed;
  bool leftPressed;
  bool rightPressed;
} Message;

Message incomingData;

// Callback signature for ESP32-S3
void onReceive(const esp_now_recv_info *info, const uint8_t *data, int len) {
  Serial.println("We receivin");
  memcpy(&incomingData, data, sizeof(incomingData));

  // Set direction levels accordingly then write to pins
  auto up_level = (incomingData.upPressed) ? HIGH: LOW;
  auto down_level = (incomingData.downPressed) ? HIGH: LOW;
  auto left_level = (incomingData.leftPressed) ? HIGH: LOW;
  auto right_level = (incomingData.rightPressed) ? HIGH: LOW;

  digitalWrite(UP_PIN, up_level);
  digitalWrite(DOWN_PIN, down_level);
  digitalWrite(LEFT_PIN, left_level);
  digitalWrite(RIGHT_PIN, right_level);
}

void setup() {
  Serial.begin(115200);
  pinMode(UP_PIN, OUTPUT);
  pinMode(DOWN_PIN, OUTPUT);
  pinMode(LEFT_PIN, OUTPUT);
  pinMode(RIGHT_PIN, OUTPUT);

  WiFi.mode(WIFI_STA);

  if (esp_now_init() != ESP_OK) {
    Serial.println("ESP-NOW init failed");
    return;
  }

  esp_now_register_recv_cb(onReceive);

  esp_now_peer_info_t peer = {};
  memcpy(peer.peer_addr, senderMAC, 6);
  peer.channel = 0;
  peer.encrypt = false;

  esp_now_add_peer(&peer);

  Serial.println("Receiver ready");
}

void loop() {}
