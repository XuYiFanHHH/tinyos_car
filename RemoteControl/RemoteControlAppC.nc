#include "ControlMsg.h"
configuration RemoteControlAppC {}
implementation {
	components MainC, ButtonC, LedsC, JoyStickC;
	components RemoteControlC as App;
    components ActiveMessageC;
    components new AMSenderC(AM_ControlMsg);
	components new TimerMilliC() as ControlTimer;
	components new TimerMilliC() as TestTimer;

	App.Boot -> MainC;
	App.Leds -> LedsC;	
	App.Button -> ButtonC.Button;
	App.adcReadX -> JoyStickC.ReadX;
	App.adcReadY -> JoyStickC.ReadY;
	App.MilliTimer -> ControlTimer;
	App.TestTimer ->  TestTimer;

	App.Packet -> AMSenderC;
	App.AMSend -> AMSenderC;
	App.AMControl -> ActiveMessageC;
}