#include "caip.h"  // Se incluye la biblioteca caip.h
#include "ID1000500B.h"
#include <stdint.h>
#include <stdio.h>
#include <conio.h> // Se incluye la biblioteca conio.h

int main(){
    //const char *connector = "/dev/ttyACM0";
	//const char *csv_file = "/home/anette/intelFPGA_lite/22.1std/quartus/HDL/ID1000500B/ID1000500B_config.csv";

    uint8_t nic_addr = 1;
    uint8_t port = 0;
	ID1000500B_init("/dev/ttyACM0",nic_addr, port, "/home/anette/intelFPGA_lite/22.1std/quartus/HDL/ID1000500B/ID1000500B_config.csv");
    //caip_t *aip = caip_init(connector, nic_addr, port, csv_file);

    uint32_t ID[1];
    uint32_t STATUS[1];

    ID1000500B_status(STATUS);
    printf("Read STATUS: %08X\n\n", STATUS[0]);

    uint32_t sizeY[1] = {0x00000005};
    uint32_t sizeY_size = sizeof(sizeY) / sizeof(uint32_t);

    /*printf("Write configuration register: CONFIG_REGISTER\n");
    aip->writeConfReg("CONFIG_REGISTER", sizeY, 1, 0);
    printf("sizeY Data: [");
    for(int i=0; i<sizeY_size; i++){
        printf("0x%08X", sizeY[i]);
        if(i != sizeY_size-1){
            printf(", ");
        }
    }
    printf("]\n\n");*/
    
    uint32_t dataY[5] =    {0x00000001, 0x0000000B, 0x00000004, 0x000000FE, 0x000000FF};
    uint32_t dataY_size = sizeof(dataY) / sizeof(uint32_t);
	uint32_t modeloOro[] = {0x0000001B, 0x000000A3, 0x000000F5, 0x00000160, 0x0000022F, 0x000002CE, 0x0000032B, 0x000003B1, 0x00000411, 0x0000044B, 0x000003B4, 0x000002A8, 0x000001E0, 0x000000C8};
    //Escrbir datos en memoria
    printf("Write memory: MEMORY_Y\n");
    ID1000500B_writeData("MEMORY_Y", dataY, 5, 0);
    printf("dataY Data: [");
    for(int i=0; i<dataY_size; i++){
        printf("0x%08X", dataY[i]);
        if(i != dataY_size-1){
            printf(", ");
        }
    }
    printf("]\n\n");
    printf("Start IP\n\n");
    ID1000500B_enableDelay(2000);
    //start
    ID1000500B_startIP();
    //Esperar la interrupcion
    ID1000500B_waitINT();

    uint32_t dataZ[14];
    uint32_t dataZ_size = sizeof(dataZ) / sizeof(uint32_t);

    //leer la memoria de salida
    printf("Read memory: MEMORY_Z\n");
    ID1000500B_readData("MEMORY_Z", dataZ, 14, 0);
    printf("dataZ Data: [");
    for(int i=0; i<dataZ_size; i++){
        printf("0x%08X", dataZ[i]);
        if(i != dataZ_size-1){
            printf(", ");
        }
    }
    printf("]\n\n");

    //obtener status
    ID1000500B_status(STATUS);
    printf("Read STATUS: %08X\n\n", STATUS[0]);

    //imprimir el resultado 
    uint16_t dataZ[dataY_size];
    conv(dataY, dataY_size, dataZ);

    // Comparación de resultados
    for (uint32_t i = 0; i < dataY_size; i++) {
        printf("TX: %08X \t | RX: %08X \t %s \n", modeloOro[i], dataZ[i], (modeloOro[i] == dataZ[i]) ? "YES" : "NO");
    }


	ID1000500B_disableDelay();
	ID1000500B_status();
    ID1000500B_finish();

    printf("\n\nPress key to close ... ");
    getch();

    return 0;

}
