#include "CommandInterface.hpp"

TestStand::TestStand(LoadCell loadcell, Thermocouple thermocouple, 
        PressureTransducer pressuretransducer, NOValve valve)
    : lc{loadcell}, tc{thermocouple}, pt{pressuretransducer}, v{valve}
{}

//arduino é little endian!!!!!!!
CommandData::CommandData(byte serialInput[5]) 

    : code{serialInput[0]}, data{*((float*)(serialInput+1))}
{}

CommandData CommandData::receiveData() {
        byte buf[5];
        Serial.readBytesUntil('\n', buf, 5);
        CommandData command(buf);
}

#define CASE(C, val) case ActionCodes::C: \
    C(val);\
    break;

void TestStand::executeCommand(CommandData data) {
    switch (data.code)
    {
    CASE(CALIBRATE_SCALE, data.data)
    default:
        break;
    }
}

void TestStand::CALIBRATE_SCALE(float data) {
    lc.calibrateScale(data);
}