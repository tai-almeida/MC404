#include <stdio.h>
int binario[32], aux[32];

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
    //int binario[32];
    //scanf("%s %s %s %s %s\n", input1, input2, input3, input4, input5);
    scanf("%s ", input1);
    scanf("%s ", input2);
    scanf("%s ", input3);
    scanf("%s ", input4);
    scanf("%s", input5);
    
    // primeiro input
    //int valor_numerico = para_decimal(input1);
    //printf("%d\n", valor_numerico);
    para_binario(-1);
    lsb(3, 0);
    for(int i=31; i>=0; i--) {
        printf("%d", binario[i]);
    }
    printf("\n");

    // segundo input
    para_binario(-1);
    lsb(8, 3);
    for(int i=31; i>=0; i--) {
        printf("%d", binario[i]);
    }
    printf("\n");

    // terceiro input
    para_binario(-1);
    lsb(5, 11);
    for(int i=31; i>=0; i--) {
        printf("%d", binario[i]);
    }
    printf("\n");

    // quarto input
    para_binario(-1);
    lsb(5, 16);
    for(int i=31; i>=0; i--) {
        printf("%d", binario[i]);
    }
    printf("\n");

    // quinto input
    para_binario(-1);
    lsb(11, 21);
    for(int i=31; i>=0; i--) {
        printf("%d", binario[i]);
    }
    printf("\n");

    return 0;
}