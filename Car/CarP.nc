
module CarP {
    provides {
        interface Car;
    }

    uses {
        interface HplMsp430GeneralIO;
        interface HplMsp430Usart;
        interface Resource;
        interface Leds;
    }
}   

implementation {
    uint8_t type;
    uint16_t m_value;
    uint16_t xAngle = 3400;
    uint16_t yAngle = 3400;
    uint16_t initAngle = 3400;
	uint16_t max_speed;
	uint16_t min_speed;
    msp430_uart_union_config_t config = {
		{
			utxe: 1,
			urxe: 1,
			ubr: UBR_1MHZ_115200,
			umctl: UMCTL_1MHZ_115200,
			ssel: 0x02,
			pena: 0,
			pev: 0,
			spb: 0,
			clen: 1,
			listen: 0,
			mm: 0,
			ckpl: 0,
			urxse: 0,
			urxeie: 0,
			urxwie: 0,
			utxe: 1,
			urxe: 1
		}
	};
    
    void send_command() {
        uint8_t i;
        for(i = 0; i < 8; i++) {
            if(i == 0) {
                call HplMsp430Usart.tx(0x1);
            }
            else if(i == 1) {
                call HplMsp430Usart.tx(0x2);
            }
            else if(i == 2) {
                call HplMsp430Usart.tx(type);
            }
            else if(i == 3) {
                call HplMsp430Usart.tx(m_value >> 8);
            }
            else if(i == 4) {
                call HplMsp430Usart.tx(m_value & 0xFF);
            }
            else if(i == 5) {
                call HplMsp430Usart.tx(0xFF);
            }
            else if(i == 6) {
                call HplMsp430Usart.tx(0xFF);
            }
            else if(i == 7) {
                call HplMsp430Usart.tx(0x00);
            }
            while(!call HplMsp430Usart.isTxEmpty()){

            }
        }
        call Resource.release();
    }

    event void Resource.granted() {
        call HplMsp430Usart.setModeUart(&config);
        call HplMsp430Usart.enableUart();
        U0CTL &= ~SYNC;
        // send_command();
    }
    
    command error_t Car.Angle_1(uint16_t value) {
        type = 1;
        if(value == 0) {
            if(xAngle + 300 < 5000) {
                xAngle += 300;
            }
        }
        else if(value == 1) {
            if(xAngle - 300 > 1800) {
                xAngle -= 300;
            }
        }
        else if(value == 2){
            xAngle = initAngle;
        }
        m_value = xAngle;
        // send_command();
        // call Resource.request();
        if(value == 2){
            signal Car.InitAngle_1Done();
        }
    }

    command error_t Car.Angle_2(uint16_t value) {
        type = 7;
        if(value == 0) {
            if(yAngle + 300 < 5000) {
                yAngle += 300;
            }
        }
        else if(value == 1) {
            if(yAngle - 300 < 1800) {
                yAngle -= 300;
            }
        }
        else if(value == 2){
            xAngle = initAngle;
        }
        m_value = yAngle;
        // send_command;
        // call Resource.request();
        if(value == 2){
            signal Car.InitAngle_2Done();
        }
    }


    command error_t Car.Forward(uint16_t value) {
        type = 2;
        m_value = value;
        // send_command();
        // call Resource.request();
    }

    command error_t Car.Back(uint16_t value) {
        type = 3;
        m_value = value;
        // send_command();
        // call Resource.request();
    }

    command error_t Car.Left(uint16_t value) {
        type = 4;
        m_value = value;
        // send_command();
        // call Resource.request();
    }

    command error_t Car.Right(uint16_t value) {
        type = 5;
        m_value = value;
        // send_command();
        // call Resource.request();
    }

    command error_t Car.Pause() {
        type = 6;
        m_value = 0;
        // send_command();
        // call Resource.request();
    }

    command void Car.start() {
  }

    
}