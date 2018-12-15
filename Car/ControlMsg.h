#ifndef CONTROLMSG_H
#define CONTROLMSG_H 

typedef nx_struct ControlMsg {
	nx_uint8_t type;
	nx_uint16_t data;
} ControlMsg;

enum {
	AM_ControlMsg = 6,
    CAR_SPEED = 500,
};

#endif