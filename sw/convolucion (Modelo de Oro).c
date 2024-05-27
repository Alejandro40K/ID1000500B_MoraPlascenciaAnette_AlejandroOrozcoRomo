#include <stdio.h>

int main (){
    int sizeY_temp = 3;
    int sizeH_temp = 6;
    int dataZ_temp;
    int memH_addr, memY_addr, memZ_addr;
    int k;
    int dataH, dataY, dataZ;
    int memory_H[] = {5, 3, 1, 0, 2, 6};
    int memory_Y[] = {-1, 0, 1};

    int busy = 1;
    int done = 0;
    int writeZ = 0;
    printf("Busy: %i\n", busy);
    int tam_conv = sizeH_temp + sizeY_temp - 1;

    for(int i = 0; i < tam_conv; i++){
        dataZ_temp = 0;
        for(int j = 0; j < sizeY_temp; j++){
            if(((i - j) >= 0) && ((i - j) < sizeH_temp)){
                memH_addr = i - j;
                memY_addr = j;
                dataH = memory_H[memH_addr];
                dataY = memory_Y[memY_addr];
                int mult_temp = dataH*dataY;
                dataZ_temp = dataZ_temp + (mult_temp);
            }
        }
        memZ_addr = i;
        dataZ = dataZ_temp;
        writeZ = 1;
        printf("writeZ: %i, dataZ: %i, memZ_addr: %i \n", writeZ, dataZ, memZ_addr);
        writeZ = 0;
    }
    busy = 0;
    done = 1;
    printf("Busy: %i\n", busy);
    printf("done: %i\n", done);
    done = 0;

    return 0;
}
