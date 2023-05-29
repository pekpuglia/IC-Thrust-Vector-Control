#ifndef TEST_STAND_HPP
#define TEST_STAND_HPP

//componentes
#include "LoadCell.hpp"
#include "Thermocouple.hpp"
#include "PressureTransducer.hpp"
#include "Valve.hpp"
#include "CommandData.hpp"

class TestStand
{
private:
    LoadCell lc;
    Thermocouple tc;
    PressureTransducer pt;
    NOValve v;
    void CALIBRATE_SCALE(float data);
    void TARE_SCALE();
    void SCALE_READING();
    void THERMOCOUPLE_READING();
    void TRANSDUCER_READING();
    void OPEN_VALVE();
    void CLOSE_VALVE();
    void FULL_TEST();
public:
    TestStand(LoadCell loadcell, Thermocouple thermocouple, 
        PressureTransducer pressuretransducer, NOValve valve);

    void executeCommand(CommandData data);
};



enum ActionCodes : uint8_t {
    CALIBRATE_SCALE = 0,
    TARE_SCALE = 1,
    SCALE_READING = 2,
    THERMOCOUPLE_READING = 3,
    TRANSDUCER_READING = 4,
    OPEN_VALVE = 5,
    CLOSE_VALVE = 6,
    FULL_TEST = 7
};

#endif