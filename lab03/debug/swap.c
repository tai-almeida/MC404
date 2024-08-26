#include <stdio.h>
#include <string.h>

char input[20];
char output[35];

/*Converte para string para um valor numerico
Padrão do c: ja em complemento de 2*/
int valor_decimal(const char *input, int base) {
    int resultado=0, sinal=1, i=0, potencia=1;

    int digito=0;
    int tam = strlen(input);
    if(base == 0) {
        // eh decimal
        if(input[0] == '-') {
            sinal = -1;
            i++;
        } 
        for(int j=tam-1; j>=i; j--) {
            digito = input[j] - '0';
            resultado += digito*potencia;
            potencia *= 10;
        }
    }
    return resultado*sinal;
}

void swap_endianness(int valor) {
    int byte0, byte1, byte2, byte3;
    unsigned int resultado;

    // isola do byte menos ao mais significativo
    byte0 = (valor & 0X000000FF) >> 0;
    byte1 = (valor & 0x0000FF00) >> 8;
    byte2 = (valor & 0x00FF0000) >> 16;
    byte3 = (valor & 0xFF000000) >> 24;

    // shifta cada byte para ter o menos significativo 
    // no lugar do mais e vice versa
    byte0 <<= 24;
    byte1 <<= 16;
    byte2 <<= 8;
    byte3 <<= 0;

    // concatena os resultados usando OR
    resultado = byte0 | byte1 | byte2 | byte3;

    printf("%d", resultado);
}


int main() {
    scanf("%s", input);
    int valor_numerico = 0;
    valor_numerico = valor_decimal(input, 0);
    printf("%d\n", valor_numerico);
    swap_endianness(valor_numerico);
    return 0;
}