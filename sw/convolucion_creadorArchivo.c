#include <stdio.h>
#include <stdlib.h>

#define NOMBRE_ARCHIVO_H "MemH.txt"
#define NOMBRE_ARCHIVO_Y "MemY.txt"
#define NOMBRE_ARCHIVO_Y_IPDI "MemY.ipd"
#define NOMBRE_ARCHIVO_Z "MemZ.txt"

int main(){
    FILE* archivoH;
    FILE* archivoY;
    FILE* archivoZ;
    FILE* archivoY_IPD;
    int sizeY_temp = 5; //TOTAL DATOS EN Y
    int sizeH_temp = 10; //TOTAL DATOS H

    srand(time(0));

    //CREACION DE ARCHIVO DE MEMORIA Y

    archivoY = fopen(NOMBRE_ARCHIVO_Y, "w");

    if (archivoY == NULL) {
        printf("Error al abrir el archivo.");
        return 1;
    }

    int numerosY[sizeY_temp];
    printf("sizeY_temp: %i\n", sizeY_temp);

    printf("Y = [");
    for (int i = 0; i < sizeY_temp - 1; i++){
        int numero = rand() % (256 * 2) - 128;
        printf(" %02X ", numero & 0xFF);
        fprintf(archivoY, "%02X\n", numero & 0xFF);
        numerosY[i] = numero;
    }
    int numero = rand() % (256 * 2) - 128;
    fprintf(archivoY, "%02X", numero & 0xFF);
    printf(" %02X ", numero & 0xFF);
    numerosY[sizeY_temp-1] = numero;
    printf("]\n\n");
    fclose(archivoY);

    //CREACION DE ARCHIVO DE MEMORIA Y .IPD
    archivoY_IPD = fopen(NOMBRE_ARCHIVO_Y_IPDI, "w");

    if (archivoY_IPD == NULL) {
        printf("Error al abrir el archivo.");
        return 1;
    }
    for (int i = 0; i < sizeY_temp - 1; i++){
        fprintf(archivoY_IPD, "%02X\n", numerosY[i] & 0xFF);
    }
    fprintf(archivoY_IPD, "%02X", numerosY[sizeY_temp-1] & 0xFF);
    fclose(archivoY_IPD);

    //CREACION DE ARCHIVO DE MEMORIA H

    archivoH = fopen(NOMBRE_ARCHIVO_H, "w");

    if (archivoH == NULL) {
        printf("Error al abrir el archivo.");
        return 1;
    }

    int numerosH[sizeH_temp];
    printf("sizeH_temp: %i\n", sizeH_temp);

    printf("H = [");
    for (int i = 0; i < sizeH_temp - 1; i++){
        int numero = rand() % (256 * 2) - 128;
        printf(" %02X ", numero & 0xFF);
        fprintf(archivoH, "%02X\n", numero & 0xFF);
        numerosH[i] = numero;
    }
    numero = rand() % (256 * 2) - 128;
    fprintf(archivoH, "%02X", numero & 0xFF);
    printf(" %02X ", numero & 0xFF);
    numerosH[sizeH_temp-1] = numero;
    printf("]\n\n");
    fclose(archivoH);


    //RESOLUCION DE CONVOLUCION CON LOS DATOS GENERADOS Y GUARDADOS EN ARCHIVO

    int dataZ_temp;
    int k, dataZ;
    int tam_conv = sizeH_temp + sizeY_temp - 1;
    int convolucion[tam_conv];
    int i;

    archivoZ = fopen(NOMBRE_ARCHIVO_Z, "w");
    if (archivoZ == NULL) {
        printf("Error al abrir el archivo.");
        return 1;
    }

    printf("tam_conv: %i\n", tam_conv);
    printf("Z = [");
    for(i = 0; i < tam_conv; i++){
        dataZ_temp = 0;
        for(int j = 0; j < sizeY_temp; j++){
            k = i - j;
            if((k >= 0) && (k < sizeH_temp)){
                dataZ_temp = dataZ_temp + (numerosH[k]*numerosY[j]);
            }
        }
        dataZ = dataZ_temp;
        printf(" %04X ", dataZ & 0xFFFF);
        if(i < tam_conv - 1){
            fprintf(archivoZ, "%04X\n", dataZ & 0xFFFF);
        } else {
            fprintf(archivoZ, "%04X", dataZ & 0xFFFF);
        }
    }
    printf("]");
    fclose(archivoZ);

    return 0;
}
