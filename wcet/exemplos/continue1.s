	.file	"continue1.ll"
	.text
	.globl	main
	.type	main,@function
main:                                   # @main

# BB#0:
	addiu	$sp, $sp, -24
	sw	$zero, 20($sp)
	sw	$zero, 16($sp)
	addiu	$1, $zero, 8
	sw	$1, 12($sp)
	addiu	$1, $zero, 4
	sw	$1, 8($sp)
	sw	$zero, 4($sp)
	sw	$zero, 16($sp)
	j	$BB0_2
	nop
$BB0_1:                                 #   in Loop: Header=BB0_2 Depth=1
	lw	$1, 16($sp)
	addiu	$1, $1, 1
	sw	$1, 16($sp)
$BB0_2:                                 # =>This Inner Loop Header: Depth=1
	lw	$1, 16($sp)
	cmpgti	$p1, $1, 9
	br	$p1, $BB0_6
	nop
$BB0_3:                                 #   in Loop: Header=BB0_2 Depth=1
	lw	$1, 4($sp)
	addiu	$1, $1, 2
	sw	$1, 4($sp)
	lw	$1, 12($sp)
	lw	$2, 16($sp)
	cmplt	$p1, $2, $1
	br	$p1, $BB0_1
	nop
$BB0_4:                                 #   in Loop: Header=BB0_2 Depth=1
	lw	$1, 4($sp)
	addiu	$1, $1, 1
	sw	$1, 4($sp)
	lw	$1, 12($sp)
	lw	$2, 16($sp)
	cmplt	$p1, $2, $1
	br	$p1, $BB0_1
	nop
$BB0_5:                                 #   in Loop: Header=BB0_2 Depth=1
	lw	$1, 4($sp)
	addiu	$1, $1, 3
	sw	$1, 4($sp)
	j	$BB0_1
	nop
$BB0_6:
	lw	$4, 20($sp)
	addiu	$sp, $sp, 24
	jr	$ra
	nop
$tmp1:
	.size	main, ($tmp1)-main


