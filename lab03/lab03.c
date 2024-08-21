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

void zeraVetor(int vetor[32]) {
    for(int i=0; i<32; i++) {
        vetor[i] = 0;
    }
}

void converteCharParaInt(char input_buffer[20], int output[20]) {
    for(int i=0; input_buffer[i] != '\n'; i++) {
        output[i] = input_buffer[i] - '0';
    }
}

void converteIntParaChar(unsigned int decimal, char *output) {
    unsigned int aux = decimal;
    int i=0;

    while(aux != 0) {
        output[i] = (aux % 10) + '0';
        aux /= 10;
        i++;
    }
    inverteVetor(output, i, output_buffer);

}

void inverteVetor(int vetor[32], int posicao, int output[32]) {
    for (int i=0; i<posicao; i++) {
        output[i] = vetor[posicao - i - 1];
    }
}

void copiaVetor(int *vetor, int *destino) {
    for(int i=0; vetor[i] != '\0'; i++) {
        destino[i] = vetor[i];
    }
}

int tamString(char output[35]) {
    int tam=0;
    while(output[tam] != '\0') {
        tam++;
    }
    return tam;
}

/* Verifica se a base eh hexadecimal*/
int isHexadecimal() {
    if(input_buffer[1] == 'x') {
        return 1;
    }
    return 0;
}

/* Enquanto a divisao do decimal pela base 2 for diferente de zero, 
continua-se extraindo o resto das divisoes
Inverte o vetor, de modo que o MSB eh o valor que foi extraido por ultimo
*/
void decimalParaBinario(unsigned int decimal, int output[32]) {
    for(int i=31; i>= 0; i--) {
        output[i] = decimal % 2;
        decimal /= 2;
    }
}

int binarioParaDecimal(int binario[32], int posicao) {
    int decimal = 0;
    for(int i=0; i<posicao; i++) {
        decimal += binario[i] * elevado(2, posicao-1-i);
    }
    return decimal;
}

/* Converte hexadecimal para decimal avaliando o polinomio na base 10*/
unsigned int hexaParaDecimal(char *hexa) {
    unsigned int decimal = 0;
    for(int i=0; hexa[i] != '\0'; i++) {
        decimal += hexa[i] * elevado(16, i);
    }

    // TODO: inverter vetor
    return decimal;
}

void decimalParaHexa(unsigned int decimal, char *output) {
    // Converte decimal para hexa
    int i=0;
    const char baseHexa[16] = {"0", "1", "2", "3", "4", "5", "6", "7", 
                                "8", "9", "A", "B", "C", "D", "E", "F"};

    while(decimal > 0) {
        int resto = decimal % 16;
        // encontra o valor referente a posicao na base 16
        output[i] = baseHexa[resto];
        decimal /=16;
        i++;
    }
    inverteVetor(output, i, output_buffer);
}

/* Transcreve os valores de letra para as suas representacoes posicionais
Converte de hexadecimal para decimal e de decimal para binario
Armazena o resultado no vetor valor (global)
*/
void hexaParaBinario() {
    zeraVetor(valor);
    // Percorre o buffer, baseado na tabela ascii
    int posicao=0;

    // valor eh igual ao indice
    for(int i=2; input_buffer[i] != '\0'; i++) {
        int valorNumerico;

        if(input_buffer[i] >= '0' && input_buffer[i] <= '9') {
            valorNumerico = input_buffer[i] - '0';
        } else if(input_buffer[i] >= 'A' && input_buffer <= 'F') {
            valorNumerico = input_buffer[i] - 'A' + 10;
        } else {
            valorNumerico = input_buffer[i] - 'a' + 10;
        }

        for(int j=3; j>=0; j--) {
            // desloca o bits de valor numerico para a direita j posicoes,mantendo o menos significativo
            valor[posicao] = (valorNumerico >> j) & 1;
            posicao++;
        }
    }
    
}

/* Transcreve os valores de letra para as suas representacoes posicionais
Converte de hexadecimal para decimal e de decimal para binario
Armazena o resultado no vetor valor (global)
*/
void binarioParaHexa(int *binario, char *output) {
    int decimal = binarioParaDecimal(binario, 32);
    decimalParaHexa(decimal, output_buffer);
}

void complemento2(int valor[32]) {
    int resultado[32];
    // inverte os bits um a um
    for(int i=0; i<32; i++) {
        resultado[i] = 1 - valor[i];
    }
    
    // adiciona 1 ao complemento de 1, propagando o carry se ne
    int soma, carry = 1;
    for(int i=31; i>=0; i--) {
        soma = resultado[i] + carry;
        if(soma == 2) {
            carry = 1;
            resultado[i] = 0;
        } else {
            carry = 0;
            resultado[i] = soma;
        } 
    }
    copiaVetor(resultado, valor);
}

/* Verifica se o valor eh negativo
se for: shifta os caracteres para a direita e add - no incio
se nao: apenas faz o calculo da conversao de bases*/
void comp2ParaDecimal(int *comp2, int posicao) {
    if(comp2[0] == 1) {
        // eh negativo - shifta
        binarioParaDecimal(comp2, posicao);
        shifta(output_buffer);
    } else {
        binarioParaDecimal(comp2, posicao);
    }
}

/*Desloca os caracteres para uma posicao a direita
Inclui o sinal negativo na primeira posicao do vetor*/
void shifta(char vetor[35]) {
    int tam;
    tam = tamString(vetor);

    for(int i = tam; i>=0; i--) {
        output_buffer[i+1] = output_buffer[i];
    }
    output_buffer[0] = '-';
}



/* LIDANDO COM HEXADECIMAL */





/* Big Endian: armazena o byte mais significativo no menor endereco
Little Endian: armazena o byte menos significativo no menor endereco */
int inverteEndianness(unsigned int decimal) {
    unsigned int resultado = 0;

    // isola o primeiro byte e o desloca para a posicao do quarto byte
    unsigned int primeiroByte = (decimal & 0x000000FF) >> 0;
    primeiroByte <<= 24;

    // isola o segundo byte e o desloca para a posicao do terceiro byte
    unsigned int segundoByte = (decimal & 0x0000FF00) >> 8;
    segundoByte <<= 16;

    // isola o terceiro byte e o desloca para a posicao do segundo byte
    unsigned int terceiroByte = (decimal & 0x00FF0000) >> 16;
    terceiroByte <<= 8;

    // isola o ultimo byte e o desloca para a posicao do segundo byte
    unsigned int ultimoByte = (decimal & 0xFF000000) >> 24;
    ultimoByte <<= 0;

    // retorna a concatenacao dos bytes isolados resultando no valor desejado
    resultado = primeiroByte | segundoByte | terceiroByte | ultimoByte;
    return resultado;
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
int decimalNegativo() {
    // olha se tem -
    if(input_buffer[0] == '-') {
        return 1;
    }
    return 0;
}

/* Digito mais significativo a partir de 8 (56): negativo
Retorna 1 se negativo e 0 se positivo */
int hexaNegativo() {
    // posicao 2 (depois do x): digito mais significativo
    if(input_buffer[2] > 55) {
        return 1;
    }
    return 0;
}



/* MAIN */


int main() {
    int n = read(STDIN_FD, input_buffer, 20);
    zeraVetor(valor);
    zeraOutput();

    if (isHexadecimal()) {
        output_buffer[0] = '0';
        output_buffer[1] = 'b';
        // todo: implementar
        if(hexaNegativo()) {
            // imprime valor binario em complemento de 2
            hexaParaBinario();
            complemento2(valor);

            for(int i=0; i<32; i++) {
                output_buffer[i] = valor[i+2] + '0'; 
            }
            output_buffer[35] = '\n';
            write(STDOUT_FD, output_buffer, tamString(output_buffer));
        } else {
            hexaParaBinario();
            for(int i=0; i<32; i++) {
                output_buffer[i] = valor[i+2] + '0'; 
            }
            output_buffer[35] = '\n';
            write(STDOUT_FD, output_buffer, tamString(output_buffer));
        }
        // imprime valor decimal a partir do complemento de 2
        zeraOutput();
        comp2ParaDecimal(valor, 32);
        output_buffer[32] = '\n'; 
        write(STDOUT_FD, output_buffer, tamString(output_buffer));

        // imprime valor hexadecimal
        zeraOutput();
        copiaVetor(input_buffer, output_buffer);
        int tam = tamString(output_buffer);
        output_buffer[tam + 1] = '\n';
        write(STDOUT_FD, output_buffer, tamString(output_buffer));

        // imprime sem sinal para decimal com swap do endianess
        zeraOutput();
        unsigned int inicial = hexaParaDecimal(valor, 32);
        unsigned int trocado = inverteEndianness(inicial);
        converteIntParaChar(trocado, output_buffer);
        write(STDOUT_FD, output_buffer, tamString(output_buffer));
    } else {
        // eh decimal
        zeraOutput();
        zeraVetor(valor);

        output_buffer[0] = '0';
        output_buffer[1] = 'b';

        // avalia se eh negativo
        if(decimalNegativo()) {
            
            decimalParaBinario()
        }


        
    }

    write(STDOUT_FD, output_buffer, 35);
    return 0;
}
