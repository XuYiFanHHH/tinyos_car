#ifndef CONTROLMSG_H
#define CONTROLMSG_H 

typedef nx_struct ControlMsg {
	nx_uint8_t type;
	nx_uint16_t data;
} ControlMsg;

enum {
	AM_ControlMsg = 6,
    MIN_JOYSTICK = 1000,
    MAX_JOYSTICK = 4000,
    TIMER_PERIOD_MILLI = 100,
    CAR_SPEED = 500,
};

#endif