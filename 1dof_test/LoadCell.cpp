#include "LoadCell.hpp"
//testar tudo
template<typename T>
ReadResult<T>::ReadResult(T val)
    : isValid{true}, val{val}
{}

template<typename T>
ReadResult<T>::ReadResult()
    : isValid{false}
{}

template<typename T>
T ReadResult<T>::unwrap_or_default(T def) {
    return (isValid) ? val : def;
}

template struct ReadResult<long>;
template struct ReadResult<float>;

LoadCell::LoadCell(uint8_t dout, uint8_t sck)
    : pd_sck{sck}, dout{dout}, gain{1}
{}

bool LoadCell::is_ready() {
    return dout.digitalRead() == false;
}

#define SHIFTIN_WITH_SPEED_SUPPORT(data,clock,order) shiftIn(data,clock,order)

ReadResult<long> LoadCell::rawRead() {

	if (!is_ready())
        return ReadResult<long>();

	// Define structures for reading data into.
	unsigned long value = 0;
	uint8_t data[3] = { 0 };
	uint8_t filler = 0x00;

	// Protect the read sequence from system interrupts.  If an interrupt occurs during
	// the time the PD_SCK signal is high it will stretch the length of the clock pulse.
	// If the total pulse time exceeds 60 uSec this will cause the HX711 to enter
	// power down mode during the middle of the read sequence.  While the device will
	// wake up when PD_SCK goes low again, the reset starts a new conversion cycle which
	// forces DOUT high until that cycle is completed.
	//
	// The result is that all subsequent bits read by shiftIn() will read back as 1,
	// corrupting the value returned by read().  The ATOMIC_BLOCK macro disables
	// interrupts during the sequence and then restores the interrupt mask to its previous
	// state after the sequence completes, insuring that the entire read-and-gain-set
	// sequence is not interrupted.  The macro has a few minor advantages over bracketing
	// the sequence between `noInterrupts()` and `interrupts()` calls.

	// Disable interrupts.
	noInterrupts();

	// Pulse the clock pin 24 times to read the data.
	data[2] = SHIFTIN_WITH_SPEED_SUPPORT(dout, pd_sck, MSBFIRST);
	data[1] = SHIFTIN_WITH_SPEED_SUPPORT(dout, pd_sck, MSBFIRST);
	data[0] = SHIFTIN_WITH_SPEED_SUPPORT(dout, pd_sck, MSBFIRST);

	// Set the channel and the gain factor for the next reading using the clock pin.
	for (unsigned int i = 0; i < gain; i++) {
        pd_sck.digitalWrite(true);
        pd_sck.digitalWrite(false);
	}

	// Enable interrupts again.
	interrupts();

	// Replicate the most significant bit to pad out a 32-bit signed integer
	if (data[2] & 0x80) {
		filler = 0xFF;
	} else {
		filler = 0x00;
	}

	// Construct a 32-bit signed integer
	value = ( static_cast<unsigned long>(filler) << 24
			| static_cast<unsigned long>(data[2]) << 16
			| static_cast<unsigned long>(data[1]) << 8
			| static_cast<unsigned long>(data[0]) );

	return ReadResult<long>(static_cast<long>(value));
}

bool LoadCell::tare() {
	long total = 0;
	int validReadings = 0;
	for (int i = 0; i < 10; i++) {
    	auto readRes = rawRead();
		if (readRes.isValid)
		{
			validReadings++;
		}
		total += readRes.unwrap_or_default(0);
	}
	if (validReadings != 0)
    	offset = total / validReadings;
    return (validReadings != 0);
}

bool LoadCell::calibrateScale(float realMass) {
    if (realMass <= 0)
        return false;

	long total = 0;
	int validReadings = 0;
	for (int i = 0; i < 10; i++) {
    	auto readRes = rawRead();
		if (readRes.isValid)
		{
			validReadings++;
		}
		total += readRes.unwrap_or_default(0);
	}
	if (validReadings != 0)
		scale = ((float) total / ((float) validReadings) - (float) offset) / realMass;

    return (validReadings != 0);
}

ReadResult<float> LoadCell::calibratedRead() {
    auto readRes = rawRead();
    if (!readRes.isValid)
        return ReadResult<float>();
    //nunca vai ser inválido aqui
    long res = readRes.unwrap_or_default(0);
    return ReadResult<float>((float)(res - offset) / scale);
}