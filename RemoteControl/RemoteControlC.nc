#include "Timer.h"
#include "ControlMsg.h"

module RemoteControlC {
    uses {
        interface Boot;
        interface Leds;
        interface Timer<TMilli> as MilliTimer;
        interface Timer<TMilli> as TestTimer;
        interface Packet;
        interface AMSend;
        interface SplitControl as AMControl;
        interface Read<uint16_t> as adcReadX;
        interface Read<uint16_t> as adcReadY;
        interface Button;
    }
}
implementation {

    message_t packet;
    uint8_t action_type;
	uint16_t action_data;
    // if control is sending message
    bool locked = FALSE;

    bool pinA;
	bool pinB;
	bool pinC;
	bool pinD;
	bool pinE;
	bool pinF;
	uint16_t joyStickXvalue;
	uint16_t joyStickYvalue;
    uint8_t lastJoyStickState = 5;
    uint8_t lastButtonState = 0;
    // test count
    uint16_t num = 0;

	bool ADone;
	bool BDone;
	bool CDone;
	bool DDone;
	bool EDone;
	bool FDone;
	bool XDone;
	bool YDone;

	event void Boot.booted() {
        locked = FALSE;
		call Button.start();
		call AMControl.start();
	}

    // set timer
	event void AMControl.startDone(error_t err) {
		if (err == SUCCESS) {
            call Leds.led1Toggle();
			// call MilliTimer.startPeriodic(TIMER_PERIOD_MILLI);
            call TestTimer.startPeriodic(1000);
            num = 0;
		}
		else {
			call AMControl.start();
		}
	}

	event void AMControl.stopDone(error_t err) {}

    // send prepared frame, add lock
	void send_command() {
        if (locked) {
            return;
        }
        else
        {
            ControlMsg* sendPacket;
            call Leds.led2Toggle();
            sendPacket = (ControlMsg*)(call Packet.getPayload(&packet, sizeof(ControlMsg)));
            sendPacket->type = action_type;
            sendPacket->data = action_data;
            if ((call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(ControlMsg))) == SUCCESS) {
                locked = TRUE;
            }
        }
    }

    // sending complete, release lock
    event void AMSend.sendDone(message_t* bufPtr, error_t error) {
        locked = FALSE;
        call Leds.led2Toggle();
    }

    void set_car_movement(){
        // TURN LEFT
        if (joyStickYvalue <= MIN_JOYSTICK) {
            action_type = 3;
            action_data = CAR_SPEED;
        }
        // TURN RIGHT
        else if (joyStickYvalue >= MAX_JOYSTICK) {
            action_type = 4;
            action_data = CAR_SPEED;
        }
        // BACK
        else if (joyStickXvalue >= MAX_JOYSTICK) {
            action_type = 2;
            action_data = CAR_SPEED;
        }
        // FORWARD
        else if (joyStickXvalue <= MIN_JOYSTICK) {
            action_type = 1;
            action_data = CAR_SPEED;
        }
        // PAUSE
        else{
            action_type = 5;
            action_data = 0;
        }
        // if stick state have not change, do not send message
        if(action_type != lastJoyStickState && action_type != 0)
        {
            send_command();
            lastJoyStickState = action_type;
        }
    }

    void set_arm_movement(){
        // RESET
        if (!pinC) {
            action_type = 10;
            action_data = 0;
        }
        // GO RIGHT
        else if ((pinA) && (!pinB) && (pinC) && (pinE) && (pinF)) {
            action_type = 6;
            action_data = 0;
        }
        // GO LEFT
        else if ((!pinA) && (pinB) && (pinC) && (pinE) && (pinF)) {
            action_type = 7;
            action_data = 0;
        }
        // GO UP
        else if ((pinA) && (!pinB) && (pinC) && (pinE) && (pinF)) {
            action_type = 8;
            action_data = 0;
        }
        // GO DOWN
        else if ((!pinA) && (pinB) && (pinC) && (pinE) && (pinF)) {
            action_type = 9;
            action_data = 0;
        }
        // no button down or invalid instruction
        else
        {
            action_type = 0;
            action_data = 0;
        }
        // if invalid instruction or repeate command, do not send the packet
        if(action_type != 0 && action_type != lastButtonState)
        {
            send_command();
            lastButtonState = action_type;
        }
    }

    // already get all value from button and joystick
    // prepare frame to be sent
    void get_value_complete(){
        set_car_movement();
        set_arm_movement();
    }
	
    // timeout event, try to get all value from button and joystick
	event void MilliTimer.fired() {
        // reset all parameters, all done == True then send msg
		ADone = FALSE;
		BDone = FALSE;
		CDone = FALSE;
		DDone = FALSE;
		EDone = FALSE;
		FDone = FALSE;
		XDone = FALSE;
		YDone = FALSE;
        // get pin and joystick content
		call Button.pinValueA();
		call Button.pinValueB();
		call Button.pinValueC();
		call Button.pinValueD();
		call Button.pinValueE();
		call Button.pinValueF();
		call adcReadX.read();
		call adcReadY.read();
	}

    // test timeout event
    event void TestTimer.fired(){
        action_type = num % 10 + 1;
        if(action_type <= 4){
            action_data == CAR_SPEED;
        }
        else{
            action_data = 0;
        }
        send_command();
        num++;
    }

	event void Button.startDone(bool value) {}

	event void Button.stopDone(bool value) {}

	event void Button.pinValueADone(bool value) {
		pinA = value;
		ADone = TRUE;
		if (ADone && BDone && CDone 
			&& DDone && EDone && FDone
			&& XDone && YDone) {
			get_value_complete();
		}
	}

	event void Button.pinValueBDone(bool value) {
		pinB = value;
		BDone = TRUE;
		if (ADone && BDone && CDone 
			&& DDone && EDone && FDone
			&& XDone && YDone) {
			get_value_complete();
		}
	}

	event void Button.pinValueCDone(bool value) {
		pinC = value;
		CDone = TRUE;
		if (ADone && BDone && CDone 
			&& DDone && EDone && FDone
			&& XDone && YDone) {
			get_value_complete();
		}
	}

	event void Button.pinValueDDone(bool value) {
		pinD = value;
		DDone = TRUE;
		if (ADone && BDone && CDone 
			&& DDone && EDone && FDone
			&& XDone && YDone) {
			get_value_complete();
		}
	}

	event void Button.pinValueEDone(bool value) {
		pinE = value;
		EDone = TRUE;
		if (ADone && BDone && CDone 
			&& DDone && EDone && FDone
			&& XDone && YDone) {
			get_value_complete();
		}
	}

	event void Button.pinValueFDone(bool value) {
		pinF = value;
		FDone = TRUE;
		if (ADone && BDone && CDone 
			&& DDone && EDone && FDone
			&& XDone && YDone) {
			get_value_complete();
		}
	}

	event void adcReadX.readDone(error_t result, uint16_t val){
        if(result == SUCCESS){
            joyStickXvalue = val;
            XDone = TRUE;
			if (ADone && BDone && CDone 
				&& DDone && EDone && FDone
				&& XDone && YDone) {
				get_value_complete();
			}
        }
    }

	event void adcReadY.readDone(error_t result, uint16_t val){
        if(result == SUCCESS){
            joyStickYvalue = val;
        	YDone = TRUE;
			if (ADone && BDone && CDone 
				&& DDone && EDone && FDone
				&& XDone && YDone) {
				get_value_complete();
			}
        }
    }
}
