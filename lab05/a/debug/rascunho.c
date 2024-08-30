#include <stdio.h>
int binario[32], aux[32];

int para_decimal(char *input) {
    int n_bytes = 6;
    int resultado=0, sinal=1;
    // verifica se eh negativo
    int j=0;
    if(input[0] == '-') {
        sinal =-1;
        j++;
    }

    // converte para inteiro
    int digito, potencia=1;
    for(int i=n_bytes-2; i>=j; i--) {
        digito = input[i] - '0';
        resultado += digito*potencia;
        potencia *= 10;
    }

    return resultado*sinal;
}

void para_binario(int valor) {
    int j=31;
    for(int i=31; i>=0; i--) {
        // verifica se digito na posicao i eh 0 ou 1
        if(valor & (1<<i)) {
            aux[j] = 1;
            j--;
        }  else {
            aux[j] = 0;
            j--;
        }
    }
}

void lsb(int n, int inicio) {
    for(int i=inicio; i<=inicio+n; i++) {
        binario[i] = aux[i];
    }
}



int main() {
    char input1[7], input2[7], input3[7], input4[7], input5[7];
    int valor_numerico=0;
    scanf("%s ", input1);
    scanf("%s ", input2);
    scanf("%s ", input3);
    scanf("%s ", input4);
    scanf("%s", input5);
    
    // primeiro input
    valor_numerico = para_decimal(input1);
    printf("%d\n", valor_numerico);
    para_binario(-1);
    lsb(3, 0);
    for(int i=31; i>=0; i--) {
        printf("%d", binario[i]);
    }
    printf("\n");

    // segundo input
    valor_numerico = para_decimal(input2);
    printf("%d\n", valor_numerico);
    para_binario(valor_numerico);
    lsb(8, 3);
    for(int i=31; i>=0; i--) {
        printf("%d", binario[i]);
    }
    printf("\n");

    // terceiro input
    valor_numerico = para_decimal(input3);
    printf("%d\n", valor_numerico);
    para_binario(valor_numerico);
    lsb(5, 11);
    for(int i=31; i>=0; i--) {
        printf("%d", binario[i]);
    }
    printf("\n");

    // quarto input
    valor_numerico = para_decimal(input4);
    printf("%d\n", valor_numerico);
    para_binario(valor_numerico);
    lsb(5, 16);
    for(int i=31; i>=0; i--) {
        printf("%d", binario[i]);
    }
    printf("\n");

    // quinto input
    valor_numerico = para_decimal(input5);
    printf("%d\n", valor_numerico);
    para_binario(valor_numerico);
    lsb(11, 21);
    for(int i=31; i>=0; i--) {
        printf("%d", binario[i]);
    }
    printf("\n");

    return 0;
}