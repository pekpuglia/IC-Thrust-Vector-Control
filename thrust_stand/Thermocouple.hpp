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
    Thermocouple(MegaPins sck, MegaPins cs, MegaPins so);
    const double readCelsius();
};


#endif