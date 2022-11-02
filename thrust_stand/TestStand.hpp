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
    void SHOW_LOAD_CELL_READING();
    void TARE_SCALE();
public:
    TestStand(LoadCell loadcell, Thermocouple thermocouple, 
        PressureTransducer pressuretransducer, NOValve valve);

    void executeCommand(CommandData data);
};



enum ActionCodes : uint8_t {
    CALIBRATE_SCALE = 0,
    SHOW_LOAD_CELL_READING = 20,
    TARE_SCALE = 2
};

#endif