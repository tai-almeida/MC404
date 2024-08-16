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
int eh_hexadecimal();
int eh_decimal();
void converte_string_int();
void converte_int_string();
int hexa_negativo();
int complemento_binario();
int complemento_hexa();
int extende_32bits();
int decimal_binario();
int hexa_binario();



void converte_string_int() {
    return;
}


void converte_int_string() {
    return;
}

/* Verifica se a base eh hexadecimal*/
int eh_hexadecimal() {
    if(input_buffer[1] == "x") {
        return 1;
    }
    return 0;
}

/* Verifica se a base eh decimal*/
int eh_decimal() {
    return 0;
}

int decimal_binario() {
    return 0;
}

int hexa_binario() {
    // Percorre o buffer, baseado na tabela ascii
    int j=0;
    // converte todos os caracteres para inteiro
    for (int i=2; input_buffer[i] != '\n'; i++) {
        j++;
        if(input_buffer[i] - '0' < 58 && input_buffer[i] > 47) {
        // eh um valor entre 0 e 9
        valor[j] = input_buffer[i] - 48;
        } else {
            // eh um valor entre A e F
            switch(input_buffer[i]) {
                case 'A':
                    valor[j] = 1;
                    valor[j+1] = 0;
                    j++;
                    break;
                case 'B':
                    valor[j] = 1;
                    valor[j+1] = 1;
                    j++;
                    break;
                case 'C':
                    valor[j] = 1;
                    valor[j+1] = 2;
                    j++;
                    break;
                case 'D':
                    valor[j] = 1;
                    valor[j+1] = 3;
                    j++;
                    break;
                case 'E':
                    valor[j] = 1;
                    valor[j+1] = 4;
                    j++;
                    break;
                case 'F':
                    valor[j] = 1;
                    valor[j+1] = 5;
                    j++;
                    break;
            }
        }
    }

    // Converte hexadecimal para decimal
    int decimal = hexa_decimal()
}

int hexa_decimal(int hexa[32], int j) {
    int decimal;
    for(int i=j; i==0; i--) {
        decimal += hexa[i] * elevado(16, i);
    }
    return decimal;
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
    return 0;
}

int hexa_negativo() {
    // converte para binario para verificar o sinal
    return 0;
}

int complemento_binario() {
    return 0;
}

int complemento_hexa() {

}

int extende_32bits() {

}



/* MAIN */

// define variaveis globais
char input_buffer[20];
char output_buffer[35];
int valor[32];
int main() {
    int n = read(STDIN_FD, input_buffer, 20);
    if (eh_hexadecimal()) {
        // todo: implementar

        // verifica se eh negativo
        if(hexa_negativo()) {

        }
    } else {
        // eh decimal
    }
  
  return 0;
}
