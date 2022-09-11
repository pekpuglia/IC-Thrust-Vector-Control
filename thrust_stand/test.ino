#include "Thermocouple.hpp"


Thermocouple test(8, 9, 10);

void setup() {
    Serial.begin(9600);
}


void loop() {
    static unsigned long lastTime = millis();

    if (millis() - lastTime > 250) {
        lastTime = millis();
        Serial.print("temperatura: ");
        Serial.println(test.readCelsius());
    }
}