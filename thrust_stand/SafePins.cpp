#include "SafePins.hpp"

AbstractSafePin::AbstractSafePin(uint8_t pin)
     : pin{pin} 
{}

AbstractSafePin::operator uint8_t() {
    return pin;
}

OutPin::OutPin(uint8_t pin) 
: AbstractSafePin(pin) {
    pinMode(pin, OUTPUT);
}

void OutPin::digitalWrite(bool val) {
    //escopo globa
    ::digitalWrite(this->pin, (val) ? HIGH : LOW);
}

void OutPin::analogWrite(uint8_t val) {
    ::analogWrite(this->pin, val);
}

InPin::InPin(uint8_t pin) : AbstractSafePin(pin) {
    pinMode(pin, INPUT_PULLUP);
}

bool InPin::digitalRead() {
    return ::digitalRead(pin);
}