    .data
seed:   .word 0x0   # inicializa a semente com zero
mult_constant:  .word 1664525
add_constant:   .word 1013904223
newline:        .asciiz "\n"

    .text
    .globl main

main:
    lw $t0, seed

    # Loop para gerar 10 valores
    li $t1, 0         
loop:
    # Calcula seed = seed * mult_constant + add_constant
    lw $t2, mult_constant
    mulu $t3, $t0, $t2  # $t3 = seed * mult_constant
    lw $t2, add_constant
    addu $t0, $t3, $t2   # $t0 = seed * mult_constant + add_constant

    move $a0, $t0      
    li $v0, 1          
    syscall

    li $v0, 4         
    la $a0, newline
    syscall

    addi $t1, $t1, 1

    bne $t1, 10, loop

    li $v0, 10         
    syscall
