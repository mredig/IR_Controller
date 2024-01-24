#include <IRremote.hpp>

int guessingLEDPin = 3;

bool isLEDOn = 0;

const uint8_t onRawData[] = {
  180,
  80,
  10,
  10,
  10,
  10,
  10,
  10,
  10,
  10,
  10,
  10,
  10,
  10,
  10,
  10,
  10,
  10,
  10,
  30,
  10,
  30,
  10,
  30,
  10,
  30,
  10,
  30,
  10,
  30,
  10,
  30,
  10,
  30,
  10,
  30,
  10,
  10,
  10,
  10,
  10,
  10,
  10,
  10,
  10,
  10,
  10,
  10,
  10,
  10,
  10,
  10,
  10,
  30,
  10,
  30,
  10,
  30,
  10,
  30,
  10,
  30,
  10,
  30,
  10,
  30,
  10,
};

const uint8_t offRawData[] = {
  180,
  80,
  10,
  10,
  10,
  10,
  10,
  10,
  10,
  10,
  10,
  10,
  10,
  10,
  10,
  10,
  10,
  10,
  10,
  30,
  10,
  30,
  10,
  30,
  10,
  30,
  10,
  30,
  10,
  30,
  10,
  30,
  10,
  30,
  10,
  10,
  10,
  10,
  10,
  10,
  10,
  10,
  10,
  10,
  10,
  10,
  10,
  10,
  10,
  10,
  10,
  30,
  10,
  30,
  10,
  30,
  10,
  30,
  10,
  30,
  10,
  30,
  10,
  30,
  10,
  30,
  10,
};

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(guessingLEDPin, OUTPUT);

  IrSender.begin(guessingLEDPin);
  digitalWrite(LED_BUILTIN, LOW);
}

void loop() {
  int charAvailable = Serial.available();
  if (charAvailable > 0) {
    processInput(charAvailable);
  }
}

void processInput(int charCount) {
  String input = Serial.readString();

  if (input == "on") {
    sendSignal(onRawData);
    isLEDOn = 1;
    Serial.println("Turned on!");
  } else if (input == "off") {
    sendSignal(offRawData);
    isLEDOn = 0;
    Serial.println("Turned off!");
  } else {
    Serial.println("Unknown command.");
  }
  delay(10);
}

void sendSignal(uint8_t data[]) {
  int count = 3;
  for (int i = 0; i < count; i ++) {
    IrSender.sendRaw(data, 68, 38);
    delay(20);
  }
}
