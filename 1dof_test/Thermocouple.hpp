#ifndef THERMOCOUPLE_HPP
#define THERMOCOUPLE_HPP

#include "Arduino.h"
#include "SafePins.hpp"

class Thermocouple
{
private:
    OutPin sck, cs;
    InPin so;

    //copiado da lib arduino max6675
    const uint8_t spiread(void);

public:
    Thermocouple(uint8_t sck, uint8_t cs, uint8_t so);
    const float readCelsius();
};


#endif