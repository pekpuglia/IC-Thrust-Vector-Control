#include "LoadCell.hpp"

/*
    TODO:
    - CLIComponent - interface p cada componente na CLI
    - CLI a própria
        * tara da balança - sem inputs extras
        * ajuste da pressão - dar pressão alvo ou só exibir pressão atual?
        * executar teste - input do tempo de medição, envolve vários componentes
*/

LoadCell cell(MegaPins::D39, MegaPins::D38);

void setup() {
    //trocar por wait_ready_time_out
    delay(500);
    Serial.begin(9600);
    cell.tare();
}


void loop() {
    Serial.println(cell.calibratedRead().unwrap_or_default(-INFINITY));
    delay(200);
}
