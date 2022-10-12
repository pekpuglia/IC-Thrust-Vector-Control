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

//idealmente deveria estar especificado que é enum, mas tudo bem :/
template<typename PinEnum>
class AbstractSafePin
{
private:
    const PinEnum pin;
public:
    AbstractSafePin(PinEnum pin) : pin{pin} {};
    operator uint8_t() {
        return static_cast<uint8_t>(pin);
    };
};

template<typename PinEnum>
class OutPin : public AbstractSafePin<PinEnum>
{
public:
    OutPin<PinEnum>(PinEnum pin) : AbstractSafePin<PinEnum>(pin) {
        pinMode(pin, OUTPUT);
    };

    void digitalWrite(bool val) {
        //escopo global
        ::digitalWrite(this->pin, val);
    };

    void analogWrite(uint8_t val) {
        ::analogWrite(this->pin, val);
    };
};

template<typename PinEnum>
class InPin : public AbstractSafePin<PinEnum>
{
public:
    InPin(PinEnum pin) : AbstractSafePin<PinEnum>(pin) {
        pinMode(pin, INPUT);
    };

    bool digitalRead() {
        ::digitalRead(this->pin);
    };
};
//todo: analog pins

#endif