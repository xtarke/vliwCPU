	.file	"insertsort.ll"
	.text
	.globl	main
	.type	main,@function
main:                                   # @main

# BB#0:
	addiu	$sp, $sp, -16
	sw	$zero, 12($sp)
	lui	$1, %hi(a)
	sw	$zero, %lo(a)($1)
	addiu	$2, $zero, %lo(a)
	addu	$2, $1, $2
	addiu	$1, $zero, 11
	sw	$1, 4($2)
	addiu	$1, $zero, 10
	sw	$1, 8($2)
	addiu	$1, $zero, 9
	sw	$1, 12($2)
	addiu	$1, $zero, 8
	sw	$1, 16($2)
	addiu	$1, $zero, 7
	sw	$1, 20($2)
	addiu	$1, $zero, 2
	addiu	$3, $zero, 3
	addiu	$4, $zero, 4
	addiu	$5, $zero, 5
	addiu	$6, $zero, 6
	sw	$6, 24($2)
	sw	$5, 28($2)
	sw	$4, 32($2)
	sw	$3, 36($2)
	sw	$1, 40($2)
	j	$BB0_2
	nop
$BB0_1:                                 #   in Loop: Header=BB0_2 Depth=1
	lw	$1, 8($sp)
	addiu	$1, $1, 1
$BB0_2:                                 # =>This Loop Header: Depth=1
                                        #     Child Loop BB0_5 Depth 2
	sw	$1, 8($sp)
	lw	$1, 8($sp)
	cmpgti	$p1, $1, 10
	br	$p1, $BB0_6
	nop
$BB0_3:                                 #   in Loop: Header=BB0_2 Depth=1
	lw	$1, 8($sp)
	j	$BB0_5
	nop
$BB0_4:                                 #   in Loop: Header=BB0_5 Depth=2
	lw	$1, 4($sp)
	sll	$1, $1, 2
	addu	$1, $2, $1
	lw	$1, 0($1)
	sw	$1, 0($sp)
	lw	$1, 4($sp)
	sll	$1, $1, 2
	addu	$1, $2, $1
	lw	$3, -4($1)
	sw	$3, 0($1)
	lw	$1, 4($sp)
	sll	$1, $1, 2
	addu	$1, $1, $2
	lw	$3, 0($sp)
	sw	$3, -4($1)
	lw	$1, 4($sp)
	addiu	$1, $1, -1
$BB0_5:                                 #   Parent Loop BB0_2 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	sw	$1, 4($sp)
	lw	$1, 4($sp)
	sll	$1, $1, 2
	addu	$1, $2, $1
	lw	$3, -4($1)
	lw	$1, 0($1)
	cmpge	$p1, $1, $3
	br	$p1, $BB0_1
	nop
$BB0_7:                                 #   in Loop: Header=BB0_5 Depth=2
	j	$BB0_4
	nop
$BB0_6:
	addiu	$4, $zero, 1
	addiu	$sp, $sp, 16
	jr	$ra
	nop
$tmp1:
	.size	main, ($tmp1)-main

	.type	a,@object               # @a
	.comm	a,44,16

