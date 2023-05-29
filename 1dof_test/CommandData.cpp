#include "CommandData.hpp"



//arduino é little endian!!!!!!!
CommandData::CommandData(byte serialInput[5]) 

    : code{serialInput[0]}, data{*((float*)(serialInput+1))}
{
}

CommandData CommandData::receiveData() {
        byte buf[5];
        Serial.readBytesUntil('\n', buf, 5);
        CommandData command(buf);
        return command;
}

