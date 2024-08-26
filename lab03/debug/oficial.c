#include <stdio.h>
#include <string.h>

char input[20];
char output[35];

/* Identifica base de entrada
se 1: hexadecimal
se 0: decimal */
int get_tipo(char *input) {
    if(input[1] == 'x') {
        return 1;
    }
    return 0;
}

int elevado(int base, int expoente) {
    int resultado=0;
    for(int i=0; i<expoente; i++) {
        resultado *= base; 
    }
    return resultado;
}

void inverte_str(char *aux, char *destino, int tam) {
    int j=0;
    for(int i = tam-1; i>=0; i--) {
        destino[j] = aux[i];
        j++;
    }
    destino[j] = '\n';
    destino[j+1] = '\0';
}

void para_char(int valor, char *output) {
    int i=0, negativo = 0;
    char aux[35];

    if(valor < 0) {
        negativo = 1;
        valor *= -1;
    }

    while(valor != 0) {
        aux[i] = (valor % 10) + '0';
        valor /= 10;
        i++;
    }

    if(negativo) {
        aux[i] = '-';
        i++;
    } 
    int tam = strlen(aux);
    inverte_str(aux, output, tam);
    output[i] = '\0';
}

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
    } else {
        // eh hexadecimal
        const char base_hexa[16] = {'0', '1', '2', '3', '4', '5', '6', '7', 
                        '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'};

        // if(input[2] > '7' && input[2] <= 'f') {
        //     sinal = -1;
        //     i++;
        // }
        for(int j=tam-1; j>=2; j--) {
            for(int k=0; k<16; k++) {
                if(input[j] == base_hexa[k]) {
                    digito = k;
                }
            }
            resultado += digito*potencia;
            potencia *= 16;
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
    printf("\n");
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

void print_uint(int valor) {
    unsigned int resultado=0;

    for(int i=0; i<32; i++) {
        resultado += (valor & (1<<i)) * elevado(2, i);
    }
    printf("%d", resultado);

}

void swap_endianness(int valor) {
    int byte0, byte1, byte2, byte3;
    int resultado;

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
    printf("resultado: %d\n", resultado);
}


int main() {
    scanf("%s", input);
    int valor_numerico = 0;
    if(get_tipo(input)) {
        // eh hexadecimal
        valor_numerico = valor_decimal(input, 1);
        para_binario(valor_numerico);
        para_char(valor_numerico, output);
        printf("%s\n", output);
        printf("%s\n", input);
        swap_endianness(valor_numerico);
    } else {
        valor_numerico = valor_decimal(input, 0);
        para_binario(valor_numerico);
        printf("%s\n", input);
        para_hexa(valor_numerico);
        swap_endianness(valor_numerico);
    }
    return 0;
}