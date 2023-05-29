#include "PressureTransducer.hpp"

PressureTransducer::PressureTransducer(uint8_t analogSignalPin)
    : analogSignalPin{analogSignalPin}
{
    //talvez desnecessário
    pinMode(analogSignalPin, INPUT);
}

float PressureTransducer::readBar() {
    int reading = analogRead(analogSignalPin);
    //10bar / 5V * reading
    return (10.0/1023.0) * reading;
}