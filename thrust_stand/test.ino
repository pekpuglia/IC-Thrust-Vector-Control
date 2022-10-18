#include "PressureTransducer.hpp"

/*
    TODO:
    - CLIComponent - interface p cada componente na CLI
    - CLI a própria
        * tara + calibração da balança
        * ajuste da pressão
        * tempo de medição
    - migrar p SafePin
    - fazer loadcell ser non blocking
*/

PressureTransducer p(A8);

void setup() {
    Serial.begin(9600);
}


void loop() {
    Serial.println(p.readBar());
    delay(250);
}
