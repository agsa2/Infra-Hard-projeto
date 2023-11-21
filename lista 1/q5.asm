    .data
input_str:  .space 100      # Espaço para a string de entrada
output_str: .space 100      # Espaço para a string de saída
prompt:     .asciiz "Digite uma string: "
newline:    .asciiz "\n"

    .text
    .globl main

main:
    li $v0, 4           
    la $a0, prompt
    syscall

    # entrada do usuário
    li $v0, 8           
    la $a0, input_str
    li $a1, 100         # Tamanho máximo da string
    syscall

    la $a0, input_str   # Endereço da string de entrada
    la $a1, output_str  # Endereço da string de saída
    li $v1, 0           # Inicializa o contador de letras maiúsculas

    # Loop para percorrer a string de entrada
loop:
    lb $t0, 0($a0)      # Carrega o próximo caractere da string de entrada

    # Verifica se o caractere é nulo (fim da string)
    beq $t0, $zero, end

    # Verifica se o caractere é uma letra maiúscula
    li $t1, 'A'         # Valor ASCII para 'A'
    li $t2, 'Z'         # Valor ASCII para 'Z'
    blt $t0, $t1, not_uppercase
    bgt $t0, $t2, not_uppercase

    # ----- o caractere é uma letra maiúscula
    sb $t0, 0($a1)      # Armazena o caractere na string de saída
    addi $a1, $a1, 1    # Avança para o próximo caractere na string de saída
    addi $v1, $v1, 1    # Incrementa o contador de letras maiúsculas

not_uppercase:
    addi $a0, $a0, 1    # Avança para o próximo caractere na string de entrada
    j loop

end:
    # Adiciona o caractere nulo ao final da string de saída
    sb $zero, 0($a1)

    # Imprime a string de saída
    li $v0, 4          
    la $a0, output_str
    syscall

    li $v0, 4          
    la $a0, newline
    syscall

    # Armazena a quantidade de letras maiúsculas no registrador v1
    move $v0, $v1

    li $v0, 10          # Código do serviço de término do programa
    syscall
