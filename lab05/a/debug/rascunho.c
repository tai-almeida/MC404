#include <stdio.h>
int resultado=0;

int para_decimal(char *input) {
    int n_bytes = 6;
    int resultado=0, sinal=1;
    // verifica se eh negativo
    int j=0;
    if(input[0] == '-') {
        sinal =-1;
        j++;
    } else j++;

    // converte para inteiro
    int digito, potencia=1;
    for(int i=n_bytes-2; i>=j; i--) {
        digito = input[i] - '0';
        resultado += digito*potencia;
        potencia *= 10;
    }

    return resultado*sinal;
}


void para_binario_lsb(int valor, int n, int inicio) {
    //int posicoes = 32-n;
    int lsb = valor & n;
    resultado |= (lsb << inicio);
}

void hex_code(int valor){
    char hex[11];
    unsigned int uval = (unsigned int) valor, aux;

    hex[0] = '0';
    hex[1] = 'x';
    hex[10] = '\n';

    for (int i = 9; i > 1; i--){
        aux = uval % 16;
        if (aux >= 10)
            hex[i] = aux - 10 + 'A';
        else
            hex[i] = aux + '0';
        uval = uval / 16;
    }
    //write(1, hex, 11);
    printf("%s\n", hex);
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
    
    para_binario_lsb(valor_numerico, 7, 0);
    printf("%d\n", resultado);

    // segundo input
    valor_numerico = para_decimal(input2);
    para_binario_lsb(valor_numerico, 255, 3);
    printf("%d\n", resultado);
    

    // terceiro input
    valor_numerico = para_decimal(input3);
    para_binario_lsb(valor_numerico, 31, 11);
    printf("%d\n", resultado);
    

    // quarto input
    valor_numerico = para_decimal(input4);
    para_binario_lsb(valor_numerico, 31, 16);
    printf("%d\n", resultado);
    

    // quinto input
    valor_numerico = para_decimal(input5);
    para_binario_lsb(valor_numerico, 2047, 21);
    printf("%d\n", resultado);

    hex_code(resultado);
    

    return 0;
}