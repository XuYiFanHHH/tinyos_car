// remote control button configuration
configuration ButtonC {
  provides interface Button;
}
implementation {
  components HplMsp430GeneralIOC as GIO;
  components ButtonP;
  Button = ButtonP;

  ButtonP.PortA -> GIO.Port60;
  ButtonP.PortB -> GIO.Port21;
  ButtonP.PortC -> GIO.Port61;
  ButtonP.PortD -> GIO.Port23;
  ButtonP.PortE -> GIO.Port62;
  ButtonP.PortF -> GIO.Port26;
}