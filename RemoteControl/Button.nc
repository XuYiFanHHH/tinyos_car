// button interface
interface Button {
	command void start();
	event void startDone(error_t err);

	command void stop();
	event void stopDone(error_t err);
	
	command void pinValueA();
	event void pinValueADone(bool value);

	command void pinValueB();
	event void pinValueBDone(bool value);

	command void pinValueC();
	event void pinValueCDone(bool value);

	command void pinValueD();
	event void pinValueDDone(bool value);

	command void pinValueE();
	event void pinValueEDone(bool value);

	command void pinValueF();
	event void pinValueFDone(bool value);
}