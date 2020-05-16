#include "user_ADC.h"

void ADC_set_ref(char ADC_REF)
{
	ADMUX &= ~((1<<REFS0)|(1<<REFS1));
	switch (ADC_REF)
	{
		case AREF: //AREF
			break;
		case AVcc: //AVcc with external capacitor at AREF pin
			ADMUX |= (1<<REFS0);
			break;
		case Vbg: //Internal 1.1 voltage reference with external capacitor at AREF pin
			ADMUX |= (1<<REFS0)|(1<<REFS1);			
	}
}

void ADC_set_mux(char ADC_MUX)
{
	ADMUX &= ~((1<<MUX0)|(1<<MUX1)|(1<<MUX2)|(1<<MUX3));
	switch(ADC_MUX)
	{
		case ADC0: //ADC0
			break;
		case ADC1: //ADC1
		 	ADMUX |= (1<<MUX0);
			 break;
		case ADC2: //ADC2
			ADMUX |= (1<<MUX1);
			break;
		case ADC3: //ADC3
			ADMUX |= (1<<MUX0)|(1<<MUX1);
			break;
		case ADC4: //ADC4
			ADMUX |= (1<<MUX2);
			break;
		case ADC5: //ADC5
			ADMUX |= (1<<MUX0)|(1<<MUX2);
			break;
		case ADC6: //ADC6
			ADMUX |= (1<<MUX1)|(1<<MUX2);
			break;
		case ADC7: //ADC7
			ADMUX |= (1<<MUX0)|(1<<MUX1)|(1<<MUX2);
			break;
		case ADC8: //ADC8
			ADMUX |= (1<<MUX3);
			break;
		case VbgC: //1.1V
			ADMUX |= (1<<MUX1)|(1<<MUX2)|(1<<MUX3);
			break;
		case GND: //0V (GND)
			ADMUX |= (1<<MUX0)|(1<<MUX1)|(1<<MUX2)|(1<<MUX3);
			break;		
	}
}

void ADC_set_clock(char ADC_CLOCK)
{
	ADCSRA &= ~((1<<ADPS0)|(1<<ADPS1)|(1<<ADPS2));
	switch(ADC_CLOCK)
	{
		case 2:
			ADCSRA |= (1<<ADPS0);
			break;
		case 4:
			ADCSRA |= (1<<ADPS1);
			break;
		case 8:
			ADCSRA |= (1<<ADPS0)|(1<<ADPS1);
			break;
		case 16:
			ADCSRA |= (1<<ADPS2);
			break;	
		case 32:
			ADCSRA |= (1<<ADPS0)|(1<<ADPS2);
			break;
		case 64:
			ADCSRA |= (1<<ADPS1)|(1<<ADPS2);
			break;	
		case 128:
			ADCSRA |= (1<<ADPS0)|(1<<ADPS1)|(1<<ADPS2);
			break;
	}
}

void ADC_go()
{
	ADCSRA |= (1<<ADSC); //start conversation
	while((ADCSRA & (1<<ADSC)));//wait for end
}

void ADC_on()
{
	ADCSRA |= (1<<ADEN);//|(1<<ADATE)|(1<<ADIE);//interrupts and trigger enable
}

void ADC_off()
{
	ADCSRA &= ~(1<<ADEN);
}

void ADC_adjust(char adjust)
{
	ADMUX &= ~(1<<ADLAR);
	ADMUX |= (adjust<<ADLAR);
}