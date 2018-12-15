#include <Timer.h>
#include "printf.h"
#include "ControlMsg.h"

module RunC {
    uses {
        interface Boot;
        interface Leds;
        interface Timer<TMilli> as Timer0;
        interface Timer<TMilli> as ResetArmTimer;
        interface Timer<TMilli> as Led0TurnOff;
        interface Timer<TMilli> as Led1TurnOff;
        interface Timer<TMilli> as Led2TurnOff;
        interface Car;
        interface SplitControl as SplitControl;
        interface Receive as Receive;
    }
}

implementation {
    uint16_t num = 0;
    uint16_t type;
    uint16_t m_value;
    // if auto move without the msg of remote control
    bool auto_move = FALSE;
    // to reset arms, two steps are needed(angle1 and angle2)
    uint16_t reset_arm_step = 0;
    bool reset_arm = FALSE;

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
            auto_move = TRUE;
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

    void carMoveForward(uint16_t value){
        type = 2;
        set_leds();
        call Car.Forward(value);
    }

    void carMoveBack(uint16_t value){
        type = 3;
        set_leds();
        call Car.Back(value);
    }

    void carMoveLeft(uint16_t value){
        type = 4;
        set_leds();
        call Car.Left(value);
    }

    void carMoveRight(uint16_t value){
        type = 5;
        set_leds();
        call Car.Right(value);
    }

    void carMovePause(){
        type = 6;
        set_leds();
        call Car.Pause();
    }

    void armMoveRight(){
        type = 1;
        m_value = 0;
        set_leds();
        call Car.Angle_1(0);
    }

    void armMoveLeft(){
        type = 1;
        m_value = 1;
        set_leds();
        call Car.Angle_1(1);
    }

    void armMoveUp(){
        type = 7;
        m_value = 0;
        set_leds();
        call Car.Angle_2(0);
    }

    void armMoveDown(){
        type = 7;
        m_value = 1;
        set_leds();
        call Car.Angle_2(1);
    }

    void resetAngle_1(){
        type = 1;
        m_value = 2;
        set_leds();
        call Car.Angle_1(2);
    }

    void resetAngle_2(){
        type = 7;
        m_value = 2;
        set_leds();
        call Car.Angle_2(2);
    }

    event error_t Car.InitAngle_1Done() {
		reset_arm_step = 1;
		call ResetArmTimer.startPeriodic(100);
	}

	event error_t Car.InitAngle_2Done() {
		reset_arm_step = 2;
	}

    event void ResetArmTimer.fired(){
        call ResetArmTimer.stop();
        if(reset_arm == TRUE && reset_arm_step == 1){
            resetAngle_2();
        }
    }

    event void Timer0.fired() {
        num++;
        if(num == 1) {
            carMoveForward(CAR_SPEED);
        }
        else if(num == 11) {
            carMoveBack(CAR_SPEED);
        }
        else if(num == 21) {
            carMoveLeft(CAR_SPEED);
        }
        else if(num == 31) {
            carMoveRight(CAR_SPEED);
        }
        else if(num == 41) {
            carMovePause();
        }
        else if(num == 42 || num == 47 || num == 52) {
            armMoveRight();
        }
        else if(num == 57 || num == 62 || num == 67 || num == 72 || num == 77) {
            armMoveLeft();
        }
        else if(num == 82) {
            reset_arm = FALSE;
            resetAngle_1();
        }
        else if(num ==87 || num == 92 || num == 97) {
            armMoveUp();
        }
        else if(num == 102 || num == 107 || num == 112 || num == 117 || num == 122) {
            armMoveDown();
        }
        else if(num == 127) {
            resetAngle_2();
        }
        else if (num > 127){
            initLeds();
            auto_move = FALSE;
            call Timer0.stop();
        }           
    }

    event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
        if(!auto_move && len == sizeof(ControlMsg))
        {
            ControlMsg* packet = (ControlMsg*) payload;
            reset_arm = FALSE;
            if(packet->type == 1)
            {
                carMoveForward(packet->data);
            }
            else if(packet->type == 2)
            {
                carMoveBack(packet->data);
            }
            else if(packet->type == 3)
            {
                carMoveLeft(packet->data);
            }
            else if(packet->type == 4)
            {
                carMoveRight(packet->data);
            }
            else if(packet->type == 5)
            {
                carMovePause();
            }
            else if(packet->type == 6)
            {
                armMoveRight();
            }
            else if(packet->type == 7)
            {
                armMoveLeft();
            }
            else if(packet->type == 8)
            {
                armMoveUp();
            }
            else if(packet->type == 9)
            {
                armMoveDown();
            }
            else if(packet->type == 10)
            {
                reset_arm = TRUE;
                reset_arm_step = 0;
                resetAngle_1();
            }
        }
        return msg;
    }
}