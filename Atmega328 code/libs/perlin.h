#ifndef __PERLIN
#define __PERLIN

#include <avr/io.h>

#define P(x) p[x]

static uint8_t const p[] = { 151,160,137,91,90,15,
	131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
	190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
	88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
	77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
	102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
	135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
	5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
	223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
	129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
	251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
	49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
	138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180,151
};

inline uint8_t qadd8( uint8_t i, uint8_t j)
{
	unsigned int t = i + j;
	if( t > 255) t = 255;
	return t;
}
inline int8_t avg7( int8_t i, int8_t j)
{
	return ((i + j) >> 1) + (i & 0x1);
}

inline uint8_t scale8( uint8_t i, uint8_t scale)
{
	return i*(scale/256);
}

inline int8_t grad8(uint8_t hash, int8_t x, int8_t y)
{
	int8_t u,v;
	if( hash & 4)
	{
		u = y; v = x;
	}
	else
	{
		u = x; v = y;
	}

	if(hash&1) { u = -u; }
	if(hash&2) { v = -v; }

	return avg7(u,v);
}

inline int8_t lerp7by8( int8_t a, int8_t b, uint8_t frac)
{
	int8_t result;
	if( b > a) {
		uint8_t delta = b - a;
		uint8_t scaled = scale8( delta, frac);
		result = a + scaled;
		} else {
		uint8_t delta = a - b;
		uint8_t scaled = scale8( delta, frac);
		result = a - scaled;
	}
	return result;
}
uint8_t ease8InOutQuad( uint8_t i);
int8_t inoise8_raw(uint16_t x, uint16_t y);
uint8_t inoise8(uint16_t x, uint16_t y);
uint8_t ease8InOutQuad( uint8_t i);

#endif