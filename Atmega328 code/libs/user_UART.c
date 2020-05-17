#include "user_UART.h"

void UART_init()
{
	UBRR0L = 8;       //low byte UBBR
	UCSR0B |= (1<<TXEN0)|(1<<RXEN0);    //enable transmitter and receiver
	UCSR0C |= (1<<UCSZ00)|(1<< UCSZ01); //8-bit conversation
}

void UART_send(char send_value) {
	while(!( UCSR0A & (1 << UDRE0)));   // wait till buffer is clear
	UDR0 = send_value; // write data in TX buffer
}