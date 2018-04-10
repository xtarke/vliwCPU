	.file	"array1.ll"
	.text
	.globl	main
	.type	main,@function
main:                                   # @main

# BB#0:
	addiu	$sp, $sp, -16
	lui	$1, %hi(a)
	sw	$zero, %lo(a)($1)
	addiu	$4, $zero, 0
	addiu	$sp, $sp, 16
	jr	$ra
	nop
$tmp1:
	.size	main, ($tmp1)-main

	.type	a,@object               # @a
	.comm	a,44,16

