#include <stdio.h>

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

int main() {
    char input1[7], input2[7], input3[7], input4[7], input5[7];
    int valor_numerico = 0;
    //scanf("%s %s %s %s %s\n", input1, input2, input3, input4, input5);
    scanf("%s ", input1);
    scanf("%s ", input2);
    scanf("%s ", input3);
    scanf("%s ", input4);
    scanf("%s", input5);
    
    // primeiro input
    valor_numerico = para_decimal(input1);
    printf("%d\n", valor_numerico);

    // segundo input
    valor_numerico = para_decimal(input2);
    printf("%d\n", valor_numerico);

    return 0;
}