# Grupo 05 - Lista 1
# Questão 6

.data

.text
# Read a and b values
li $v0, 5
syscall
add $t0, $v0, $zero 		# Read a and put in t0

blt $t0, $zero, NEGATIVE_A 	# If a < 0, store 1 in $v1 and end program

li $v0, 5
syscall
add $t1, $v0, $zero 		# Read b and put in t1

add $t2, $zero, $zero		# Store an aux i in t2
jal RECURSIVE_DIV

li $v0, 1
syscall				# Print a % b
j END

NEGATIVE_A:
addi $v1, $zero, 1 		# Store 1 in $v1
j END

RECURSIVE_DIV:
# Considerating $t0 = a; $t1 = b; $t2 = i = result; $a0 = mod
add $a0, $t0, $zero
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