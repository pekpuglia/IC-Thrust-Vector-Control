#ifndef COMMAND_INTERFACE_HPP
#define COMMAND_INTERFACE_HPP

#include "Arduino.h"

//componentes
#include "LoadCell.hpp"
#include "Thermocouple.hpp"
#include "PressureTransducer.hpp"
#include "Valve.hpp"

struct CommandData
{
    const uint8_t code;
    const float data;
    CommandData(byte serialInput[5]);
    static CommandData receiveData();
};

class TestStand
{
private:
    LoadCell lc;
    Thermocouple tc;
    PressureTransducer pt;
    NOValve v;
    void CALIBRATE_SCALE(float data);
public:
    TestStand(LoadCell loadcell, Thermocouple thermocouple, 
        PressureTransducer pressuretransducer, NOValve valve);

    void executeCommand(CommandData data);
};



enum ActionCodes : uint8_t {
    CALIBRATE_SCALE = 0
};


#endif