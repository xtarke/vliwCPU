	.file	"loop2.ll"
	.text
	.globl	main
	.type	main,@function
main:                                   # @main

# BB#0:
	addiu	$sp, $sp, -16
	sw	$zero, 12($sp)
	sw	$zero, 8($sp)
	addiu	$1, $zero, 10
	sw	$1, 4($sp)
	j	$BB0_2
	nop
$BB0_1:                                 #   in Loop: Header=BB0_2 Depth=1
	lw	$1, 8($sp)
	addiu	$1, $1, 1
	sw	$1, 8($sp)
$BB0_2:                                 # =>This Inner Loop Header: Depth=1
	lw	$1, 4($sp)
	addiu	$2, $1, -1
	sw	$2, 4($sp)
	cmplti	$p1, $1, 1
	brf	$p1, $BB0_1
	nop
$BB0_3:
	addiu	$4, $zero, 0
	addiu	$sp, $sp, 16
	jr	$ra
	nop
$tmp1:
	.size	main, ($tmp1)-main


