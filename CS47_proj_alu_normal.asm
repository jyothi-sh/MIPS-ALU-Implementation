.include "./cs47_proj_macro.asm"
.text
.globl au_normal
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_normal
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_normal:
	beq $a2, 43, add_label	      #goes to add_label if $a2 = '+'
	beq $a2, 45, subtract_label  #goes to subtract_label if $a2 = '-'
	beq $a2, 42, multiply_label  #goes to multiply_label if $a2 = '*'
	beq $a2, 47, divide_label    #goes to divide_label if $a2 = '/'
	
add_label:			#label that will add the two values
	add $v0, $a0, $a1
	jr $ra
	
subtract_label:			#label that will subtract the two values
	sub $v0, $a0, $a1
	jr $ra
	
multiply_label:			#label that will multiply the two values
	mult $a0, $a1
	mflo $v0		#value will be stored in register $v0 and $v1
	mfhi $v1
	jr $ra
	
divide_label:			#label that will divide the two values
	div $a0, $a1
	mflo $v0		#quotient stored in $v0
	mfhi $v1		#remainder stores in $1
	jr $ra


	
	


#+ = 43
#- = 45
#* = 42
#/ = 47
