#include "LoadCell.hpp"

//inseguro - como lidar com falha??
LoadCell::LoadCell(byte dt, byte sck, unsigned int repetitions)
    : sensor{}, calibrated{false}, repetitions{repetitions}
{
    sensor.begin(dt, sck);
    bool success = sensor.wait_ready_timeout();
    if (!success)
        Serial.println("Celula de carga falhou em ser ativada. Verificar conexões e pinagem.");
    
    sensor.set_scale();
    sensor.tare();
}

void LoadCell::tare() {
    sensor.tare();
}

void LoadCell::calibrateScale(double realMass) {

    sensor.set_scale(sensor.get_units(repetitions) / realMass);
    calibrated = true;
}

double LoadCell::rawRead() {
    return sensor.get_value(repetitions);
}

double LoadCell::calibratedRead() {
    if (calibrated)
        return sensor.get_units(repetitions);
    else
        return -INFINITY;
}