	.file	"loop-simples1.ll"
	.text
	.globl	main
	.type	main,@function
main:                                   # @main

# BB#0:
	addiu	$sp, $sp, -8
	sw	$zero, 4($sp)
	sw	$zero, 0($sp)
	sw	$zero, 0($sp)
	j	$BB0_2
	nop
$BB0_1:                                 #   in Loop: Header=BB0_2 Depth=1
	lw	$1, 0($sp)
	addiu	$1, $1, 1
	sw	$1, 0($sp)
$BB0_2:                                 # =>This Inner Loop Header: Depth=1
	lw	$1, 0($sp)
	cmpgti	$p1, $1, 99
	brf	$p1, $BB0_1
	nop
$BB0_3:
	lw	$4, 4($sp)
	addiu	$sp, $sp, 8
	jr	$ra
	nop
$tmp1:
	.size	main, ($tmp1)-main


