#define BUTTON_PIN D4
#define HIGH_PIN   D5
#define LOW_PIN   D6

void setup() {
  pinMode(BUTTON_PIN, INPUT_PULLDOWN);   // External pulldown resistor
  pinMode(HIGH_PIN, OUTPUT);
  Serial.begin(115200);

  digitalWrite(HIGH_PIN, HIGH); // Always 3.3V
  digitalWrite(LOW_PIN, LOW); // Always 0V
}

void loop() {
  bool pressed = digitalRead(BUTTON_PIN); // HIGH when pressed
  if (pressed) Serial.println("BTN PRESSED...");
}
