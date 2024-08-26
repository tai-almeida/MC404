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

void para_hexa(int valor) {
    int achou=0, resultado=0;
    char digito;
    char hexa[35], aux[35];
    const char base_hexa[16] = {'0', '1', '2', '3', '4', '5', '6', '7', 
                        '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'};
    
    if(valor < 0) {
        valor = ~(valor) + 1;
    }
    // processa cada 4 bits (exapansao do binario)
    int quatro_bits=0, j=0, i;
    for(i=7; i>=0; i--) {
        // desloca valor 4i pra direita e compara com o valor 15 em binario
        quatro_bits = (valor >> (4*i)) & 15;
        digito = base_hexa[quatro_bits];
        aux[j] = digito;
        j++;
    }
    aux[j] = '\0';

    int ini = 0;
    while(aux[ini] == '0' && ini < j-1) {
        ini++;
    }
    for(int i=ini; i<8; i++) {
        hexa[i-ini] = aux[i];
    }
    printf("0x%s\n", hexa);
    
}


int main() {
    scanf("%s", input);
    int valor_numerico = 0;
    valor_numerico = valor_decimal(input, 0);
    printf("%d\n", valor_numerico);
    para_hexa(valor_numerico);
    return 0;
}