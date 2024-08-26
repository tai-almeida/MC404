int read(int __fd, const void *__buf, int __n){
    int ret_val;
  __asm__ __volatile__(
    "mv a0, %1           # file descriptor\n"
    "mv a1, %2           # buffer \n"
    "mv a2, %3           # size \n"
    "li a7, 63           # syscall write code (63) \n"
    "ecall               # invoke syscall \n"
    "mv %0, a0           # move return value to ret_val\n"
    : "=r"(ret_val)  // Output list
    : "r"(__fd), "r"(__buf), "r"(__n)    // Input list
    : "a0", "a1", "a2", "a7"
  );
  return ret_val;
}

void write(int __fd, const void *__buf, int __n)
{
  __asm__ __volatile__(
    "mv a0, %0           # file descriptor\n"
    "mv a1, %1           # buffer \n"
    "mv a2, %2           # size \n"
    "li a7, 64           # syscall write (64) \n"
    "ecall"
    :   // Output list
    :"r"(__fd), "r"(__buf), "r"(__n)    // Input list
    : "a0", "a1", "a2", "a7"
  );
}

void exit(int code)
{
  __asm__ __volatile__(
    "mv a0, %0           # return code\n"
    "li a7, 93           # syscall exit (64) \n"
    "ecall"
    :   // Output list
    :"r"(code)    // Input list
    : "a0", "a7"
  );
}
#define STDIN_FD  0
#define STDOUT_FD 1
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
    int resultado=1;
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

int para_char(int valor, char *output) {
    int i=0, negativo = 0;
    char aux[35];

    if(valor == -2147483648) {
        write(STDOUT_FD, "-2147483648\n", 12);
        return 11;
    } 
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
    
    inverte_str(aux, output, i);
    return i;
}

/*Converte para string para um valor numerico
Padrão do c: ja em complemento de 2*/
int valor_decimal(const char *input, int base, int n_bytes) {
    int resultado=0, sinal=1, i=0, exp=0;
    int digito=0;
    if(base == 0) {
        // eh decimal
        if(input[0] == '-') {
            // verifica se eh negativo
            sinal = -1;
            i++;
        } 
        for(int j=n_bytes-2; j>=i; j--) {
            digito = input[j] - '0';
            resultado += digito*elevado(10, exp);
            exp++;
        }
    } else {
        // eh hexadecimal
        const char base_hexa[16] = {'0', '1', '2', '3', '4', '5', '6', '7', 
                        '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'};
        
        for(int j=n_bytes-2; j>=2; j--) {
            for(int k=0; k<16; k++) {
                if(input[j] == base_hexa[k]) {
                    digito = k;
                }
            }
            resultado += digito*elevado(16, exp);
            exp++;
        }
    }
    return resultado*sinal;
}

/* Converte um valor numerico para binarios avaliando bit por bit
caso seja um valor negativo, usa-se complemento de 2
So comeca a imprimir a partir do primeiro 1 (descarta os zeros a esquerda)*/
void para_binario(int valor) {
    int achou=0;
    write(STDOUT_FD, "0b", 2);

    // percorre o valor do digito menos significativo para o mais
    for(int i=31; i>=0; i--) {
        if(valor & (1<<i)) {
            achou=1;
            write(STDOUT_FD, "1", 1);
        } else {
            if(!achou) {
                continue;
            } else write(STDOUT_FD, "0", 1);
        }
    }
    write(STDOUT_FD, "\n", 1);
}

/* Processa cada 4 bits e salva sua conversao em uma string */
void para_hexa(int valor) {
    int achou=0, resultado=0;
    char digito;
    char hexa[35], aux[35];
    const char base_hexa[16] = {'0', '1', '2', '3', '4', '5', '6', '7', 
                        '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'};
    
    // processa cada 4 bits (exapansao do binario)
    int quatro_bits=0, j=0, i;
    for(i=7; i>=0; i--) {
        // desloca valor 4i pra direita e compara com o valor 15 em binario
        quatro_bits = (valor >> (4*i)) & 15;
        digito = base_hexa[quatro_bits];
        aux[j] = digito;
        j++;
    }

    int ini = 0;
    while(aux[ini] == '0' && ini < j-1) {
        ini++;
    }
    for(i=ini; i<8; i++) {
        hexa[i-ini+2] = aux[i];
    }
    hexa[i-ini+2] = '\n';
    hexa[i-ini+3] = '\0';
    hexa[0] = '0';
    hexa[1] = 'x';
    write(STDOUT_FD, hexa, i-ini+3);
}

int swap_endianness(int valor) {
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
    return resultado;
}

void print_swapped(int valor) {
    char str[35];
    unsigned int resultado=0, n=0;

    if(valor == 4294967295) {
        // explode o limite
        write(STDOUT_FD, "4294967295\n", 11);
        return;
    }
    unsigned int aux = valor, temp=aux;
    while(aux != 0) {
        n++;
        aux /= 10;
    }
    aux=temp;
    for(int i=n-1; i>=0; i--) {
        int resto = aux%10;
        aux /= 10;
        str[i] = resto + '0';
    }
    str[n] = '\n';
    write(STDOUT_FD, str, n+1);
}

int main() {
  char str[20];
  /* Read up to 20 bytes from the standard input into the str buffer */
  int n = read(STDIN_FD, input, 20);
  int valor_numerico = 0;
    if(get_tipo(input)) {
        // eh hexadecimal
        valor_numerico = valor_decimal(input, 1, n);
        para_binario(valor_numerico);
        para_char(valor_numerico, output);
        write(STDOUT_FD, output, 35);
        write(STDOUT_FD, input, 11);
        int trocado = swap_endianness(valor_numerico);
        print_swapped(trocado);
    } else {
        valor_numerico = valor_decimal(input, 0, n);
        para_binario(valor_numerico);
        write(STDOUT_FD, input, 11);
        para_hexa(valor_numerico);
        int trocado = swap_endianness(valor_numerico);
        print_swapped(trocado);
    }
  return 0;
}

void _start()
{
  int ret_code = main();
  exit(ret_code);
}