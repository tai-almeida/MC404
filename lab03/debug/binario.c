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
            // verifica se eh negativo
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


/* Converte um valor numerico para binarios avaliando bit por bit
caso seja um valor negativo, usa-se complemento de 2
So comeca a imprimir a partir do primeiro 1 (descarta os zeros a esquerda)*/
void para_binario(int valor) {
    int achou=0;
    printf("0b");
    // if(valor < 0) {
    //     // complemento de 2
    //     valor = ~(valor) + 1;
    // }

    // percorre o valor do digito menos significativo para o mais
    for(int i=31; i>=0; i--) {
        // compara o valor com o bit na posicao i
        if(!(valor & (1<<i))) {
            // caso de zero, o digito binario eh zero
            if(achou == 0) {
                continue;
            } else {
                printf("0");
            }
        } else {
            // caso de um, o digito binario eh um
            achou=1;
            printf("1");
        }
    }
}


int main() {
    scanf("%s", input);
    int valor_numerico = 0;
    valor_numerico = valor_decimal(input, 0);
    printf("valor decimal: %d\n", valor_numerico);
    para_binario(valor_numerico);
    return 0;
}