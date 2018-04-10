	.file	"cover.ll"
	.text
	.globl	swi120
	.type	swi120,@function
swi120:                                 # @swi120

# BB#0:
	addiu	$sp, $sp, -8
	sw	$4, 4($sp)
	sw	$zero, 0($sp)
	lui	$2, %hi($JTI0_0)
	j	$BB0_2
	nop
$BB0_1:                                 #   in Loop: Header=BB0_2 Depth=1
	sw	$1, 4($sp)
	lw	$1, 0($sp)
	addiu	$1, $1, 1
	sw	$1, 0($sp)
$BB0_2:                                 # =>This Inner Loop Header: Depth=1
	lw	$1, 0($sp)
	cmpgti	$p1, $1, 119
	br	$p1, $BB0_7
	nop
$BB0_3:                                 #   in Loop: Header=BB0_2 Depth=1
	lw	$3, 0($sp)
	cmpgti	$p1, $3, 119
	brf	$p1, $BB0_5
	nop
$BB0_4:                                 #   in Loop: Header=BB0_2 Depth=1
	lw	$1, 4($sp)
	addiu	$1, $1, -1
	j	$BB0_1
	nop
$BB0_5:                                 #   in Loop: Header=BB0_2 Depth=1
	sll	$1, $3, 2
	addu	$1, $1, $2
	lw	$1, %lo($JTI0_0)($1)
	jr	$1
	nop
$BB0_6:                                 #   in Loop: Header=BB0_2 Depth=1
	lw	$1, 4($sp)
	addiu	$1, $1, 1
	j	$BB0_1
	nop
$BB0_7:
	lw	$4, 4($sp)
	addiu	$sp, $sp, 8
	jr	$ra
	nop
$tmp1:
	.size	swi120, ($tmp1)-swi120
	.section	.rodata,"a",@progbits
	.align	2
$JTI0_0:
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)
	.long	($BB0_6)

	.text
	.globl	swi50
	.type	swi50,@function
swi50:                                  # @swi50

# BB#0:
	addiu	$sp, $sp, -8
	sw	$4, 4($sp)
	sw	$zero, 0($sp)
	lui	$2, %hi($JTI1_0)
	j	$BB1_2
	nop
$BB1_1:                                 #   in Loop: Header=BB1_2 Depth=1
	sw	$1, 4($sp)
	lw	$1, 0($sp)
	addiu	$1, $1, 1
	sw	$1, 0($sp)
$BB1_2:                                 # =>This Inner Loop Header: Depth=1
	lw	$1, 0($sp)
	cmpgti	$p1, $1, 49
	br	$p1, $BB1_7
	nop
$BB1_3:                                 #   in Loop: Header=BB1_2 Depth=1
	lw	$3, 0($sp)
	cmpgti	$p1, $3, 59
	brf	$p1, $BB1_5
	nop
$BB1_4:                                 #   in Loop: Header=BB1_2 Depth=1
	lw	$1, 4($sp)
	addiu	$1, $1, -1
	j	$BB1_1
	nop
$BB1_5:                                 #   in Loop: Header=BB1_2 Depth=1
	sll	$1, $3, 2
	addu	$1, $1, $2
	lw	$1, %lo($JTI1_0)($1)
	jr	$1
	nop
$BB1_6:                                 #   in Loop: Header=BB1_2 Depth=1
	lw	$1, 4($sp)
	addiu	$1, $1, 1
	j	$BB1_1
	nop
$BB1_7:
	lw	$4, 4($sp)
	addiu	$sp, $sp, 8
	jr	$ra
	nop
$tmp3:
	.size	swi50, ($tmp3)-swi50
	.section	.rodata,"a",@progbits
	.align	2
$JTI1_0:
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)
	.long	($BB1_6)

	.text
	.globl	swi10
	.type	swi10,@function
swi10:                                  # @swi10

# BB#0:
	addiu	$sp, $sp, -8
	sw	$4, 4($sp)
	sw	$zero, 0($sp)
	lui	$2, %hi($JTI2_0)
	j	$BB2_2
	nop
$BB2_1:                                 #   in Loop: Header=BB2_2 Depth=1
	sw	$1, 4($sp)
	lw	$1, 0($sp)
	addiu	$1, $1, 1
	sw	$1, 0($sp)
$BB2_2:                                 # =>This Inner Loop Header: Depth=1
	lw	$1, 0($sp)
	cmpgti	$p1, $1, 9
	br	$p1, $BB2_7
	nop
$BB2_3:                                 #   in Loop: Header=BB2_2 Depth=1
	lw	$3, 0($sp)
	cmpgti	$p1, $3, 9
	brf	$p1, $BB2_5
	nop
$BB2_4:                                 #   in Loop: Header=BB2_2 Depth=1
	lw	$1, 4($sp)
	addiu	$1, $1, -1
	j	$BB2_1
	nop
$BB2_5:                                 #   in Loop: Header=BB2_2 Depth=1
	sll	$1, $3, 2
	addu	$1, $1, $2
	lw	$1, %lo($JTI2_0)($1)
	jr	$1
	nop
$BB2_6:                                 #   in Loop: Header=BB2_2 Depth=1
	lw	$1, 4($sp)
	addiu	$1, $1, 1
	j	$BB2_1
	nop
$BB2_7:
	lw	$4, 4($sp)
	addiu	$sp, $sp, 8
	jr	$ra
	nop
$tmp5:
	.size	swi10, ($tmp5)-swi10
	.section	.rodata,"a",@progbits
	.align	2
$JTI2_0:
	.long	($BB2_6)
	.long	($BB2_6)
	.long	($BB2_6)
	.long	($BB2_6)
	.long	($BB2_6)
	.long	($BB2_6)
	.long	($BB2_6)
	.long	($BB2_6)
	.long	($BB2_6)
	.long	($BB2_6)

	.text
	.globl	main
	.type	main,@function
main:                                   # @main

# BB#0:
	addiu	$sp, $sp, -32
	sw	$ra, 28($sp)            # 4-byte Folded Spill
	sw	$zero, 24($sp)
	sw	$zero, 20($sp)
	lw	$4, 20($sp)
	jal	swi10
	nop
	sw	$4, 20($sp)
	lw	$4, 20($sp)
	jal	swi50
	nop
	sw	$4, 20($sp)
	lw	$4, 20($sp)
	jal	swi120
	nop
	sw	$4, 20($sp)
	lw	$4, 20($sp)
	lw	$ra, 28($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 32
	jr	$ra
	nop
$tmp8:
	.size	main, ($tmp8)-main


