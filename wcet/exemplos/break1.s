	.file	"break1.ll"
	.text
	.globl	main
	.type	main,@function
main:                                   # @main

# BB#0:
	addiu	$sp, $sp, -16
	sw	$zero, 12($sp)
	sw	$zero, 8($sp)
	addiu	$1, $zero, 5
	sw	$1, 4($sp)
	sw	$zero, 8($sp)
	cmpne	$p1, $zero, $zero
	cmpeq	$p2, $zero, $zero
	j	$BB0_2
	nop
$BB0_1:                                 #   in Loop: Header=BB0_2 Depth=1
	lw	$1, 8($sp)
	addiu	$1, $1, 1
	sw	$1, 8($sp)
$BB0_2:                                 # =>This Inner Loop Header: Depth=1
	lw	$1, 8($sp)
	cmpgti	$p4, $1, 4
	cmpne	$p3, $zero, $zero
	orl	$p3, $p1, $p3
	br	$p4, $BB0_4
	nop
$BB0_3:                                 #   in Loop: Header=BB0_2 Depth=1
	lw	$1, 4($sp)
	lw	$2, 8($sp)
	cmplt	$p3, $2, $1
$BB0_4:                                 #   in Loop: Header=BB0_2 Depth=1
	nandl	$p3, $p3, $p2
	br	$p3, $BB0_6
	nop
$BB0_5:                                 #   in Loop: Header=BB0_2 Depth=1
	lw	$1, 8($sp)
	cmpgti	$p3, $1, 3
	brf	$p3, $BB0_1
	nop
$BB0_6:
	lw	$4, 12($sp)
	addiu	$sp, $sp, 16
	jr	$ra
	nop
$tmp1:
	.size	main, ($tmp1)-main


