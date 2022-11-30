#include "TestStand.hpp"

/*
    TODO:
    - CLIComponent - interface p cada componente na CLI
    - CLI a própria
        * tara da balança - sem inputs extras
        * ajuste da pressão - dar pressão alvo ou só exibir pressão atual?
        * executar teste - input do tempo de medição, envolve vários componentes
*/

void setup() {
    Serial.begin(9600);
}

TestStand teststand(LoadCell(MegaPins::D2, MegaPins::D3),
            Thermocouple(MegaPins::D7, MegaPins::D6, MegaPins::D5),
            PressureTransducer(A3),
            NOValve(MegaPins::D22));

OutPin led(LED_BUILTIN);

void loop() {
    if (Serial.available() > 0) {
        led.digitalWrite(true);
        delay(50);
        led.digitalWrite(false);
        CommandData command = CommandData::receiveData();
        teststand.executeCommand(command);
    }
    // float x = 1.56 + rand();
    // Serial.println(x);
    // delay(100);
}
