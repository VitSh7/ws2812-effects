/*
 * spi.h
 *
 * Created: 4/28/2020 9:00:59 PM
 *  Author: Vitve
 */ 


#ifndef SPI_H_
#define SPI_H_

#include <avr/io.h>

extern void spi_init();
extern void spi_transfer_sync (uint8_t * dataout, uint8_t * datain, uint8_t len);
extern void spi_transmit_sync (uint8_t * dataout, uint8_t len);
extern uint8_t spi_fast_shift (uint8_t data);


#endif /* SPI_H_ */