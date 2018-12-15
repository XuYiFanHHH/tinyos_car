#include <Timer.h>
#include "printf.h"

configuration RunAppC {
}
implementation {
  components MainC;
  components LedsC;
  components RunC as App;
  components new TimerMilliC() as Timer0;
  components new TimerMilliC() as ResetArmTimer;
  components new TimerMilliC() as Led0TurnOff;
  components new TimerMilliC() as Led1TurnOff;
  components new TimerMilliC() as Led2TurnOff;
  components ActiveMessageC;
  components new AMReceiverC(AM_ControlMsg);
  components CarC;
  components SerialStartC;

  App.Boot -> MainC;
  App.Leds -> LedsC;
  App.Timer0 -> Timer0;
  App.ResetArmTimer -> ResetArmTimer;
  App.Led0TurnOff -> Led0TurnOff;
  App.Led1TurnOff -> Led1TurnOff;
  App.Led2TurnOff -> Led2TurnOff;
  App.SplitControl -> ActiveMessageC;
  App.Receive -> AMReceiverC;
  App.Car -> CarC;
}
