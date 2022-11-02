#include "TestStand.hpp"

TestStand::TestStand(LoadCell loadcell, Thermocouple thermocouple, 
        PressureTransducer pressuretransducer, NOValve valve)
    : lc{loadcell}, tc{thermocouple}, pt{pressuretransducer}, v{valve}
{}

#define CASE_W_INPUT(C, val) case ActionCodes::C: \
    C(val);\
    break;

#define CASE(C) case ActionCodes::C: \
    C(); \
    break;

void TestStand::executeCommand(CommandData data) {
    // Serial.println(ActionCodes::SHOW_LOAD_CELL_READING);
    switch (data.code)
    {
    CASE_W_INPUT(CALIBRATE_SCALE, data.data)
    CASE(SHOW_LOAD_CELL_READING)
    CASE(TARE_SCALE)
    CASE(SHOW_THERMOCOUPLE_READING)
    CASE(SHOW_SCALE_AND_THERMOCOUPLE)
    default:
        break;
    }
}
//##############################################################
//load cell
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
//################################################################
void TestStand::SHOW_THERMOCOUPLE_READING() {
    float reading = tc.readCelsius();
    Serial.println(reading, 4);
}

void TestStand::SHOW_SCALE_AND_THERMOCOUPLE() {
    float scale = lc.calibratedRead().unwrap_or_default(-1);
    float t = tc.readCelsius();
    Serial.print(scale, 4);
    Serial.print(" ");
    Serial.println(t, 4);
}