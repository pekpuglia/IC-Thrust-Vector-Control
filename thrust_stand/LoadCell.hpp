#ifndef LOAD_CELL_HPP
#define LOAD_CELL_HPP

#include "Arduino.h"
#include "_HX711.hpp"

class LoadCell
{
private:
    HX711 sensor;
    
    bool calibrated;

    unsigned int repetitions;

public:
    //assume ligação no canal A
    LoadCell(byte dt, byte sck, unsigned int repetitions);

    void tare();

    void calibrateScale(double realMass);

    double rawRead();
    //pode interromper o programa
    double calibratedRead();
};

#endif