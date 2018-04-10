	.file	"pred_test.ll"
	.text
	.globl	equal
	.type	equal,@function
equal:                                  # @equal

# BB#0:
	addiu	$sp, $sp, -8
	sw	$4, 4($sp)
	sw	$5, 0($sp)
	lw	$1, 4($sp)
	cmpeq	$p1, $1, $5
	pmov	$4, $p1
	addiu	$sp, $sp, 8
	jr	$ra
	nop
$tmp1:
	.size	equal, ($tmp1)-equal

	.globl	main
	.type	main,@function
main:                                   # @main

# BB#0:
	addiu	$sp, $sp, -24
	sw	$ra, 20($sp)            # 4-byte Folded Spill
	addiu	$4, $zero, 5
	addiu	$5, $zero, 6
	jal	equal
	nop
	addiu	$4, $zero, 0
	lw	$ra, 20($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 24
	jr	$ra
	nop
$tmp4:
	.size	main, ($tmp4)-main


