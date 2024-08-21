// define variaveis globais
char input_buffer[20];
char output_buffer[35];
int valor[32];

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

void _start()
{
  int ret_code = main();
  exit(ret_code);
}

#define STDIN_FD  0
#define STDOUT_FD 1

/* FUNCOES */

void zeraOutput() {
    for(int i=0;i<35;i++) {
        output_buffer[i] = 0;
    }
}


int *converteCharParaInt(char input_buffer[20]) {
    int input[20];
    for(int i=0; input_buffer[i] != '\n'; i++) {
        input[i] = input_buffer[i] - '0';
    }
    return input;
}

int *inverteVetor(int vetor[32], int posicao) {
    int temp[32];
    for (int i=0; i<posicao; i++) {
        temp[i] = vetor[posicao - i];
    }
    return temp;
}

int *copiaVetor(int vetor[32]) {
    int v2[32];
    for(int i=0; i<32; i++) {
        v2[i] = vetor[i];
    }
    return v2;
}


void converte_int_string() {
    return;
}

/* Verifica se a base eh hexadecimal*/
int isHexadecimal() {
    if(input_buffer[1] == 'x') {
        return 1;
    }
    return 0;
}

int decimalParaBinario(int decimal) {
    int binarioInvertido[32];
    int k=-1;
    while(decimal != 0) {
        k++;
        binarioInvertido[k] = (decimal % 2);
        decimal /= 2;
    }
    int binario[32] = inverteVetor(binarioInvertido, k);
    return binario;
}

/* LIDANDO COM HEXADECIMAL */

int hexaParaBinario() {
    // Percorre o buffer, baseado na tabela ascii
    int posicao=0;
    const char baseHexa[16] = {"0", "1", "2", "3", "4", "5", "6", "7", 
                                "8", "9", "A", "B", "C", "D", "E", "F"};

    // valor eh igual ao indice
    for(int i=0; i<32; i++) {
        for(int j=0; j<16; j++) {
            if(input_buffer[i] == baseHexa[j]) {
                valor[i] = j;
                posicao++;
            }
        }
    }

    // Converte hexadecimal para decimal
    int decimal = hexaParaDecimal(valor, posicao);

    // Converte decimal para binário
    int binario[32] = decimalParaBinario(decimal);
}

int hexaParaDecimal(int hexa[32], int j) {
    int decimal = 0;
    for(int i=0; i<j; i++) {
        decimal += hexa[i] * elevado(16, i);
    }

    // TODO: inverter vetor
    return decimal;
}

int inverteEndian() {
    
}

int elevado(int base, int expoente) {
    int resultado = 1;
    for(int i=0; i<expoente; i++) {
        resultado*=base;
    }
    return resultado;
}




/* Verifica se o numero de entrada eh negativo
digito mais significativo = 1: negativo
digito mais significativo = 0: positivo*/
int decimal_negativo() {
    // olha se tem -
    if(input_buffer[0] == '-') {
        return 1;
    }
    return 0;
}

/* Digito mais significativo a partir de 8: negativo
Retorna 1 se negativo e 0 se positivo */
int hexaNegativo(char hexa[35]) {
    // posicao 2 (depois do x): digito mais significativo
    if(hexa[2] > '7') {
        return 1;
    }
    return 0;
}



/* MAIN */


int main() {
    int n = read(STDIN_FD, input_buffer, 20);
    if (isHexadecimal()) {
        // todo: implementar
        if(hexaNegativo(output_buffer))

        
    } else {
        // eh decimal
    }
  
  return 0;
}
