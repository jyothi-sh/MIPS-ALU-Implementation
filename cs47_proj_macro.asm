# Add you macro definition here - do not touch cs47_common_macro.asm"
#<------------------ MACRO DEFINITIONS ---------------------->#

	#macro extract_nth_bit
	    #$regVal: will contain 0 or 1 depending on bit value of nth bit (regD)
	    #regSourceBit: source bit pattern (regS)
	    #regPos: bit postion you want to extract from (between 0 and 31) (regT)
	#Usage: extracts the bit from nth position
	.macro extract_nth_bit ($regVal, $regSourceBit, $regPos) 
	#move content of $regSourceBit to $s0 so that $regSourceBit value isn't manipulated directly
	move $s0, $regSourceBit		
	#shifts to right based on position of bit that is being extracted
	srav $s0, $s0, $regPos 	
	#will use "AND" operation with 1 and extracted bit, resulting in 1 or 0
	and $regVal, $s0, 1	
	.end_macro
	
	
	#macro insert_to_nth_bit
	    #$regVal: will contain 0 or 1 depending on bit value of nth bit               
	    #regSourceBit: source bit pattern 						         
	    #regPos: bit postion in which the bit is being inserted (between 0 and 31)   
	    #maskReg: register to hold temporary mask
	#Usage: will insert bit 0 or 1 at nth position of bit pattern
	.macro insert_to_nth_bit ($regVal, $regSourceBit, $regPos, $maskReg)     
	li $maskReg, 1
	#shifts to left based on position of bit that is being added
	sllv $maskReg, $maskReg, $regPos
	#will invert the bit pattern in maskReg (all bits will be 1 except bit at nth position)		
	not $maskReg, $maskReg		
	#performs "AND" operation with inverted mask and the original source bit to reset the nth bit to zero		
	and $regSourceBit, $regSourceBit, $maskReg
	#creates a bit pattern made up of the bit 1 or 0 (depending on what bit is being inserted)	
	sllv $regVal, $regVal,$regPos		
	#performs "OR" operation to create the bit pattern with the inserted nth bit	
	or $regSourceBit, $regSourceBit, $regVal	
	.end_macro 
	
	
	#store RTE - 14 *4 = 56 bytes
	#storing fp, ra, $a0-#a3, $s0-$s7
	.macro store_RTE
	addi	$sp, $sp, -60
	sw	$fp, 60($sp)
	sw	$ra, 56($sp)
	sw	$a0, 52($sp)
	sw	$a1, 48($sp)
	sw	$a2, 44($sp)
	sw	$a3, 40($sp)
	sw	$s0, 36($sp)
	sw	$s1, 32($sp)
	sw	$s2, 28($sp)
	sw	$s3, 24($sp)
	sw	$s4, 20($sp)
	sw	$s5, 16($sp)
	sw	$s6, 12($sp)
	sw	$s7, 8($sp)
	addi	$fp, $sp, 60
	.end_macro 
	
	#restore frame
	.macro restore_RTE
	lw	$fp, 60($sp)
	lw	$ra, 56($sp)
	lw	$a0, 52($sp)
	lw	$a1, 48($sp)
	lw	$a2, 44($sp)
	lw	$a3, 40($sp)
	lw	$s0, 36($sp)
	lw	$s1, 32($sp)
	lw	$s2, 28($sp)
	lw	$s3, 24($sp)
	lw	$s4, 20($sp)
	lw	$s5, 16($sp)
	lw	$s6, 12($sp)
	lw	$s7, 8($sp)
	addi	$sp, $sp, 60
	jr	$ra
	.end_macro 
	
	#Usage: if number is negative, this macro converts it to twos complement
	.macro twos_complement_checker($regS, $regFinal)
	bgt $regS, 0, positive_val
	not $regS, $regS
	#addi $regFinal, $regS, 1
	la $a0, ($regS)
	li $a1, 1
	li $a2, 0
	jal add_sub_logical
	la $regFinal, ($v0)
	j end_checker
	
	positive_val:
		move $regFinal, $regS
	end_checker:
	.end_macro
	
	#Usage: converts number to twos complement regardless of whether or not it is +/-
	.macro twos_complement_convert($regS, $regFinal)
	not $regS, $regS
	la $a0, ($regS)
	li $a1, 1
	li $a2, 0
	jal add_sub_logical
	la $regFinal, ($v0)
	.end_macro
	
	
