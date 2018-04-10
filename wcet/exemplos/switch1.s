	.file	"switch1.ll"
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
	br	$p1, $BB0_9
	nop
$BB0_1:
	addiu	$1, $zero, 0
	sll	$1, $1, 2
	lui	$2, %hi($JTI0_0)
	addu	$1, $1, $2
	lw	$1, %lo($JTI0_0)($1)
	jr	$1
	nop
$BB0_2:
	lw	$1, 4($sp)
	addiu	$1, $1, 1
	j	$BB0_8
	nop
$BB0_3:
	lw	$1, 4($sp)
	addiu	$1, $1, -1
	j	$BB0_8
	nop
$BB0_4:
	lw	$1, 4($sp)
	addiu	$1, $1, 3
	j	$BB0_8
	nop
$BB0_5:
	lw	$1, 4($sp)
	addiu	$1, $1, 4
	j	$BB0_8
	nop
$BB0_6:
	lw	$1, 4($sp)
	addiu	$1, $1, 5
	j	$BB0_8
	nop
$BB0_7:
	lw	$1, 4($sp)
	addiu	$1, $1, 6
$BB0_8:
	sw	$1, 4($sp)
$BB0_9:
	lw	$4, 20($sp)
	addiu	$sp, $sp, 24
	jr	$ra
	nop
$tmp1:
	.size	main, ($tmp1)-main
	.section	.rodata,"a",@progbits
	.align	2
$JTI0_0:
	.long	($BB0_2)
	.long	($BB0_3)
	.long	($BB0_4)
	.long	($BB0_5)
	.long	($BB0_6)
	.long	($BB0_7)


