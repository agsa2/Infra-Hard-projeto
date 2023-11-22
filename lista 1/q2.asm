#Questão 2

.data 
A: .word 7
B: .word 6
C: .word 12

s: .space 3

s_eq:  .asciiz "eq"
s_iso: .asciiz "iso"
s_esc: .asciiz "esc"
s_not: .asciiz "not"

.text
lw $t0, A # valor A
lw $t1, B # valor B
lw $t2, C # valor C
la $t4, s # Endereço da string s

#Somando dois lados do triângulo
add $s0, $t0, $t1 # $s0 recebe a soma de A + B
add $s1, $t0, $t2 # $s1 recebe a soma de A + C 
add $s2, $t1, $t2 # $s3 recebe a soma de B + C 

#Verificando se dois lados são maiores que o terceiro
blt $s0, $t2, naoEhTriangulo # caso (A + B) < C nao e um triangulo
blt $s1, $t1, naoEhTriangulo # caso (A + C) < B nao e um triangulo
blt $s2, $t0, naoEhTriangulo # caso (B + C) < A nao e um triangulo

beq $t0, $t1, AigualB      # if (A == B) vai para branch AigualB
bne $t0, $t1, AdiferenteB  # caso contrario, vai para branch AdiferenteB

AigualB:
beq $t0, $t2, equilatero # Caso A == C tambem, entao o triangulo e equilatero
bne $t0, $t2, isosceles  # se A != C, entao o triangulo e isosceles
 
AdiferenteB:
beq $t0, $t2, isosceles  # se A != B && A == C, entao o triangulo e isosceles
beq $t0, $t1, isosceles  # se (A != B && A != C) mas A == B, entao o triangulo tbm e isosceles
bne $t1, $t2, escaleno   # se chegou ate aqui, entao: A != B, A != C && B != C, portanto, o triangulo e escaleno

#Armazenamento do tipo do triangulo na variavel s
equilatero:
la $t4, s_eq
j fim

isosceles:
la $t4, s_iso
j fim

escaleno:
la $t4, s_esc
j fim

naoEhTriangulo: 
la $t4, s_not

fim:
  
    