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



#define STDIN_FD  0
#define STDOUT_FD 1

/* FUNCOES */
void zeraOutput();
void zeraVetor(int *vetor);
int tamString(char *output);
int elevado(int base, int expoente);
void copiaVetor(char *vetor, char *copia, int posicao);
int charParaInt(char caractere);
void converteIntParaChar(unsigned int decimal, char *output);
void inverteVetor(char *aux, int inicio);
int isHexadecimal();
int hexaNegativo();
void intParaHexa(unsigned int numero);
void intParaDecimal(unsigned int numero);
void intParaBinario(unsigned int numero);
unsigned int inputHexa(int posicao);
void binarioParaStr(int *binario, char *output);
void binarioParaHexa();
void complemento2();
void shifta();
int inverteEndianness(unsigned int decimal);
unsigned int inputDecimal(int posicao);
unsigned int binarioParaInt();
int decimalNegativo();

/*Zera todas as posições do buffer de saída*/
void zeraOutput() {
    for(int i=0; i<35; i++) {
        output_buffer[i] = '\0';
    }
}

void zeraVetor(int *vetor) {
    for(int i=0; i<32; i++) {
        vetor[i] = 0;
    }
}

int tamString(char *output) {
    int tam=0;
    while(output[tam] != '\0') {
        tam++;
    }
    return tam;
}

int elevado(int base, int expoente) {
    int resultado = 1;
    for(int i=0; i<expoente; i++) {
        resultado*=base;
    }
    return resultado;
}

/* Converte da tabela ascii para um valor inteiro
Hexadecimal sempre em letra minuscula*/
int charParaInt(char caractere) {
    if(caractere >= 'a' && caractere <='f') {
        return caractere - 'a' + 10;
    } else {
        return caractere - '0';
    }
}

void converteIntParaChar(unsigned int decimal, char *output) {
    int i=0;

    while(decimal != 0) {
        output[i] = (decimal % 10) + '0';
        decimal /= 10;
        i++;
    }
    inverteVetor(output, i);
    output[i] = '\n';

}

void inverteVetor(char *aux, int inicio) {
    int atual = tamString(aux) - 1;
    int j=0;
    for (int i=atual; i>= 0; i++) {
        output_buffer[i] = aux[j];
        j++;
    }
}

void copiaVetor(char *vetor, char *destino, int posicao) {
    int i;
    for(i=posicao; vetor[i] != '\n'; i++) {
        destino[i] = vetor[i];
    }
    destino[i] = '\n';
}

// LIDANDO COM HEXADECIMAL

/* Verifica se a base eh hexadecimal: comeca com 0x*/
int isHexadecimal() {
    if(input_buffer[1] == 'x') {
        return 1;
    }
    return 0;
}

/* Digito mais significativo a partir de 8 (56): negativo
Retorna 1 se negativo e 0 se positivo */
int hexaNegativo() {
    // posicao 2 (depois do x): digito mais significativo
    if(input_buffer[2] > '7') {
        return 1;
    }
    return 0;
}


void intParaHexa(unsigned int numero) {
    // Converte decimal para hexa
    int i=0, valor;
    char aux[32];
    const char baseHexa[16] = {'0', '1', '2', '3', '4', '5', '6', '7', 
                                '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'};

    while(valor > 0) {
        int resto = numero % 16;
        // encontra o valor referente a posicao na base 16
        aux[i] = baseHexa[resto];
        valor /= 16;
        i++;
    }
    
    inverteVetor(aux, 2);
    output_buffer[0] = '0';
    output_buffer[1] = '1';
    output_buffer[i+2] = '\n';
}

void intParaDecimal(unsigned int numero) {
    int valor = numero;
    char aux[32];

    int i=0;
    while(valor > 0) {
        aux[i] = (valor%10) + '0';
        valor /= 10;
        i++;
    }
    output_buffer[i] = '\n';
    inverteVetor(aux, 0);
}

void intParaBinario(unsigned int numero) {
    int valor = numero;
    char aux[32];

    int i=0;
    while(valor != 0) {
        aux[i] = (valor%2) + '0';
        valor /= 2;
        i++;
    }

    if(valor == 0) {
        output_buffer[2] = valor + '0';
        output_buffer[3] = '\n';
    } else {
        output_buffer[i] = '\n';
    }

    output_buffer[0] = '0';
    output_buffer[1] = 'b';
    inverteVetor(aux, 2);
}

/* Obtem o valor em modulo do decimal de entrada */
unsigned int inputHexa(int posicao) {
    unsigned int moduloHexa=0;
    char c = input_buffer[posicao];
    int tam = tamString(input_buffer)-3; // desconsidera o 0xsinal
    
    for(int i=2; i<34; i++) {
        int valor = charParaInt(input_buffer[posicao]);
        moduloHexa += valor*elevado(16, tam-1);
        tam--;
    }
    return moduloHexa;
}

void binarioParaStr(int *binario, char *output) {
    int i;
    for(i=0; i<32; i++) {
        output[i] = binario[i] + '0';
    }
    output[i] = '\n';
}


/* Transcreve os valores de letra para as suas representacoes posicionais
Converte de hexadecimal para decimal e de decimal para binario
Armazena o resultado no vetor valor (global)
*/
void binarioParaHexa() {
    char aux[35];
    
    output_buffer[0] = '0';
    output_buffer[1] = 'x';
    copiaVetor(output_buffer, aux, 2);
    zeraOutput();

    const char binParaHexa[16] = {'0', '1', '2', '3', '4', '5', '6', '7',
                                    '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'};

    // processa 4 bits por iteração sobre 32 bits
    int resultado, posicaoByte, j=2, i;
    for(i=0; i<32; i+=4) {
        resultado=0, posicaoByte=3;
        resultado += elevado(2, posicaoByte) * charParaInt(aux[i]);
        resultado += elevado(2, posicaoByte--) * charParaInt(aux[i+1]);
        resultado += elevado(2, posicaoByte--) * charParaInt(aux[i+2]);
        resultado += elevado(2, posicaoByte--) * charParaInt(aux[i+3]);

        output_buffer[j] = binParaHexa[resultado];
        j++;
    }
    output_buffer[i] = '\n';
}

void complemento2() {
    output_buffer[0] = '0';
    output_buffer[1] = '1';
    // complemento de base 1 (reduzida)
    
    for(int i=0; i<34; i++) {
        if(output_buffer[i] == '0') {
            output_buffer[i] = '1';
        
        } else if(output_buffer[i] == '1') {
            output_buffer[i] = '0';
        }
    }

    // complemento de base 2
    int carry = 1, i;
    for(i=31; i>=2; i--) {
        if(output_buffer[i] == '1' && carry == 1) {
            output_buffer[i] = '0';
            carry = 1;
        } else if(output_buffer[i] == '0' && carry == 1) {
            output_buffer[i] = '1';
            carry = 0;
            break;
        }
    }
    output_buffer[i] = '\n';
}

/*Desloca os caracteres para uma posicao a direita
Inclui o sinal negativo na primeira posicao do vetor*/
void shifta() {
    char aux[35];
    copiaVetor(output_buffer, aux, 0);
    zeraOutput();
    int i=0;

    while(aux[i] != '\n') {
        // desloca todas as posicoes para a direita uma unidade
        output_buffer[i+1] = aux[i];
        i++;
    }
    if(aux[i] == '\n') {
        output_buffer[i] = aux[i];
    }
}

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


/* Obtem o valor em modulo do decimal de entrada */
unsigned int inputDecimal(int posicao) {
    unsigned int moduloDecimal=0;
    char c = input_buffer[posicao];
    int tam = tamString(input_buffer);
    int i=0;

    while(c != '\n') {
        int valor = charParaInt(c);
        moduloDecimal += c*elevado(10, posicao);
        posicao--;
    }

    return moduloDecimal;
}

unsigned int binarioParaInt() {
    char c = output_buffer[2];
    unsigned int modulo=0;
    int tam = tamString(output_buffer) - 2;
    int posicao = tam-1;

    c = output_buffer[tam];
    int valor;
    for(int i=2; i<tam+2; i++) {
        valor= charParaInt(output_buffer[i]);
        modulo +=elevado(2, posicao)*valor;
        posicao--;
        
    }
    return modulo;
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


int main() {
    int n = read(STDIN_FD, (void *) input_buffer, 20);
    zeraVetor(valor);
    zeraOutput();
    int tam;
    unsigned int modulo=0, trocado;
    if(isHexadecimal()) {
        if(hexaNegativo()) {
            modulo = inputHexa(0);
            intParaBinario(modulo);
            write(STDOUT_FD, (void *) output_buffer, 35);
            zeraOutput();
            modulo = binarioParaInt();
            zeraOutput();
            intParaDecimal(modulo);
            shifta();
            write(STDOUT_FD, (void *) output_buffer, 35);
            write(STDOUT_FD, (void *) input_buffer, 20);
            //copiaVetor(input_buffer, output_buffer, 0);
            trocado = inverteEndianness(modulo);
            converteIntParaChar(trocado, output_buffer);
            write(STDOUT_FD, (void *) output_buffer, 35);
        } else {
            modulo = inputHexa(0);
            intParaBinario(modulo);
            write(STDOUT_FD, (void *) output_buffer, 35);
            zeraOutput();
            intParaDecimal(modulo);
            shifta();
            write(STDOUT_FD, (void *) output_buffer, 35);
            write(STDOUT_FD, (void *) input_buffer, 20);
            zeraOutput();
            copiaVetor(input_buffer, output_buffer, 0);
            trocado = inverteEndianness(modulo);
            write(STDOUT_FD, (void *) output_buffer, 35);
        }
    } else {
        
        if(decimalNegativo()) {
            modulo = inputDecimal(1); // ignora a posicao 0 do sinal
            modulo--;
            intParaBinario(modulo);
            complemento2();
            write(STDOUT_FD, (void *) output_buffer, 35);
            write(STDIN_FD, (void *) input_buffer, 20);
            binarioParaHexa();
            write(STDOUT_FD, (void *) output_buffer, 35);
            zeraOutput();
            trocado = inverteEndianness(modulo);
            converteIntParaChar(trocado, output_buffer);
            output_buffer[34] = '\n';
            write(STDOUT_FD, (void *) output_buffer, 35);
        } else {
            modulo = inputDecimal(0);
            intParaBinario(modulo);
            write(STDOUT_FD, (void *) output_buffer, 35);
            write(STDOUT_FD, (void *) input_buffer, 20);
            zeraOutput();
            intParaHexa(modulo);
            write(STDOUT_FD, (void *) output_buffer, 35);
            zeraOutput();
            trocado = inverteEndianness(modulo);
            converteIntParaChar(trocado, output_buffer);
            output_buffer[34] = '\n';
            write(STDOUT_FD, (void *) output_buffer, 35);
            zeraOutput();
        }        
    }
    return 0;
}

void _start()
{
  int ret_code = main();
  exit(ret_code);
}