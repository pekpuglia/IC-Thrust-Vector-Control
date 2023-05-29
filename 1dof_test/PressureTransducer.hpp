#ifndef PRESSURE_TRANSDUCER_HPP
#define PRESSURE_TRANSDUCER_HPP

#include "Arduino.h"

class PressureTransducer
{
private:
    const uint8_t analogSignalPin;
public:
    PressureTransducer(uint8_t analogSignalPin);
    float readBar();
};

#endif