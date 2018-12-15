interface Car {
    command void start();
    command error_t Angle_1(uint16_t value);
    command error_t Angle_2(uint16_t value);
    command error_t Forward(uint16_t value);
    command error_t Back(uint16_t value);
    command error_t Left(uint16_t value);
    command error_t Right(uint16_t value);
    command error_t Pause();
	// command error_t InitAngle(uint16_t value);
}