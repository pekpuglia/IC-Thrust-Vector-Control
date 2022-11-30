#ifndef LOAD_CELL_HPP
#define LOAD_CELL_HPP

#include "Arduino.h"
#include "_HX711.hpp"
#include "SafePins.hpp"

template<typename T>
struct ReadResult
{
private:
    T val;
public:
    const bool isValid;

    ReadResult(T val);
    ReadResult();
    T unwrap_or_default(T def);
};

class LoadCell
{
private:

    OutPin pd_sck;

    InPin dout;

    const uint8_t gain;

    long offset = 0;

    float scale = 1;

    ReadResult<long> rawRead();
public:
    //assume ligação no canal A
    LoadCell(uint8_t dout, uint8_t sck);

    bool is_ready();

    bool tare();

    bool calibrateScale(float realMass);
    
    ReadResult<float> calibratedRead();
};


#endif