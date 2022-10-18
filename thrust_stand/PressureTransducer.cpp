#include "PressureTransducer.hpp"

PressureTransducer::PressureTransducer(uint8_t analogSignalPin)
    : analogSignalPin{analogSignalPin}
{
    pinMode(analogSignalPin, INPUT);
}

double PressureTransducer::readBar() {
    int reading = analogRead(analogSignalPin);
    Serial.println(reading);
    //10bar / 5V * reading
    return (10.0/1023.0) * reading;
}