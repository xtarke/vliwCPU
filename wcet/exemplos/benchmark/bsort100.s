	.file	"bsort100.ll"
	.text
	.globl	main
	.type	main,@function
main:                                   # @main

# BB#0:
	addiu	$sp, $sp, -40
	sw	$ra, 36($sp)            # 4-byte Folded Spill
	sw	$16, 32($sp)            # 4-byte Folded Spill
	addiu	$1, $zero, %lo(Array)
	lui	$2, %hi(Array)
	addu	$16, $2, $1
	or	$4, $16, $zero
	jal	Initialize
	nop
	or	$4, $16, $zero
	jal	BubbleSort
	nop
	addiu	$4, $zero, 0
	lw	$16, 32($sp)            # 4-byte Folded Reload
	lw	$ra, 36($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 40
	jr	$ra
	nop
$tmp2:
	.size	main, ($tmp2)-main

	.globl	Initialize
	.type	Initialize,@function
Initialize:                             # @Initialize

# BB#0:
	addiu	$sp, $sp, -16
	sw	$4, 8($sp)
	lui	$1, %hi(factor)
	addiu	$2, $zero, -1
	sw	$2, %lo(factor)($1)
	sw	$2, 0($sp)
	addiu	$1, $zero, 1
	sw	$1, 4($sp)
	addiu	$2, $zero, 500
	j	$BB1_2
	nop
$BB1_1:                                 #   in Loop: Header=BB1_2 Depth=1
	lw	$3, 4($sp)
	subu	$1, $2, $3
	sll	$3, $3, 2
	lw	$4, 8($sp)
	addu	$3, $4, $3
	sw	$1, 0($3)
	lw	$1, 4($sp)
	addiu	$1, $1, 1
	sw	$1, 4($sp)
$BB1_2:                                 # =>This Inner Loop Header: Depth=1
	lw	$1, 4($sp)
	cmpgti	$p1, $1, 100
	brf	$p1, $BB1_1
	nop
$BB1_3:
	lw	$4, 12($sp)
	addiu	$sp, $sp, 16
	jr	$ra
	nop
$tmp4:
	.size	Initialize, ($tmp4)-Initialize

	.globl	BubbleSort
	.type	BubbleSort,@function
BubbleSort:                             # @BubbleSort

# BB#0:
	addiu	$sp, $sp, -32
	sw	$4, 24($sp)
	sw	$zero, 20($sp)
	addiu	$2, $zero, 1
	sw	$2, 4($sp)
	addiu	$3, $zero, 100
	j	$BB2_2
	nop
$BB2_1:                                 #   in Loop: Header=BB2_2 Depth=1
	lw	$1, 4($sp)
	addiu	$1, $1, 1
	sw	$1, 4($sp)
$BB2_2:                                 # =>This Loop Header: Depth=1
                                        #     Child Loop BB2_5 Depth 2
	lw	$1, 4($sp)
	cmpgti	$p1, $1, 99
	br	$p1, $BB2_10
	nop
$BB2_3:                                 #   in Loop: Header=BB2_2 Depth=1
	sw	$2, 20($sp)
	sw	$2, 8($sp)
	j	$BB2_5
	nop
$BB2_4:                                 #   in Loop: Header=BB2_5 Depth=2
	lw	$1, 8($sp)
	addiu	$1, $1, 1
	sw	$1, 8($sp)
$BB2_5:                                 #   Parent Loop BB2_2 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	lw	$1, 8($sp)
	cmpgti	$p1, $1, 99
	br	$p1, $BB2_9
	nop
$BB2_6:                                 #   in Loop: Header=BB2_5 Depth=2
	lw	$1, 4($sp)
	subu	$1, $3, $1
	lw	$4, 8($sp)
	cmpgt	$p1, $4, $1
	br	$p1, $BB2_9
	nop
$BB2_7:                                 #   in Loop: Header=BB2_5 Depth=2
	lw	$1, 8($sp)
	sll	$1, $1, 2
	lw	$4, 24($sp)
	addu	$1, $4, $1
	lw	$4, 4($1)
	lw	$1, 0($1)
	cmple	$p1, $1, $4
	br	$p1, $BB2_4
	nop
$BB2_8:                                 #   in Loop: Header=BB2_5 Depth=2
	lw	$1, 8($sp)
	sll	$1, $1, 2
	lw	$4, 24($sp)
	addu	$1, $4, $1
	lw	$1, 0($1)
	sw	$1, 16($sp)
	lw	$1, 8($sp)
	sll	$1, $1, 2
	lw	$4, 24($sp)
	addu	$1, $4, $1
	lw	$4, 4($1)
	sw	$4, 0($1)
	lw	$1, 8($sp)
	sll	$1, $1, 2
	lw	$4, 24($sp)
	addu	$1, $1, $4
	lw	$4, 16($sp)
	sw	$4, 4($1)
	sw	$zero, 20($sp)
	j	$BB2_4
	nop
$BB2_9:                                 #   in Loop: Header=BB2_2 Depth=1
	lw	$1, 20($sp)
	cmpnei	$p1, $1, 0
	brf	$p1, $BB2_1
	nop
$BB2_10:
	lw	$4, 28($sp)
	addiu	$sp, $sp, 32
	jr	$ra
	nop
$tmp6:
	.size	BubbleSort, ($tmp6)-BubbleSort

	.type	Array,@object           # @Array
	.comm	Array,404,16
	.type	factor,@object          # @factor
	.comm	factor,4,4
	.type	Seed,@object            # @Seed
	.comm	Seed,4,4

