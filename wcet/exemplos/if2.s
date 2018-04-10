	.file	"if2.ll"
	.text
	.globl	main
	.type	main,@function
main:                                   # @main

# BB#0:
	addiu	$sp, $sp, -24
	sw	$zero, 20($sp)
	sw	$4, 16($sp)
	sw	$5, 8($sp)
	addiu	$1, $zero, 1
	sw	$1, 4($sp)
	cmpne	$p1, $zero, $zero
	br	$p1, $BB0_3
	nop
$BB0_1:
	lw	$1, 4($sp)
	cmpgti	$p1, $1, 0
	brf	$p1, $BB0_3
	nop
$BB0_2:
	lw	$1, 4($sp)
	addiu	$1, $1, 1
	j	$BB0_4
	nop
$BB0_3:
	lw	$1, 4($sp)
	addiu	$1, $1, -1
$BB0_4:
	sw	$1, 4($sp)
	lw	$4, 20($sp)
	addiu	$sp, $sp, 24
	jr	$ra
	nop
$tmp1:
	.size	main, ($tmp1)-main


