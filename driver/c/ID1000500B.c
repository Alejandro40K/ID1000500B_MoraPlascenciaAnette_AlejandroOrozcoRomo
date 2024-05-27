#include "id00001001.h"
#include "caip.h"
#include <stdio.h>
#include <stdbool.h>

#ifdef _WIN32
#include <windows.h>
#else
#include <unistd.h>
#endif // _WIN32

//Defines
#define INT_DONE    0
#define ONE_FLIT    1
#define ZERO_OFFSET 0
#define STATUS_BITS 8
#define INT_DONE_BIT    0x00000001


/** Global variables declaration (private) */
caip_t      *ID1000500B_aip;
uint32_t    ID1000500B_id = 0;
/*********************************************************************/

/** Private functions declaration */
static uint32_t ID1000500B_getID(uint32_t* id);
static uint32_t ID1000500B_clearStatus(void);
/*********************************************************************/

/** Global variables declaration (public)*/

/*********************************************************************/

/**Functions*/

/* Driver initialization*/
int32_t ID1000500B_init(const char *connector, uint8_t nic_addr, uint8_t port, const char *csv_file)
{
    ID1000500B_aip = caip_init(connector, nic_addr, port, csv_file);

    if(ID1000500B_aip == NULL){
        printf("CAIP Object not created");
        return -1;
    }
    ID1000500B_aip->reset();

    ID1000500B_getID(&ID1000500B_id);
    ID1000500B_clearStatus();

    printf("\nIP Dummy controller created with IP ID: %08X\n\n", ID1000500B_id);
    return 0;
}

/* Write data*/
int32_t ID1000500B_writeData(uint32_t *data, uint32_t data_size)
{
    ID1000500B_aip->writeMem("MDATAIN", data, data_size, ZERO_OFFSET);
    return 0;
}

/* Read data*/
int32_t ID1000500B_readData(uint32_t *data, uint32_t data_size)
{
    ID1000500B_aip->readMem("MDATAOUT", data, data_size, ZERO_OFFSET);
    return 0;
}

/* Start processing*/
int32_t ID1000500B_startIP(void)
{
    ID1000500B_aip->start();
    return 0;
}

/* Enable delay*/
int32_t ID1000500B_enableDelay(uint32_t msec)
{
    uint32_t time_delay[] = {msec*2 + 1};
    ID1000500B_aip->writeConfReg("CDELAY", time_delay, ONE_FLIT, ZERO_OFFSET);
    return 0;
}

/* Disable delay*/

int32_t ID1000500B_disableDelay(void)
{
    uint32_t zeros[ONE_FLIT] = {0};
    ID1000500B_aip->writeConfReg("CDELAY", zeros, ONE_FLIT, ZERO_OFFSET);
    return 0;
}


/* Enable interruption notification "Done"*/
int32_t ID1000500B_enableINT(void)
{
    ID1000500B_aip->enableINT(INT_DONE, NULL);
    printf("\nINT Done enabled");
    return 0;
}

/* Disable interruption notification "Done"*/
int32_t ID1000500B_disableINT(void)
{
    ID1000500B_aip->disableINT(INT_DONE);
    printf("\nINT Done disabled");
    return 0;
}

/* Show status*/
int32_t ID1000500B_status(void)
{
    uint32_t status;
    ID1000500B_aip->getStatus(&status);
    printf("\nStatus: %08X",status);
    return 0;
}

/* Wait interruption*/
int32_t ID1000500B_waitINT(void)
{
    bool waiting = true;
    uint32_t status;

    while(waiting)
    {
        ID1000500B_aip->getStatus(&status);

        if((status & INT_DONE_BIT)>0)
            waiting = false;

        #ifdef _WIN32
        Sleep(500); // ms
        #else
        sleep(0.1); // segs
        #endif
    }

    ID1000500B_aip->clearINT(INT_DONE);

    return 0;
}

/* Finish*/
int32_t ID1000500B_finish(void)
{
    ID1000500B_aip->finish();
    return 0;
}

//PRIVATE FUNCTIONS
uint32_t ID1000500B_getID(uint32_t* id)
{
    ID1000500B_aip->getID(id);

    return 0;
}

uint32_t ID1000500B_clearStatus(void)
{
    for(uint8_t i = 0; i < STATUS_BITS; i++)
        ID1000500B_aip->clearINT(i);

    return 0;
}
/*
int32_t conv(uint8_t *X, uint8_t sizeX, uint16_t *result)
{
    // Escribir datos de entrada en la memoria MMEM_Y_IN
    ID1000500B_writeData();
    // Escribir tamaño de datos de entrada en el registro de configuración CREG_CONF_SIZEY
    ID1000500B_SizeY_config();
    // Iniciar procesamiento
    ID1000500B_startIP();
    // Esperar a que se complete el procesamiento
    int32_t wait_result = ID1000500B_waitINT();
    if (wait_result != 0) {
        printf("Error esperando a la interrupción\n");
        return wait_result;
    }
    // Verificar el estado después de que se completa el procesamiento
    ID1000500B_status();
    // Leer datos de salida de la memoria MMEM_Z_OUT
    ID1000500B_readData(result, 64);
    return 0;
}*/

int32_t conv(uint8_t *X, uint8_t sizeX, uint16_t *result)
{
    // Imprimir el contenido de los datos de entrada
    printf("Data de entrada: [");
    for (int i = 0; i < sizeX; i++) {
        printf("%02X ", X[i]);
        if (i != sizeX - 1) {
            printf(", ");
        }
    }
    printf("]\n");

    // Escribir datos de entrada en la memoria MMEM_Y_IN
    ID1000500B_writeData(X, sizeX);

    // Imprimir el tamaño de los datos de entrada
    printf("Tamaño de los datos de entrada: %d\n", sizeX);

    // Escribir tamaño de datos de entrada en el registro de configuración CREG_CONF_SIZEY
    ID1000500B_SizeY_config(sizeX);

    // Iniciar procesamiento
    ID1000500B_startIP();

    // Esperar a que se complete el procesamiento
    int32_t wait_result = ID1000500B_waitINT();
    if (wait_result != 0) {
        printf("Error esperando a la interrupción\n");
        return wait_result;
    }

    // Verificar el estado después de que se completa el procesamiento
    ID1000500B_status();

    // Leer datos de salida de la memoria MMEM_Z_OUT
    ID1000500B_readData(result, 64);

    return 0;
}

