	.file	"matmult.ll"
	.text
	.globl	main
	.type	main,@function
main:                                   # @main

# BB#0:
	addiu	$sp, $sp, -24
	sw	$ra, 20($sp)            # 4-byte Folded Spill
	jal	InitSeed
	nop
	addiu	$1, $zero, %lo(ArrayA)
	lui	$2, %hi(ArrayA)
	addu	$4, $2, $1
	addiu	$1, $zero, %lo(ArrayB)
	lui	$2, %hi(ArrayB)
	addu	$5, $2, $1
	addiu	$1, $zero, %lo(ResultArray)
	lui	$2, %hi(ResultArray)
	addu	$6, $2, $1
	jal	Test
	nop
	lw	$ra, 20($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 24
	jr	$ra
	nop
$tmp2:
	.size	main, ($tmp2)-main

	.globl	InitSeed
	.type	InitSeed,@function
InitSeed:                               # @InitSeed

# BB#0:
	lui	$1, %hi(Seed)
	sw	$zero, %lo(Seed)($1)
	jr	$ra
	nop
$tmp3:
	.size	InitSeed, ($tmp3)-InitSeed

	.globl	Test
	.type	Test,@function
Test:                                   # @Test

# BB#0:
	addiu	$sp, $sp, -40
	sw	$ra, 36($sp)            # 4-byte Folded Spill
	sw	$4, 32($sp)
	sw	$5, 24($sp)
	sw	$6, 16($sp)
	lw	$4, 32($sp)
	jal	Initialize
	nop
	lw	$4, 24($sp)
	jal	Initialize
	nop
	lw	$6, 16($sp)
	lw	$5, 24($sp)
	lw	$4, 32($sp)
	jal	Multiply
	nop
	lw	$ra, 36($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 40
	jr	$ra
	nop
$tmp6:
	.size	Test, ($tmp6)-Test

	.globl	Initialize
	.type	Initialize,@function
Initialize:                             # @Initialize

# BB#0:
	addiu	$sp, $sp, -40
	sw	$ra, 36($sp)            # 4-byte Folded Spill
	sw	$16, 32($sp)            # 4-byte Folded Spill
	sw	$4, 24($sp)
	sw	$zero, 20($sp)
	addiu	$16, $zero, 80
	j	$BB3_2
	nop
$BB3_1:                                 #   in Loop: Header=BB3_2 Depth=1
	lw	$1, 20($sp)
	addiu	$1, $1, 1
	sw	$1, 20($sp)
$BB3_2:                                 # =>This Loop Header: Depth=1
                                        #     Child Loop BB3_5 Depth 2
	lw	$1, 20($sp)
	cmpgti	$p1, $1, 19
	br	$p1, $BB3_6
	nop
$BB3_3:                                 #   in Loop: Header=BB3_2 Depth=1
	sw	$zero, 16($sp)
	j	$BB3_5
	nop
$BB3_4:                                 #   in Loop: Header=BB3_5 Depth=2
	jal	RandomInteger
	nop
	lw	$1, 20($sp)
	mul	$1, $1, $16
	lw	$2, 24($sp)
	addu	$1, $2, $1
	lw	$2, 16($sp)
	sll	$2, $2, 2
	addu	$1, $1, $2
	sw	$4, 0($1)
	lw	$1, 16($sp)
	addiu	$1, $1, 1
	sw	$1, 16($sp)
$BB3_5:                                 #   Parent Loop BB3_2 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	lw	$1, 16($sp)
	cmpgti	$p1, $1, 19
	br	$p1, $BB3_1
	nop
$BB3_7:                                 #   in Loop: Header=BB3_5 Depth=2
	j	$BB3_4
	nop
$BB3_6:
	lw	$16, 32($sp)            # 4-byte Folded Reload
	lw	$ra, 36($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 40
	jr	$ra
	nop
$tmp9:
	.size	Initialize, ($tmp9)-Initialize

	.globl	Multiply
	.type	Multiply,@function
Multiply:                               # @Multiply

# BB#0:
	addiu	$sp, $sp, -40
	sw	$4, 32($sp)
	sw	$5, 24($sp)
	sw	$6, 16($sp)
	sw	$zero, 12($sp)
	addiu	$2, $zero, 80
	j	$BB4_2
	nop
$BB4_1:                                 #   in Loop: Header=BB4_2 Depth=1
	lw	$1, 12($sp)
	addiu	$1, $1, 1
	sw	$1, 12($sp)
$BB4_2:                                 # =>This Loop Header: Depth=1
                                        #     Child Loop BB4_5 Depth 2
                                        #       Child Loop BB4_8 Depth 3
	lw	$1, 12($sp)
	cmpgti	$p1, $1, 19
	br	$p1, $BB4_9
	nop
$BB4_3:                                 #   in Loop: Header=BB4_2 Depth=1
	sw	$zero, 8($sp)
	j	$BB4_5
	nop
$BB4_4:                                 #   in Loop: Header=BB4_5 Depth=2
	lw	$1, 8($sp)
	addiu	$1, $1, 1
	sw	$1, 8($sp)
$BB4_5:                                 #   Parent Loop BB4_2 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB4_8 Depth 3
	lw	$1, 8($sp)
	cmpgti	$p1, $1, 19
	br	$p1, $BB4_1
	nop
$BB4_6:                                 #   in Loop: Header=BB4_5 Depth=2
	lw	$1, 12($sp)
	mul	$1, $1, $2
	lw	$3, 16($sp)
	addu	$1, $3, $1
	lw	$3, 8($sp)
	sll	$3, $3, 2
	addu	$1, $1, $3
	sw	$zero, 0($1)
	sw	$zero, 4($sp)
	j	$BB4_8
	nop
$BB4_7:                                 #   in Loop: Header=BB4_8 Depth=3
	lw	$3, 4($sp)
	mul	$1, $3, $2
	lw	$4, 24($sp)
	addu	$4, $4, $1
	lw	$1, 8($sp)
	sll	$1, $1, 2
	addu	$4, $4, $1
	lw	$4, 0($4)
	lw	$5, 12($sp)
	mul	$5, $5, $2
	lw	$6, 32($sp)
	addu	$6, $6, $5
	sll	$3, $3, 2
	addu	$3, $6, $3
	lw	$3, 0($3)
	mul	$3, $3, $4
	lw	$4, 16($sp)
	addu	$4, $4, $5
	addu	$1, $4, $1
	lw	$4, 0($1)
	addu	$3, $4, $3
	sw	$3, 0($1)
	lw	$1, 4($sp)
	addiu	$1, $1, 1
	sw	$1, 4($sp)
$BB4_8:                                 #   Parent Loop BB4_2 Depth=1
                                        #     Parent Loop BB4_5 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	lw	$1, 4($sp)
	cmpgti	$p1, $1, 19
	br	$p1, $BB4_4
	nop
$BB4_10:                                #   in Loop: Header=BB4_8 Depth=3
	j	$BB4_7
	nop
$BB4_9:
	addiu	$sp, $sp, 40
	jr	$ra
	nop
$tmp11:
	.size	Multiply, ($tmp11)-Multiply

	.globl	RandomInteger
	.type	RandomInteger,@function
RandomInteger:                          # @RandomInteger

# BB#0:
	lui	$1, %hi(Seed)
	lw	$2, %lo(Seed)($1)
	addiu	$3, $zero, 133
	mul	$2, $2, $3
	addiu	$2, $2, 81
	lui	$3, 4145
	ori	$3, $3, 5319
	mult	$2, $3
	mfhi	$3
	srl	$4, $3, 31
	sra	$3, $3, 9
	addu	$3, $3, $4
	addiu	$4, $zero, 8095
	mul	$3, $3, $4
	subu	$4, $2, $3
	sw	$4, %lo(Seed)($1)
	jr	$ra
	nop
$tmp12:
	.size	RandomInteger, ($tmp12)-RandomInteger

	.type	ArrayA,@object          # @ArrayA
	.comm	ArrayA,1600,16
	.type	ArrayB,@object          # @ArrayB
	.comm	ArrayB,1600,16
	.type	ResultArray,@object     # @ResultArray
	.comm	ResultArray,1600,16
	.type	Seed,@object            # @Seed
	.comm	Seed,4,4

