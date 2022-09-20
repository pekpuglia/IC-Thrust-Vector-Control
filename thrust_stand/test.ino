#include "LoadCell.hpp"

LoadCell cell(A0, A3, 10);

void setup() {
    Serial.begin(57600);
    delay(1000);
    cell.calibrateScale(1.0);
}


void loop() {
    static unsigned long lastTime = millis();

    if (millis() - lastTime > 5) {
        lastTime = millis();
        Serial.print("carga: ");
        Serial.println(cell.calibratedRead());
    }
}
