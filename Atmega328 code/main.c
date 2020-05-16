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

#include <avr/io.h>
#include "user_ADC.h"
#include "FHT.h"
#include "user_UART.h"
#include "spi.h"
#include "user_I2C.h"
#include "perlin.h"
#include <avr/interrupt.h>
#include <math.h>

#define NOISE_ADD 3

//defines for colormusic
#define averK 0.01
#define MAX_K 1.8
#define SMOOTH 0.1
#define EXP	1.4


#define MAX_K_FREQ 1.2
#define SMOOTH_STEP 10

#define MONO 0 //if mono==1 then do onlu left channel

volatile uint8_t count = 0;
volatile uint8_t L_sound[FHT_N];
volatile uint8_t R_sound[FHT_N];

uint8_t max_fht_noise=0;
uint8_t max_sound_noise=0;
uint8_t L_current_level=0;
uint8_t R_current_level=0;
uint8_t sound_mid=0;

uint8_t mode=19;
uint8_t channel_average=1;

uint8_t NumberOfLeds=117;
uint8_t MAX_CH=58;

uint8_t noise_value[300];
#define NOISE_STEP 15
int counter = 0;

float R_soundLevel=0;
float R_soundLevel_f=0;
float L_soundLevel=0;
float L_soundLevel_f=0;
float averageLevel=0;
uint8_t Rlenght=0;
uint8_t Llenght=0;
int maxLevel=0; 

volatile uint8_t spectre[FHT_N/2-2];

float band_f[3];
float band_aver[3];
int band_bright[3];
float freq_max_f=0;

volatile char ready=0;

volatile char bytes_received=0;
volatile char next_byte_is=0; //1 - mode, 2 - Number_of_leds
volatile char go=0;

char setting_noise=1;

int _map(int x, int in_min, int in_max, int out_min, int out_max)
{
	return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}

int _constrain(int x, int min, int max)
{
	if(x<min) return min;
	else if(x>max) return max;
	else return x;
}


void get_audio()
{
	if (mode==0)
	{
		ADC_set_mux(ADC0);
		for(int i=0; i<FHT_N; i++)
		{
			ADC_go();
			L_sound[i]=ADCH;
		}
		
		if (MONO==0)
		{
			ADC_set_mux(ADC1);
			for(int i=0; i<FHT_N; i++)
			{
				ADC_go();
				R_sound[i]=ADCH;
			}
		}
	}
	else
	{
		ADC_set_mux(ADC3);
		for(int i=0; i<FHT_N; i++)
		{
			ADC_go();
			fht_input[i]=ADCH;
		}
	}
}

void get_current_level()
{
	L_current_level=0;
	R_current_level=0;
	
	uint8_t L_sound_level=0;
	uint8_t R_sound_level=0;
	for (int i=0; i<FHT_N; i++)
	{
		//sound_level=abs(sound_mid-sound[i]);
		L_sound_level=L_sound[i];
		if(L_sound_level<max_sound_noise)
			L_sound_level=0;
		if(L_sound_level>L_current_level)
			L_current_level=L_sound_level;
		if (MONO==0)
		{
			R_sound_level=R_sound[i];
			if(R_sound_level<max_sound_noise)
				R_sound_level=0;
			if(R_sound_level>R_current_level)
				R_current_level=R_sound_level;	
		}
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
		//uint8_t sound_mid_i=0;
		//get_audio();
		/*
		for (int i=0; i<FHT_N; i++)
		{
			sound_mid_i+=sound[i];
		}
		
		sound_mid_i=sound_mid_i/FHT_N;
		sound_mid += sound_mid_i;
		*/
		ADC_set_mux(ADC0);
		for(int i=0; i<FHT_N; i++)
		{
			ADC_go();
			L_sound[i]=ADCH;
		}
		
		ADC_set_mux(ADC3);
		for(int i=0; i<FHT_N; i++)
		{
			ADC_go();
			fht_input[i]=ADCH;
		}
		
		for (int i=0; i<FHT_N; i++)
		{
			//sound_level=abs(sound_mid_i-sound[i]);
			if(L_sound[i]>max_sound_noise)
				max_sound_noise=L_sound[i];
		}
		do_fht();
		for (int i=2; i<FHT_N/2; i++)
		{
			fht_level=fht_log_out[i];
			if(fht_level>max_fht_noise)
				max_fht_noise=fht_level;
		}
	}
	//sound_mid=sound_mid/100;
	max_sound_noise=max_sound_noise+NOISE_ADD;
	max_fht_noise=max_fht_noise+NOISE_ADD;
	setting_noise=0;
}

void filter()
{
	for (int i=2; i<FHT_N/2; i++)
	{
		if(fht_log_out[i]<max_fht_noise)
			spectre[i-2]=0;
		else
			spectre[i-2]=fht_log_out[i];
	}
}

void level_filter()
{
	if (channel_average==1)
	{
		int average = (L_current_level+R_current_level)/2;
		L_current_level=average;
		R_current_level=average;
	}
	
	L_soundLevel=powf(L_current_level, EXP);	
	L_soundLevel_f=L_soundLevel*SMOOTH + L_soundLevel_f*(1-SMOOTH);
	
	if (MONO==0)
	{
		R_soundLevel=powf(R_current_level, EXP);
		R_soundLevel_f=R_soundLevel*SMOOTH + R_soundLevel_f*(1-SMOOTH);
	}
	else
		R_soundLevel_f=L_soundLevel_f;
		
	
	if ((R_soundLevel_f>3)&&(L_soundLevel_f>3))
	{
		averageLevel=((L_soundLevel_f+R_soundLevel_f)/2)*averK+averageLevel*(1-averK);
		maxLevel=averageLevel*MAX_K;
		Rlenght = _map(R_soundLevel_f, 0, maxLevel, 0, MAX_CH);
		Llenght = _map(L_soundLevel_f, 0, maxLevel, 0, MAX_CH);
		Rlenght = _constrain(Rlenght, 0, MAX_CH);
		Llenght = _constrain(Llenght, 0, MAX_CH);
	}
	else
	{
		Rlenght = 0;
		Llenght = 0;
	}
}

void band_filter()
{
	uint8_t band[3];
	band[0]=0;
	band[1]=0;
	band[2]=0;
	for (int i=0; i<3; i++)
	{
		if (spectre[i]>band[0]) band[0]=spectre[i];
	}
	for (int i=3; i<7; i++)
	{
		if (spectre[i]>band[1]) band[1]=spectre[i];
	}
	for (int i=8; i<(FHT_N/2-2); i++)
	{
		if (spectre[i]>band[2]) band[2]=spectre[i];
	}
	uint8_t freq_max=5;
	for (int i=0; i<3; i++)
	{
		if (band[i]>freq_max) freq_max=band[i];
	}
	freq_max_f=freq_max*averK+freq_max_f*(1-averK);
	
	for (int i=0; i<3; i++)
	{
		band_aver[i]=band[i]*averK+band_aver[i]*(1-averK);
		band_f[i]=band[i]*SMOOTH+band_f[i]*(1-SMOOTH);
		if (band_f[i]>(band_aver[i]*MAX_K_FREQ))
			band_bright[i]=255;
		else
		{
			if (band_bright[i]>0)
				band_bright[i]=band_bright[i]-SMOOTH_STEP;
			if (band_bright[i]<0)
			{
				band_bright[i]=0;
			}
		} 
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
		switch (mode)
		{
			case 0:
				if(go==1)
				{
					get_audio();
					get_current_level();
					level_filter();
					go=0;
				}
				break;
			case 1:
				if(go==1)
				{
					get_audio();
					do_fht();
					filter();
					band_filter();
					go=0;
				}
				break;
			case 19:
				if(go==1)
				{
					for (int i=0; i<NumberOfLeds; i++)
					{
						noise_value[i]=inoise8(i*NOISE_STEP, counter);
					}
					counter+=20;
					go=0;
				}
				break;
			
		}
		
		//get_audio();
		//get_current_level();
		//do_fht();
		//filter();		
    }
}


ISR(TWI_vect)
{
	//UART_send(TWI_STATUS);
	switch (TWI_STATUS)
	{
		case 0xA8://own SLA+R has been received
			count=0;
			if(mode==1)
				TWDR = band_bright[count++];
			if(mode==0)
				TWDR = Llenght;
			if (mode==19)
				TWDR = noise_value[count++];
			TWCR = (1<<TWINT)|(1<<TWEA)|(1<<TWEN)|(1<<TWIE);
			break;
		case 0xB8: //data byte has been transmitted
			if (mode==1)
			{
				TWDR = band_bright[count++];
				if(count==3)
				{
					count=0;
					go=1;
					TWCR = (1<<TWINT)|(1<<TWEN)|(1<<TWIE);// transmit last byte 
				}
				else
					TWCR = (1<<TWINT)|(1<<TWEA)|(1<<TWEN)|(1<<TWIE);// transmit next byte
			}
			else if (mode==0)
			{
				TWDR = Rlenght;
				go=1;
				TWCR = (1<<TWINT)|(1<<TWEN)|(1<<TWIE);// transmit last byte 	
			}
			else
			{
				TWDR = noise_value[count++];
				if(count==NumberOfLeds)
				{
					count=0;
					go=1;
					TWCR = (1<<TWINT)|(1<<TWEN)|(1<<TWIE);// transmit last byte 
				}
				else
					TWCR = (1<<TWINT)|(1<<TWEA)|(1<<TWEN)|(1<<TWIE);// transmit next byte
			}
			break;
		case 0xC0:
			TWCR = (1<<TWINT)|(1<<TWEA)|(1<<TWEN)|(1<<TWIE);// wait;
			break;
		case 0x60://own SLA+W has been received
			TWCR = (1<<TWINT)|(1<<TWEA)|(1<<TWEN)|(1<<TWIE);
			bytes_received=0;
			break;
		case 0x80://data has been received
			bytes_received++;
			if(bytes_received==1)
			{
				next_byte_is=TWDR;
				TWCR = (1<<TWINT)|(1<<TWEA)|(1<<TWEN)|(1<<TWIE);
			}
			else if(bytes_received==2)
			{
				if (next_byte_is==1)
					mode=TWDR;
				else if (next_byte_is==2)
				{
					NumberOfLeds=TWDR;
					MAX_CH=NumberOfLeds/2;
				}
				TWCR = (1<<TWINT)|(1<<TWEN)|(1<<TWIE);
			}
			break;
		case 0x88:
			TWCR = (1<<TWINT)|(1<<TWEA)|(1<<TWEN)|(1<<TWIE);// wait;
			break;
		default:
			TWCR = (1<<TWINT)|(1<<TWEA)|(1<<TWEN)|(1<<TWIE);// wait;
			break;	
	}
}