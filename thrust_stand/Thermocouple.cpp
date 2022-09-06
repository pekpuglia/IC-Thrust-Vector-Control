#include "Thermocouple.hpp"

Thermocouple::Thermocouple(uint8_t sck, uint8_t cs, uint8_t so)
    : sck{sck}, cs{cs}, so{so}
{
    pinMode(cs, OUTPUT);
    pinMode(sck, OUTPUT);
    pinMode(so, OUTPUT);

    digitalWrite(cs, HIGH);
}

const uint8_t Thermocouple::spiread(void) { 
  int i;
  byte d = 0;

  for (i=7; i>=0; i--)
  {
    digitalWrite(sck, LOW);
    _delay_ms(1);
    if (digitalRead(so)) {
      //set the bit to 1 no matter what
      d |= (1 << i);
    }

    digitalWrite(sck, HIGH);
    _delay_ms(1);
  }

  return d;
}


const double Thermocouple::readCelsius(void) {

  uint16_t v;

  digitalWrite(cs, LOW);
  _delay_ms(1);

  v = spiread();
  v <<= 8;
  v |= spiread();

  digitalWrite(cs, HIGH);

  if (v & 0x4) {
    // uh oh, no thermocouple attached!
    return NAN; 
    //return -100;
  }

  v >>= 3;

  return v*0.25;
}