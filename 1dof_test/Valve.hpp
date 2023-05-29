#ifndef VALVE_HPP
#define VALVE_HPP

#include "Arduino.h"
#include "SafePins.hpp"

/*
----------------------------------------
IN    | Luz verde | Circuito | Válvula
false | acesa     | fechado  | aberta
true  | apagada   | aberto   | fechada
----------------------------------------

NOValve = Normally Open Valve
O relay está na configuração normally open (sem conexão no IN, 
a tensão é ~4V, e cai no caso TRUE da tabela acima)

*/
class NOValve
{
private:
    OutPin pin;
public:
    NOValve(OutPin pin);

    void open();

    void close();

    ~NOValve();
};

#endif