#ifndef SAFE_PINS_HPP
#define SAFE_PINS_HPP

#include "Arduino.h"

#ifdef ARDUINO_AVR_MEGA2560
enum MegaPins : uint8_t {
    D2 = 2,D3,D4,D5,D6,
    D7,D8,D9,D10,D11,
    D12,D13,D14,D15,D16,
    D17,D18,D19,D20,D21,
    D22,D23,D24,D25,D26,
    D27,D28,D29,D30,D31,
    D32,D33,D34,D35,D36,
    D37,D38,D39,D40,D41,
    D42,D43,D44,D45,D46,
    D47,D48,D49,D50,D51,
    D52, D53
};
#endif

//idealmente deveria ter um template com um enum mas tudo bem :/
class AbstractSafePin
{
protected:
    const uint8_t pin;
public:
    AbstractSafePin(uint8_t pin);
    operator uint8_t();
};

class OutPin : public AbstractSafePin
{
public:
    OutPin(uint8_t pin);

    void digitalWrite(bool val);

    void analogWrite(uint8_t val);
};

class InPin : public AbstractSafePin
{
public:
    InPin(uint8_t pin);

    const bool digitalRead();
};
//todo: analog pins

#endif