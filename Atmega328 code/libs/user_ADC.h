#ifndef _user_ADC_h // include guard
#define _user_ADC_h

#include <avr/io.h>

/*
Function ADC_set_ref sets reference voltage for ADC, parameter ADC_REF defines which source to use:
0 - AREF;
1 - AVcc with external capacitor at AREF pin;
2 - Internal 1.1 voltage reference with external capacitor at AREF pin;
*/
#define AREF 0
#define AVcc 1
#define Vbg  2

void ADC_set_ref(char ADC_REF);

/*
Function ADC_set_MUX sets input channel for ADC, parameter ADC_MUX defines which channel to select:
0 - ADC0;
1 - ADC1;
2 - ADC2;
3 - ADC3;
4 - ADC4;
5 - ADC5;
6 - ADC6;
7 - ADC7;
8 - ADC8 (for internal temperature sensor);
9 - 1.1V;
10 - 0V; 
*/
#define ADC0 0
#define ADC1 1
#define ADC2 2
#define ADC3 3
#define ADC4 4
#define ADC5 5
#define ADC6 6
#define ADC7 7
#define ADC8 8
#define VbgC 9
#define GND 10

void ADC_set_mux(char ADC_MUX);

/*
Function ADC_set_clock sets prescaler for ADC_clock, parameter ADC_CLOCK defines which prescaler to select, available prescalers:
2
4
8
16
32
64
128
*/
void ADC_set_clock(char ADC_CLOCK);

/*
Function ADC_go starts the conversation and waits for end of conversation.
*/
void ADC_go();

/*
Enable ADC module.
*/
void ADC_on();

/*
Disable ADC module.
*/
void ADC_off();

/*
Set adjust left or right
1 - left
0 - right
*/

#define RIGHT 0
#define LEFT 1

void ADC_adjust(char adjust);

#endif