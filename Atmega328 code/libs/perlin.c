#include "perlin.h"


uint8_t ease8InOutQuad( uint8_t i)
{
    uint8_t j = i;
    if( j & 0x80 ) {
	    j = 255 - j;
    }
    uint8_t jj  = scale8(  j, j);
    uint8_t jj2 = jj << 1;
    if( i & 0x80 ) {
	    jj2 = 255 - jj2;
    }
    return jj2;	
}

int8_t inoise8_raw(uint16_t x, uint16_t y)
{
	// Find the unit cube containing the point
	  uint8_t X = x>>8;
	  uint8_t Y = y>>8;

	  // Hash cube corner coordinates
	  uint8_t A = P(X)+Y;
	  uint8_t AA = P(A);
	  uint8_t AB = P(A+1);
	  uint8_t B = P(X+1)+Y;
	  uint8_t BA = P(B);
	  uint8_t BB = P(B+1);

	  // Get the relative position of the point in the cube
	  uint8_t u = x;
	  uint8_t v = y;

	  // Get a signed version of the above for the grad function
	  int8_t xx = ((uint8_t)(x)>>1) & 0x7F;
	  int8_t yy = ((uint8_t)(y)>>1) & 0x7F;
	  uint8_t N = 0x80;

	  u = ease8InOutQuad(u); v = ease8InOutQuad(v);
  
	  int8_t X1 = lerp7by8(grad8(P(AA), xx, yy), grad8(P(BA), xx - N, yy), u);
	  int8_t X2 = lerp7by8(grad8(P(AB), xx, yy-N), grad8(P(BB), xx - N, yy - N), u);

	  int8_t ans = lerp7by8(X1,X2,v);

	  return ans;	
}

uint8_t inoise8(uint16_t x, uint16_t y) 
{
	int8_t n = inoise8_raw( x, y);  // -64..+64
	n+= 64;                         //   0..128
	uint8_t ans = qadd8( n, n);     //   0..255
	return ans;
}