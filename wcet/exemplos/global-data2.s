	.file	"global-data2.ll"
	.text
	.globl	main
	.type	main,@function
main:                                   # @main

# BB#0:
	lui	$1, %hi(a)
	addiu	$2, $zero, 14
	sw	$2, %lo(a)($1)
	lui	$1, %hi(b)
	addiu	$2, $zero, 15
	sw	$2, %lo(b)($1)
	addiu	$4, $zero, 0
	jr	$ra
	nop
$tmp0:
	.size	main, ($tmp0)-main

	.type	a,@object               # @a
	.data
	.globl	a
	.align	2
a:
	.long	1048575                 # 0xfffff
	.size	a, 4

	.type	b,@object               # @b
	.globl	b
	.align	2
b:
	.long	64764                   # 0xfcfc
	.size	b, 4


