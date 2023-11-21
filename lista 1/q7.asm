# Grupo 05 - Lista 1
# Questão 7

.data
RESULT: 	.word 0
REMAINDER: 	.word 0

.text
# Load result and remainder mem positions
la $a0, RESULT
la $a1, REMAINDER

# Read a and b values
li $v0, 5
syscall
add $t0, $v0, $zero 		# Read a and put in t0

li $v0, 5
syscall
add $t1, $v0, $zero 		# Read b and put in t1

add $t2, $zero, $zero		# Store an aux i in t2

# Using $s0 and $s1 to save signal informations and remove signals
slt $s0, $t0, $zero
slt $s1, $t1, $zero

beq $s0, $zero, CHECK_B
sub $t0, $zero, $t0
CHECK_B:
beq $s1, $zero, CONTINUE
sub $t1, $zero, $t1
CONTINUE:

jal RECURSIVE_DIV

# Reconsidere signals
beq $s0, $zero, NEXT_SIGNAL
sub $t0, $zero, $t0
sub $t2, $zero, $t2
NEXT_SIGNAL:
beq $s1, $zero, END
sub $t1, $zero, $t1
sub $t2, $zero, $t2

j END

RECURSIVE_DIV:
# Considerating $t0 = a; $t1 = b; $t2 = i = result; $t3 = mod = remainder
add $t3, $t0, $zero
blt $t0, $t1, END_DIV

addi $sp, $sp, -12		# Store arguments in stack
sw $t0, 8($sp)
sw $t1, 4($sp)
sw $ra, 0($sp)

sub $t0, $t0, $t1		# a = a - b
addi $t2, $t2, 1		# i = i + 1
jal RECURSIVE_DIV

lw $ra, 0($sp)			# Re-Load arguments and reset stack pointer
lw $t1, 4($sp)
lw $t0, 8($sp)
addi $sp, $sp, 12

END_DIV:
jr $ra

END:
# Storing RESULT and REMAINDER on mem
sw $t2, ($a0)
sw $t3, ($a1)