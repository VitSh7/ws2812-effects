/*
 * sound fft.c
 *
 * Created: 4/24/2020 2:10:02 PM
 * Author : Vitve
 */ 

#define F_CPU 16000000UL
#define F_SCL 100000UL

#define FHT_N 64
#define LOG_OUT 1

#define NOISE_ADD 3

#include <avr/io.h>
#include "user_ADC.h"
#include "FHT.h"
#include "user_UART.h"
#include "spi.h"
#include "user_I2C.h"
#include <avr/interrupt.h>
#include <math.h>

volatile uint8_t count = 2;
volatile uint8_t sound[FHT_N];

volatile uint8_t send_mode = 0;

uint8_t max_fht_noise=0;
uint8_t max_sound_noise=0;
uint8_t current_level=0;
uint8_t sound_mid=0;

volatile uint8_t spectre[FHT_N/2];

volatile char ready=0;

void get_audio()
{
	for(int i=0; i<FHT_N; i++)
	{
		ADC_go();
		sound[i]=ADCH;
		fht_input[i]=sound[i];
	}
}

void get_current_level()
{
	current_level=0;
	uint8_t sound_level=0;
	for (int i=0; i<FHT_N; i++)
	{
		sound_level=abs(sound_mid-sound[i]);
		if(sound_level<max_sound_noise)
				sound_level=0;
		if(sound_level>current_level)
			current_level=sound_level;
	}
}

void do_fht()
{
	fht_window();  // window the data for better frequency response
	fht_reorder(); // reorder the data before doing the fht
	fht_run();     // process the data in the fht
	fht_mag_log(); // take the output of the fht
}


void get_noise()
{
	uint8_t fht_level=0;
	uint8_t sound_level=0; 
	for(int j=0; j<100; j++)
	{
		uint8_t sound_mid_i=0;
		get_audio();
		for (int i=0; i<FHT_N; i++)
		{
			sound_mid_i+=sound[i];
		}
		sound_mid_i=sound_mid_i/FHT_N;
		sound_mid += sound_mid_i;
		for (int i=0; i<FHT_N; i++)
		{
			sound_level=abs(sound_mid_i-sound[i]);
			if(sound_level>max_sound_noise)
				max_sound_noise=sound_level;
		}
		do_fht();
		for (int i=2; i<FHT_N/2; i++)
		{
			fht_level=fht_log_out[i];
			if(fht_level>max_fht_noise)
				max_fht_noise=fht_level;
		}
	}
	sound_mid=sound_mid/100;
	max_sound_noise=max_sound_noise+NOISE_ADD;
	max_fht_noise=max_fht_noise+NOISE_ADD;
}

void filter()
{
	for (int i=2; i<FHT_N/2; i++)
	{
		if(fht_log_out[i]<max_fht_noise)
			spectre[i]=0;
		else
			spectre[i]=fht_log_out[i];
	}
}

int main(void)
{
	PORTC |= ((1<<PINC4) | (1<<PINC5));
	I2C_set_own_SLA(66);
	I2C_init();
	
	ADC_set_ref(AREF);
	ADC_set_mux(ADC0);
	ADC_set_clock(32);//500 kHz adc clock, fd=500/13=38462 Hz
	ADC_adjust(LEFT);//left adjustment - use only ADCH - 8 bit
	ADC_on();

	sei();
	
	UART_init();
	
	get_noise();
    while (1) 
    {
		get_audio();
		get_current_level();
		do_fht();
		filter();
		UART_send(current_level);		
    }
}


ISR(TWI_vect)
{
	//UART_send(TWI_STATUS);
	switch (TWI_STATUS)
	{
		case 0xA8://own SLA+R has been received
			TWDR = spectre[count++];
			TWCR = (1<<TWINT)|(1<<TWEA)|(1<<TWEN)|(1<<TWIE);
			break;
		case 0xB8: //data byte has been transmitted
			if (count==FHT_N/2)
			{
				TWDR = current_level;
				count++;
			}
			else
				TWDR = spectre[count++];
			if(count>FHT_N/2)
			{
				count=2;
				TWCR = (1<<TWINT)|(1<<TWEN)|(1<<TWIE);// transmit last byte 
			}
			else
				TWCR = (1<<TWINT)|(1<<TWEA)|(1<<TWEN)|(1<<TWIE);// transmit next byte
			break;
		case 0xC0:
			TWCR = (1<<TWINT)|(1<<TWEA)|(1<<TWEN)|(1<<TWIE);// wait;
			break;
		default:
			TWCR = (1<<TWINT)|(1<<TWEA)|(1<<TWEN)|(1<<TWIE);// wait;
			break;	
	}
}