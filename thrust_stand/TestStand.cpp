#include "TestStand.hpp"

TestStand::TestStand(LoadCell loadcell, Thermocouple thermocouple, 
        PressureTransducer pressuretransducer, NOValve valve)
    : lc{loadcell}, tc{thermocouple}, pt{pressuretransducer}, v{valve}
{}

#define CASE_W_INPUT(C, val) case ActionCodes::C: \
    C(val);\
    break;

void TestStand::executeCommand(CommandData data) {
    // Serial.println(ActionCodes::SHOW_LOAD_CELL_READING);
    switch (data.code)
    {
    CASE_W_INPUT(CALIBRATE_SCALE, data.data)
    case ActionCodes::SHOW_LOAD_CELL_READING:
        SHOW_LOAD_CELL_READING();
        break;
    case ActionCodes::TARE_SCALE:
        TARE_SCALE();
        break;
    default:
        break;
    }
}

void TestStand::CALIBRATE_SCALE(float data) {
    lc.calibrateScale(data);
}

void TestStand::SHOW_LOAD_CELL_READING() {
    auto res = lc.calibratedRead();
    //mudar p write?
    Serial.println(res.unwrap_or_default(-1), 4);
}

void TestStand::TARE_SCALE() {
    lc.tare();
}