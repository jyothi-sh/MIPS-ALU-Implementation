.include "./cs47_proj_macro.asm"
.include "./cs47_common_macro.asm"
.text
.globl au_logical
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_logical
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_logical:
	store_RTE
	beq	$a2, 43, add_logical 	#goes to add_label if $a2 = '+'
	beq	$a2, 45, sub_logical 	#goes to subtract_label if $a2 = '-'
	beq	$a2, 42, mul_logic	#goes to multiply_label if $a2 = '*'
	beq 	$a2, 47, div_logic	#goes to divide_label if $a2 = '/'

add_logical:
	store_RTE
	li $a2, 0x00000000	#load 0 into $a2
	jal add_sub_logical	#jump and link to add_sub_logic
	restore_RTE
	
sub_logical:
	store_RTE
	li $a2, 0xFFFFFFFF	#load 0xFFFFFFFF into $a2
	jal add_sub_logical	#jump and link to add_sub_logic
	restore_RTE
	
	
add_sub_logical:
	store_RTE
	add $t0, $zero, $zero 	# ($t0 = index) set to 0
	add $t1,$zero, $zero 	# ($t1 = sum) set to 0
	add $t2, $zero, $zero	# ($t2 = carry) bit initialized at 0
	beq $a2, 0x00000000, add_loop	#if $a2 is 0, go directly to add_loop
	beq $a2, 0xFFFFFFFF, subtraction  #if $a2 is not 0, needs to go to subtraction 
	
	
subtraction:
	not $a1, $a1
	add $t2,$t2,1
add_loop:
	beq $t0, 32, exit_loop	#if index = 32, exits loop
	extract_nth_bit($t3, $a0,$t0)	#extracts nth bit of first number (based on index the counter is on)
	extract_nth_bit ($t4, $a1, $t0)	#extracts nth bit of second number
	#to find the Y (nth bit that is inserted)
	xor $t5, $t3, $t4	#performs xor on the nth bits of the two numbers
	xor $t6, $t5, $t2	#performs xor on result of last line with the carry bit 
	insert_to_nth_bit($t6, $t1, $t0, $t7) 
	#to find the carry out
	and $t7, $t5, $t2	#and operation with the xor of the nth bits of the two numbers with the carry bit
	and $t6, $t3, $t4	#and operation on nth bits of the two numbers
	or $t2, $t7, $t6	#or operation with $t7 and $t6
	addi $t0, $t0, 0x1	#increment index by 1
	j add_loop		#loop again

exit_loop:			#comes here when loop is over (index = 32)
	la $v0, ($t1)		#loads sum to $v0
	la $v1, ($t2)		#carry bit stored in $v1 (used in twos_complement_64_bit)
	restore_RTE


twos_complement:
#use add_logical and "not"
#compute "not $a0" + 1
	store_RTE
	not $a0, $a0	#performs not on first number
	li $a1, 1	#sets second number to 1
	li $a2, 0
	j add_sub_logical	#goes to loop

twos_complement_if_negative:
#use twos_complement
	store_RTE
	#if $a0 !< 0, value in $a0 will be passed into $v0
	move $v0, $a0	
	#branch to twos_complement if $a0 < 0
	blt $a0, $zero, twos_complement	
	restore_RTE

bit_replicator:
	store_RTE
	#branches to zero_bit_replicator if $a0 holds value  of 0
	beq $a0, 0x0, zero_bit_replicator	
	#if $a0 != 0, $v0 should hold value 0xFFFFFFFF
	li $v0, 0xFFFFFFFF			
	restore_RTE
	
zero_bit_replicator:
	li $v0, 0x00000000		
	restore_RTE
	
mul_logic:
	store_RTE
	move $s4, $zero	# INDEX
	move $s1, $zero # s1 = HI
	move $s2, $a1 # MPLR = LO
	move $t8,$s2 # untransformed $a1 (lo)
	move $s3, $a0 # MCND 
	move $t9, $s3 # untransformed $a0 (MCND)
	twos_complement_checker($s2, $s2)
	twos_complement_checker($s3, $s3)
	

mul_loop:
	beq $s4, 32, exit_mul_loop	#if index = 32, exits loop
	extract_nth_bit($a0, $s2, $zero) # a0 = L[0] = MPLR[0]
	jal bit_replicator # result should be in $v0
	and $t0, $s3, $v0 # x = M & R ; $t0 = X
	move $a0, $s1 # $a0 = HI
	move $a1, $t0 # $a1 = X
	li $a2, 0
	jal add_sub_logical # H = H + X --> result stored in $v0
	move $s1, $v0 # update hi
	sra $s2, $s2, 1 # L >> 1 ; $S2 = L
	extract_nth_bit($t1,$s1,$zero) # $t1 = H[0]
	li $t2, 31 # setting up for insertion (L[32])
	insert_to_nth_bit($t1, $s2, $t2, $t3) # L[31] = h[0] ; $T3 = mask
	sra $s1, $s1, 1 # HI >> 1 ; $S1 = HI
	addi $s4, $s4, 1 # I = I + 1
	j mul_loop

twos_complement_64_bit:
	store_RTE
	not $a0, $a0
	not $s0, $a1
	li $a2, 0
	li $a1, 1
	jal add_sub_logical
	move $s3, $v0
	move $a0, $s0
	move $a1, $v1
	jal add_sub_logical
	move $v1, $v0
	move $v0, $s3
	restore_RTE #Macro call to restore frame

exit_mul_loop:
	move $v0, $s2
	move $v1, $s1
	li $t0, 31
	extract_nth_bit($t1, $t8, $t0)
	extract_nth_bit($t2, $t9, $t0)
	xor $t0, $t1, $t2
	beqz $t0, done
	move $a0, $v0
	move $a1, $v1
	jal twos_complement_64_bit

done: 
	restore_RTE
#------------------------------------------------------------------------------------------------------------
div_logic:
	store_RTE
	move $s1, $zero # ($t0 = index) set to 0
	move $s2, $a0	#Q = DVND
	move $s3, $a1	#D = DVSR
	move $s4, $zero #R = 0
	move $t8, $a0 # untransformed $a0
	move $t9, $a1 # untransformed $a1
	twos_complement_checker($s2, $s2)
	twos_complement_checker($s3,$s3)
	
div_unsigned:
	sll $s4, $s4, 1 # R<<1
	li $t4, 31
	extract_nth_bit($t5, $s2, $t4) # Q[31]
	insert_to_nth_bit($t5,$s4, $zero, $t6) # R[0] = Q[31]
	sll $s2, $s2, 1 # Q << 1
	la $a0, ($s4)
	la $a1, ($s3) 
	li $a2, 0XFFFFFFFF
	jal add_sub_logical # S = R-D
	move $s5, $v0 # $t7 = S (R-D)
	bltz $s5, extra_step # if S < 0 --> go to extra step
	move $s4, $s5 # R = S
	li $s7, 1
	insert_to_nth_bit($s7, $s2, $zero, $t6)

extra_step: 
	addi $s1, $s1, 1
	beq $s1, 32, div_done
	j div_unsigned

div_done:
	# ---- determine signs of Q and R, etc.
	li $t0, 31
	# Q
	extract_nth_bit($t1, $t8, $t0)
	extract_nth_bit($t2, $t9, $t0)
	xor $t0, $t1, $t2 # $t0 = S of Q
	move $s0, $t1
	beq $t0, 1, sign_q
	j check_r
	
sign_q: 
	twos_complement_convert($s2,$s2)
	
check_r:
	beq $s0, 1, sign_r	
	j finish

sign_r:	
	twos_complement_convert($s4,$s4)
	
finish:
	move $v0, $s2
	move $v1, $s4
	restore_RTE

