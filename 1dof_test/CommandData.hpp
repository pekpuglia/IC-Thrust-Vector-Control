#ifndef COMMAND_DATA_HPP
#define COMMAND_DATA_HPP

#include "Arduino.h"

struct CommandData
{
    const uint8_t code;
    const float data;
    CommandData(byte serialInput[5]);
    static CommandData receiveData();
};

#endif