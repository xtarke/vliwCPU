	.file	"loop-grande1.ll"
	.text
	.globl	main
	.type	main,@function
main:                                   # @main

# BB#0:
	addiu	$sp, $sp, -16
	sw	$zero, 12($sp)
	sw	$zero, 8($sp)
	sw	$zero, 4($sp)
	sw	$zero, 0($sp)
	sw	$zero, 8($sp)
	j	$BB0_2
	nop
$BB0_1:                                 #   in Loop: Header=BB0_2 Depth=1
	lw	$1, 4($sp)
	addiu	$2, $1, 2
	sw	$2, 4($sp)
	addiu	$1, $1, 5
	sw	$1, 4($sp)
	lw	$1, 0($sp)
	addiu	$2, $1, 4
	sw	$2, 0($sp)
	addiu	$1, $1, 9
	sw	$1, 0($sp)
	lw	$1, 4($sp)
	addiu	$2, $1, 6
	sw	$2, 4($sp)
	addiu	$1, $1, 13
	sw	$1, 4($sp)
	lw	$1, 0($sp)
	addiu	$2, $1, 8
	sw	$2, 0($sp)
	addiu	$1, $1, 17
	sw	$1, 0($sp)
	lw	$1, 8($sp)
	addiu	$1, $1, 1
	sw	$1, 8($sp)
$BB0_2:                                 # =>This Inner Loop Header: Depth=1
	lw	$1, 8($sp)
	cmpgti	$p1, $1, 4
	brf	$p1, $BB0_1
	nop
$BB0_3:
	lw	$4, 12($sp)
	addiu	$sp, $sp, 16
	jr	$ra
	nop
$tmp1:
	.size	main, ($tmp1)-main


