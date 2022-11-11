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
    CASE(TARE_SCALE)
    CASE(SCALE_READING)
    CASE(THERMOCOUPLE_READING)
    CASE(TRANSDUCER_READING)
    CASE(OPEN_VALVE)
    CASE(CLOSE_VALVE)
    CASE(FULL_TEST)
    default:
        break;
    }
}
//##############################################################
//load cell
void TestStand::CALIBRATE_SCALE(float data) {
    lc.calibrateScale(data);
}

void TestStand::TARE_SCALE() {
    lc.tare();
}

void TestStand::SCALE_READING() {
    auto res = lc.calibratedRead();
    //mudar p write?
    Serial.println(res.unwrap_or_default(-1), 4);
}

//################################################################
void TestStand::THERMOCOUPLE_READING() {
    float reading = tc.readCelsius();
    Serial.println(reading, 4);
}

void TestStand::TRANSDUCER_READING() {
    float reading = pt.readBar();
    Serial.println(reading, 4);
}

void TestStand::OPEN_VALVE() {
    v.open();
}

void TestStand::CLOSE_VALVE() {
    v.close();
}

void TestStand::FULL_TEST() {
    float scale_reading = lc.calibratedRead().unwrap_or_default(-1);
    float therm_reading = tc.readCelsius();
    float trans_reading = pt.readBar();
    Serial.print(scale_reading, 4);
    Serial.print(" ");
    Serial.print(therm_reading, 4);
    Serial.print(" ");
    Serial.println(trans_reading, 4);
}