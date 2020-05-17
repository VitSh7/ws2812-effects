#ifndef user_I2C_H
#define user_I2C_H

#include <avr/io.h>

#ifndef F_CPU
/* prevent compiler error by supplying a default */
#warning "F_CPU not defined for user_I2C.h"
#define F_CPU 16000000UL
#endif

#ifndef F_SCL
/* prevent compiler error by supplying a default */
# warning "F_SCL not defined for user_I2C.h"
# define F_SCL 100000UL
#endif

#define TWBR_value (((F_CPU/F_SCL)-16)/2)
#define TWI_STATUS TWSR&(~((1<<TWPS1)|(1<<TWPS0)))
#define TWI_INTERRUPT 1// 1 - interrupts enable, 0 interrupts disable
#define SLA 0x2B

void I2C_init();

void I2C_start();
void I2C_stop();
void I2C_send(char byte);
void I2C_send_address(char address);
void I2C_quit();
void I2C_send_array(char data[], int *count_bytes, int size, int pause);
void I2C_set_own_SLA(char address);

#endif