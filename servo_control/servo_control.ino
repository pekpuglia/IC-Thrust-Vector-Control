#include "Servo.h"

Servo servo;

void setup()
{
    Serial.begin(9600);
    servo.attach(4);
    servo.write(90);
}

int serialASCIIInt() {
    String fromSerial = Serial.readStringUntil('\n');
    int ret = fromSerial.toInt();
    return ret;
}

int serialLittleEndianInt() {
    int ret;
    Serial.readBytesUntil('\n', (uint8_t*) &ret, sizeof(int));
    return ret;
}

void loop() {
    if (Serial.available() == 0) {
        return;
    }
    //espera resto da mensagem chegar
    delay(5);
    int command = serialLittleEndianInt();
    Serial.println(command);
    if (command < 0 || command > 180) {
        return;
    }
    servo.write(command);
}