// button module and command definitions

module ButtonP {
    provides {
        interface Button;
    }

    uses {
    	interface HplMsp430GeneralIO as PortA;
    	interface HplMsp430GeneralIO as PortB;
    	interface HplMsp430GeneralIO as PortC;
    	interface HplMsp430GeneralIO as PortD;
    	interface HplMsp430GeneralIO as PortE;
    	interface HplMsp430GeneralIO as PortF;
	}
}

implementation {

	command void Button.start() {
        // set pin to low
		call PortA.clr();
		call PortB.clr();
		call PortC.clr();
		call PortD.clr();
		call PortE.clr();
		call PortF.clr();
        // Set pin direction to input.
		call PortA.makeInput();
		call PortB.makeInput();
		call PortC.makeInput();
		call PortD.makeInput();
		call PortE.makeInput();
		call PortF.makeInput();
		signal Button.startDone(SUCCESS);
	}
	
	command void Button.stop() {
        // set pin to low
		call PortA.clr();
		call PortB.clr();
		call PortC.clr();
		call PortD.clr();
		call PortE.clr();
		call PortF.clr();
		signal Button.stopDone(SUCCESS);
	}
	
	command void Button.pinValueA() {
        // Read pin value
		bool pinA = call PortA.get();
		signal Button.pinValueADone(pinA);
	}

	command void Button.pinValueB() {
        // Read pin value
		bool pinB = call PortB.get();
		signal Button.pinValueBDone(pinB);
	}

	command void Button.pinValueC() {
        // Read pin value
		bool pinC = call PortC.get();
		signal Button.pinValueCDone(pinC);
	}

	command void Button.pinValueD() {
        // Read pin value
		bool pinD = call PortD.get();
		signal Button.pinValueDDone(pinD);
	}

	command void Button.pinValueE() {
        // Read pin value
		bool pinE = call PortE.get();
		signal Button.pinValueEDone(pinE);
	}

	command void Button.pinValueF() {
        // Read pin value
		bool pinF = call PortF.get();
		signal Button.pinValueFDone(pinF);
	}
}