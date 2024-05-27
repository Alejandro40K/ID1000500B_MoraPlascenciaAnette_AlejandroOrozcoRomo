#ifndef __ID1000500B_H__
#define __ID1000500B_H__

#include <stdint.h>

/** Global variables declaration (public) */
/* These variables must be declared "extern" to avoid repetitions. They are defined in the .c file*/
/******************************************/

/** Public functions declaration */

/* Driver initialization   //prefigio del id que tenemos| parametros puertos usb bridge| | |ruta csv OJO, Mismas en python                                                             */
int32_t ID1000500B_init(const char *connector, uint8_t nic_addr, uint8_t port, const char *csv_file);

/* Write data, pasamos el puntero delarray de datos | tamaño de esos datos */
int32_t ID1000500B_writeData(uint32_t *data, uint32_t data_size);

/* Read data*/
int32_t ID1000500B_readData(uint32_t *data, uint32_t data_size);

/* Start processing*/
int32_t ID1000500B_startIP(void);

/* Enable delay*/
int32_t ID1000500B_enableDelay(uint32_t msec);

/* Disable delay*/
int32_t ID1000500B_disableDelay(void);

/* Enable interruption notification "Done"*/
int32_t ID1000500B_enableINT(void);

/* Disable interruption notification "Done"*/
int32_t ID1000500B_disableINT(void);

/* Show status*/
int32_t ID1000500B_status(void);

/* Wait interruption*/
int32_t ID1000500B_waitINT(void);

/* Finish*/
int32_t ID1000500B_finish(void);

int32_t conv(uint8_t *X, uint8_t sizeX, uint16_t *result);

#endif // __ID1000500B_H__




