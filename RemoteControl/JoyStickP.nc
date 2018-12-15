// module JoyStick and definitions of several commands
#include "Msp430Adc12.h"

module JoyStickP {
    // provide 2 interfaces as the configuration of X and Y
    provides {
        interface AdcConfigure<const msp430adc12_channel_config_t*> as AdcConfigureX;
        interface AdcConfigure<const msp430adc12_channel_config_t*> as AdcConfigureY;
    }

    uses {
    	interface HplMsp430GeneralIO;
	}
}

implementation {

    // X and Y output configuration

	const msp430adc12_channel_config_t Xconfiguration = {
		inch: INPUT_CHANNEL_A6,
		sref: REFERENCE_VREFplus_AVss,
		ref2_5v: REFVOLT_LEVEL_2_5,
		adc12ssel: SHT_SOURCE_ACLK,
		adc12div: SHT_CLOCK_DIV_1,
		sht: SAMPLE_HOLD_4_CYCLES,
		sampcon_ssel: SAMPCON_SOURCE_SMCLK,
		sampcon_id: SAMPCON_CLOCK_DIV_1
	};

	const msp430adc12_channel_config_t Yconfiguration = {
		inch: INPUT_CHANNEL_A7,
		sref: REFERENCE_VREFplus_AVss,
		ref2_5v: REFVOLT_LEVEL_2_5,
		adc12ssel: SHT_SOURCE_ACLK,
		adc12div: SHT_CLOCK_DIV_1,
		sht: SAMPLE_HOLD_4_CYCLES,
		sampcon_ssel: SAMPCON_SOURCE_SMCLK,
		sampcon_id: SAMPCON_CLOCK_DIV_1
	};

	async command const msp430adc12_channel_config_t* AdcConfigureX.getConfiguration() {
    	return &Xconfiguration;
  	}

  	async command const msp430adc12_channel_config_t* AdcConfigureY.getConfiguration() {
    	return &Yconfiguration;
  	}
}