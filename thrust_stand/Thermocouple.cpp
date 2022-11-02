#include "Thermocouple.hpp"

Thermocouple::Thermocouple(MegaPins sck, MegaPins cs, MegaPins so)
    : sck{sck}, cs{cs}, so{so}
{
    this->cs.digitalWrite(true);
}

const uint8_t Thermocouple::spiread(void) { 
  int i;
  byte d = 0;

  for (i=7; i>=0; i--)
  {
    sck.digitalWrite(false);
    _delay_ms(1);
    if (so.digitalRead()) {
      //set the bit to 1 no matter what
      d |= (1 << i);
    }

    sck.digitalWrite(true);
    _delay_ms(1);
  }

  return d;
}

//usar read result!
const float Thermocouple::readCelsius(void) {

  uint16_t v;

  cs.digitalWrite(false);
  _delay_ms(1);

  v = spiread();
  v <<= 8;
  v |= spiread();

  cs.digitalWrite(true);

  if (v & 0x4) {
    // uh oh, no thermocouple attached!
    return NAN; 
    //return -100;
  }

  v >>= 3;

  return v*0.25;
}