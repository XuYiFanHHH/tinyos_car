#include <Timer.h>
#include "printf.h"

module RunC {
    uses {
        interface Boot;
        interface Leds;
        interface Timer<TMilli> as Timer0;
        interface Timer<TMilli> as Led0TurnOff;
        interface Timer<TMilli> as Led1TurnOff;
        interface Timer<TMilli> as Led2TurnOff;
        interface Car;
        interface SplitControl as SplitControl;
    }
}

implementation {
    uint16_t num = 0;
    uint16_t type;
    uint16_t m_value;

    void initLeds() {
        call Leds.led0Off();
        call Leds.led1Off();
        call Leds.led2Off();
    }

    void blink(uint8_t led0, uint8_t led1, uint8_t led2) {
        if(led0 == 1) {
            call Leds.led0On();
            call Led0TurnOff.startPeriodic(250);            
        }
        if(led1 == 1) {
            call Leds.led1On();
            call Led1TurnOff.startPeriodic(250);            
        }
        if(led2 == 1) {
            call Leds.led2On();
            call Led2TurnOff.startPeriodic(250);
        }
    }

    void set_leds() {
        initLeds();
        if(type == 1) {
            //angle1
            if(m_value == 0) {
               blink(0, 1, 0);
            }
            else if(m_value == 1) {
               blink(0, 0, 1);
            }
            else if(m_value == 2) {
                blink(0, 1, 1);
            }
        }
        else if(type == 2) {
            //forward
            call Leds.led0On();
        }
        else if(type == 3) {
            //back
            call Leds.led1On();
        }
        else if(type == 4) {
            //left
            call Leds.led0On();
            call Leds.led1On();
        }
        else if(type == 5) {
            //right
            call Leds.led0On();
            call Leds.led2On();
        }
        else if(type == 6) {
            //pause
            blink(1, 1, 1);
        }
        else if(type == 7) {
            //angle2
            call Leds.led0On();
            if(m_value == 0) {
                blink(0, 1, 0);
            }
            else if(m_value == 1) {
                blink(0, 0, 1);
            }
            else if(m_value == 2) {
                blink(0, 1, 1);
            }
        }
        else if(type == 8) {
            call Leds.led0On();
            call Leds.led1On();
            call Leds.led2On();
        }
    }


    event void Boot.booted() {
        call SplitControl.start();
    }

    event void SplitControl.startDone(error_t err) {
        if(err == SUCCESS) {
            call Timer0.startPeriodic( 300 );
        }
        else {
            call SplitControl.start();
        }
    }
    event void SplitControl.stopDone(error_t err) {

    }

    event void Led0TurnOff.fired() {
        call Leds.led0Toggle();
        call Led0TurnOff.stop();
    }

    event void Led1TurnOff.fired() {
        call Leds.led1Toggle();
        call Led1TurnOff.stop();
    }
    event void Led2TurnOff.fired() {
        call Leds.led2Toggle();
        call Led2TurnOff.stop();
    }

    event void Timer0.fired() {
        num++;
        if(num == 1) {
            type = 2;
            set_leds();
            call Car.Forward(500);
        }
        else if(num == 11) {
            type = 3;
            set_leds();
            call Car.Back(500);
        }
        else if(num == 21) {
            type = 4;
            set_leds();
            call Car.Left(500);
        }
        else if(num == 31) {
            type = 5;
            set_leds();
            call Car.Right(500);
        }
        else if(num == 41) {
            type = 6;
            set_leds();
            call Car.Pause();
        }
        else if(num == 42 || num == 47 || num == 52) {
            type = 1;
            m_value = 0;
            set_leds();
            call Car.Angle_1(0);
        }
        else if(num == 57 || num == 62 || num == 67 || num == 72 || num == 77) {
            type = 1;
            m_value = 1;
            set_leds();
            call Car.Angle_1(1);
        }
        else if(num == 82) {
            type = 1;
            m_value = 2;
            set_leds();
            call Car.Angle_1(2);
        }
        else if(num ==87 || num == 92 || num == 97) {
            type = 7;
            m_value = 0;
            set_leds();
            call Car.Angle_2(0);
        }
        else if(num == 102 || num == 107 || num == 112 || num == 117 || num == 122) {
            type = 7;
            m_value = 1;
            set_leds();
            call Car.Angle_2(1);
        }
        else if(num == 127) {
            type = 7;
            m_value = 2;
            set_leds();
            call Car.Angle_2(2);
        }
        else if (num > 127){
            initLeds();
            call Timer0.stop();
        }
            
    }
}