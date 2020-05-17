#include "user_I2C.h"

void I2C_init()
{
	//DDRC &= ~((1<<PORTC4)|(1<<PORTC5));
	//PORTC |= (1<<PORTC4)|(1<<PORTC4); //Pull-up resistor on line SCL
	TWBR = TWBR_value;
	TWSR = 0;
	TWCR = (1<<TWINT)|(1<<TWEA)|(1<<TWEN)|(TWI_INTERRUPT<<TWIE); //enable Acknowledge bit and enable TWI module and interrupts
}

void I2C_set_own_SLA(char address)
{
	TWAR=(address<<1);
}

void I2C_start() // to work it needs sei();
{
	TWCR = (1<<TWSTA)|(1<<TWINT)|(1<<TWEN)|(TWI_INTERRUPT<<TWIE);
	if(TWI_INTERRUPT==0)
		while (!(TWCR & (1<<TWINT)));
}

void I2C_stop()
{
	TWCR |= (1<<TWSTO)|(1<<TWINT);
	if(TWI_INTERRUPT==0)
	while (!(TWCR & (1<<TWINT)));
	//TWCR &=(1<<TWEN);
}

void I2C_send(char byte)
{
	TWDR = byte;
	TWCR = (1<<TWINT)|(1<<TWEN)|(TWI_INTERRUPT<<TWIE);// start sending
	if(TWI_INTERRUPT==0)
		while (!(TWCR & (1<<TWINT)));
}

void I2C_send_address(char address)
{
	TWDR = (address<<1); //send SLA+W (W=0)
	TWCR = (1<<TWINT)|(1<<TWEN)|(0<<TWSTA)|(TWI_INTERRUPT<<TWIE); // start sending
	if(TWI_INTERRUPT==0)
		while (!(TWCR & (1<<TWINT)));
}

void I2C_quit()
{
	TWCR = 0;
}

void I2C_send_array(char data[], int *count_bytes, int size, int pause) //use this function in ISR(TWI_VECT), i is used for counting bytes in array, must be defined as 0 as global variable
{
	//_delay_us(pause);
	switch(TWI_STATUS)
	{
		case 0x08: //A START condition has been transmitted
			I2C_send_address(SLA); //transmit address
			break;
		case 0x18: //SLA+W has been transmitted, ACK has been received
			I2C_send(data[*count_bytes]);//transmit data
			(*count_bytes)++;
			break;
		case 0x20: //SLA+W has been transmitted,NOT ACK has been received
			I2C_send(data[*count_bytes]);//transmit data
			(*count_bytes)++;
			break;
		case 0x28: //data has been transmitted, ACK has been received
			if((*count_bytes)<size)
			{
				I2C_send(data[*count_bytes]);//transmit data
				(*count_bytes)++;
			}
			else
			{
				I2C_stop();//STOP CONDITION
				(*count_bytes)=0;
			}
			break;
		case 0x30: //data has been transmitted,NOT ACK has been received
			if((*count_bytes)<size)
			{
				I2C_send(data[*count_bytes]);//transmit data
				(*count_bytes)++;
			}
			else
			{
				I2C_stop();//STOP CONDITION
				(*count_bytes)=0;
			}
			break;
		default:
			I2C_quit();
	}
}