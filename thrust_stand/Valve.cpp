#include "Valve.hpp"

NOValve::NOValve(OutPin pin)
    : pin{pin}
{
    close();
}

void NOValve::open() {
    pin.digitalWrite(false);
}

void NOValve::close() {
    pin.digitalWrite(true);
}

NOValve::~NOValve() {
    close();
}