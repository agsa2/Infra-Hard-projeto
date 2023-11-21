    .data
input_str:  .space 100      # Espa�o para a string de entrada
output_str: .space 100      # Espa�o para a string de sa�da
prompt:     .asciiz "Digite uma string: "
newline:    .asciiz "\n"

    .text
    .globl main

main:
    li $v0, 4           
    la $a0, prompt
    syscall

    # entrada do usu�rio
    li $v0, 8           
    la $a0, input_str
    li $a1, 100         # Tamanho m�ximo da string
    syscall

    la $a0, input_str   # Endere�o da string de entrada
    la $a1, output_str  # Endere�o da string de sa�da
    li $v1, 0           # Inicializa o contador de letras mai�sculas

    # Loop para percorrer a string de entrada
loop:
    lb $t0, 0($a0)      # Carrega o pr�ximo caractere da string de entrada

    # Verifica se o caractere � nulo (fim da string)
    beq $t0, $zero, end

    # Verifica se o caractere � uma letra mai�scula
    li $t1, 'A'         # Valor ASCII para 'A'
    li $t2, 'Z'         # Valor ASCII para 'Z'
    blt $t0, $t1, not_uppercase
    bgt $t0, $t2, not_uppercase

    # ----- o caractere � uma letra mai�scula
    sb $t0, 0($a1)      # Armazena o caractere na string de sa�da
    addi $a1, $a1, 1    # Avan�a para o pr�ximo caractere na string de sa�da
    addi $v1, $v1, 1    # Incrementa o contador de letras mai�sculas

not_uppercase:
    addi $a0, $a0, 1    # Avan�a para o pr�ximo caractere na string de entrada
    j loop

end:
    # Adiciona o caractere nulo ao final da string de sa�da
    sb $zero, 0($a1)

    # Imprime a string de sa�da
    li $v0, 4          
    la $a0, output_str
    syscall

    li $v0, 4          
    la $a0, newline
    syscall

    # Armazena a quantidade de letras mai�sculas no registrador v1
    move $v0, $v1

    li $v0, 10          # C�digo do servi�o de t�rmino do programa
    syscall
