.data
array: .word 0, 2, 3, 4
n:  .word 0

.text
#carregando o endereço base do array
la $t0, array
li $t1, 0
li $t4, 5 #carregando valor 5 para marcar o final do array
lw $t2, n #carregando o valor de n em t2

Loop: 
addi $t1, $t1, 1                #posição do array
lw $t3, 0($t0)                  #carregando valor do array em t3
beq $t3, $t2, Encontrado        #Comparando se os valores são iguais
beq $t1, $t4, NaoEncontrado   #Caso o valor não seja encontrado
addi $t0, $t0, 4                #Indo para a proxima posição do array
j Loop


Encontrado: 
li $v0, 1
add $v1, $t1, $zero #carregando o indice do array em v1
j Fim

NaoEncontrado:
li $v1, 2
j Fim

Fim:
li $v0, 10
syscall






