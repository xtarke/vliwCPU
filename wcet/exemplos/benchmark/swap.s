	.file	"swap.ll"
	.text
	.globl	inc
	.type	inc,@function
inc:                                    # @inc

# BB#0:
	addiu	$sp, $sp, -8
	sw	$4, 0($sp)
	lw	$1, 0($4)
	addiu	$1, $1, 1
	sw	$1, 0($4)
	addiu	$sp, $sp, 8
	jr	$ra
	nop
$tmp1:
	.size	inc, ($tmp1)-inc

	.globl	main
	.type	main,@function
main:                                   # @main

# BB#0:
	addiu	$sp, $sp, -32
	sw	$ra, 28($sp)            # 4-byte Folded Spill
	sw	$zero, 24($sp)
	lui	$1, 7
	ori	$1, $1, 54487
	sw	$1, 20($sp)
	addiu	$4, $sp, 20
	jal	inc
	nop
	addiu	$4, $zero, 0
	lw	$ra, 28($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 32
	jr	$ra
	nop
$tmp4:
	.size	main, ($tmp4)-main


