# Grupo 05 - Lista 1
# Questão 1

.data
result_perfect_square: .word 0
result_not_perfect: .word 0

.text
# Load mem positions
la $s0, result_perfect_square
la $s1 result_not_perfect

li $v0, 5 # Prepare input a
syscall # Read a
add $t0, $v0, $zero # Store a in t0
add $t1, $zero, $zero # Store b = 0 in t1

add $t2, $zero, $zero # Start i
j FOR_CHECK
FOR:
mul $t3, $t2, $t2 # i * i
seq $t4, $t3, $t0 # (i*i) == a?
jal IF
addi $t2, $t2, 1 # i++
j FOR_CHECK

IF:
beq $t4, $zero, END_IF # (i*i) != a, so jump do END_IF
addi $t1, $zero, 1     # b = 1
sw $t0, ($s0)          # result_perfect_square = a
j END_FOR		# break

END_IF:
jr $ra # Continue FOR

FOR_CHECK:
bne $t2, 10, FOR # i == 10?

END_FOR:
bne $t1, $zero, NOT_STORE_NP	# b == 0?
sw $t0, ($s1)			# if b == 0 then result_not_perfect = a

NOT_STORE_NP:
bne $t0, $zero, END	# a == 0?
addi $v1, $zero, 1 	# if a == 0 then $v1 = 1

END:
