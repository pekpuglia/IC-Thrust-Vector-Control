#ifndef THERMOCOUPLE_HPP
#define THERMOCOUPLE_HPP

#include "Arduino.h"

class Thermocouple
{
private:
    const uint8_t sck, cs, so;

    //copiado da lib arduino max6675
    const uint8_t spiread(void);

public:
    Thermocouple(uint8_t sck, uint8_t cs, uint8_t so);
    const double readCelsius();
};


#endif