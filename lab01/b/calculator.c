// variaveis globais  (input e output)
char operacao[6];
char sValor[2];

// Executa o programa
void exit(int code)
{
  __asm__ __volatile__(
    "mv a0, %0           # return code\n"
    "li a7, 93           # syscall exit (64) \n"
    "ecall"
    :             // Output list
    :"r"(code)    // Input list
    : "a0", "a7"
  );
}

/* read
 * Parameters:
 *  __fd:  file descriptor of the file to be read.
 *  __buf: buffer to store the data read.
 *  __n:   maximum amount of bytes to be read.
 * Return:
 *  Number of bytes read.
 */
int read(int __fd, const void *__buf, int __n)
{
    int ret_val;
  __asm__ __volatile__(
    "mv a0, %1           # file descriptor\n"
    "mv a1, %2           # buffer \n"
    "mv a2, %3           # size \n"
    "li a7, 63           # syscall read code (63) \n"
    "ecall               # invoke syscall \n"
    "mv %0, a0           # move return value to ret_val\n"
    : "=r"(ret_val)                   // Output list
    : "r"(__fd), "r"(__buf), "r"(__n) // Input list
    : "a0", "a1", "a2", "a7"
  );
  return ret_val;
}

/* write
 * Parameters:
 *  __fd:  files descriptor where that will be written.
 *  __buf: buffer with data to be written.
 *  __n:   amount of bytes to be written.
 * Return:
 *  Number of bytes effectively written.
 */
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

void resolve_operacao() {
  int valor;

  //passa de char para int (Tabela ASCII)
  int op1 = operacao[0] - 48;
  int op2 = operacao[4] - 48;

  // Realiza a operacao de acordo com o operador
  switch(operacao[2]) {
    case('+'):
      valor = op1 + op2;
      break;
    case('-'):
      valor = op1 - op2;
      break;
    case('*'):
      valor = op1 * op2;
      break;
  }

  // converte para string (formato da impressao)
  sValor[0] = (valor + 48);
  sValor[1] = '\n';
}

int main() {
    // le string de entrada com operacao
    int nBytes = read(0, operacao, 5);
    resolve_operacao();

    // imprime string de resultado
    write(1, sValor, 2);
    return 0;
}


void _start()
{
  int ret_code = main();
  exit(ret_code);
}
