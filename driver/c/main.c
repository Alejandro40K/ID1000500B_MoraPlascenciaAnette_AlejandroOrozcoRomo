#include <stdio.h>
#include <stdlib.h>
#include "id1000500b.h"

#define PORT "/dev/ttyACM0"
#define ADDR_CONFIG "/home/anette/intelFPGA_lite/22.1std/quartus/HDL/ID1000500B/ID1000500B_config.csv"

int main() 
{
    uint16_t golden[64] = {0xFFFF, 0xFFF7, 0x0017, 0x0044, 0x003C, 0X006C, 0x0006, 0xFFE2, 0x007A, 0x0035, 0xFFF4, 0xFFF8, 0xFFFE, 0xFFFF};  
    uint8_t nic_addr  = 1;
    uint8_t port = 0;
    uint8_t sizeY= 0x05;
    uint16_t dataZ[64] = {0};
    uint8_t dataY[32]={0x01, 0x0B, 0x04, 0xFE, 0xFF};

    //INIT
    id1000500b_init(PORT, nic_addr, port, ADDR_CONFIG);
    id1000500b_status();
    
    //CONVOLUTION
    conv(dataY, sizeY, dataZ); 

    id1000500b_status();
    id1000500b_clearIntDone(); 

    printf("\n\n");

    //GOLDEN MODEL VS CONVOLUTION DRIVER
    for(uint32_t i=0; i<14; i++){
        printf("Golden: %08X \t | Driver: %08X \t %s \n", golden[i], dataZ[i], (golden[i]==dataZ[i])?"YES":"NO" );
    }

    id1000500b_status();
    id1000500b_finish();

    printf("\n\n");
    return 0;

}
