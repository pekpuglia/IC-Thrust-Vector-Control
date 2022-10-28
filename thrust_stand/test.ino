#include "CommandInterface.hpp"
#include "SafePins.hpp"
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

TestStand teststand(LoadCell(MegaPins::D39, MegaPins::D38),
            Thermocouple(MegaPins::D47, MegaPins::D49, MegaPins::D51),
            PressureTransducer(A3),
            NOValve(MegaPins::D30));

void loop() {
    if (Serial.available() > 0) {
        CommandData command = CommandData::receiveData();
        teststand.executeCommand(command);
    }
}
