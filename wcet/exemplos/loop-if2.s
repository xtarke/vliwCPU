	.file	"loop-if2.ll"
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
	sw	$zero, 0($sp)
	sw	$zero, 0($sp)
	j	$BB0_2
	nop
$BB0_1:                                 #   in Loop: Header=BB0_2 Depth=1
	sw	$1, 4($sp)
	lw	$1, 0($sp)
	addiu	$1, $1, 1
	sw	$1, 0($sp)
$BB0_2:                                 # =>This Inner Loop Header: Depth=1
	lw	$1, 0($sp)
	cmpgti	$p1, $1, 4
	br	$p1, $BB0_6
	nop
$BB0_3:                                 #   in Loop: Header=BB0_2 Depth=1
	lw	$1, 4($sp)
	cmpgti	$p1, $1, 5
	br	$p1, $BB0_5
	nop
$BB0_4:                                 #   in Loop: Header=BB0_2 Depth=1
	lw	$1, 4($sp)
	addiu	$2, $1, 1
	sw	$2, 4($sp)
	addiu	$2, $1, 2
	sw	$2, 4($sp)
	addiu	$2, $1, 4
	sw	$2, 4($sp)
	addiu	$1, $1, 7
	j	$BB0_1
	nop
$BB0_5:                                 #   in Loop: Header=BB0_2 Depth=1
	lw	$1, 4($sp)
	addiu	$2, $1, -1
	sw	$2, 4($sp)
	addiu	$2, $1, -2
	sw	$2, 4($sp)
	addiu	$2, $1, -4
	sw	$2, 4($sp)
	addiu	$1, $1, -7
	j	$BB0_1
	nop
$BB0_6:
	lw	$4, 20($sp)
	addiu	$sp, $sp, 24
	jr	$ra
	nop
$tmp1:
	.size	main, ($tmp1)-main


