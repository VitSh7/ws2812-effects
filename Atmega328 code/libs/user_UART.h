
#define F_CPU 16000000UL
#define BAUD 115200L									// Baud Rate
#define UBRRL_value (F_CPU/(BAUD*16))-1				//UBRR value

#include <avr/io.h>

void UART_init();
void UART_send(char send_value);