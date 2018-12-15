// JoyStick configuration
configuration JoyStickC {
	provides {
        // adc input of X and Y
		interface Read<uint16_t> as ReadX;
		interface Read<uint16_t> as ReadY;
	}
}
implementation {
	components JoyStickP;
	components new AdcReadClientC() as AdcClientX;
	components new AdcReadClientC() as AdcClientY;
	ReadX = AdcClientX;
	ReadY = AdcClientY;
    // bind AdcConfigure interface to the JoyStickP relative interface 
    // use AdcConfigure.getConfiguration() to get congiguration of X and Y
	AdcClientX.AdcConfigure -> JoyStickP.AdcConfigureX;
	AdcClientY.AdcConfigure -> JoyStickP.AdcConfigureY;
}