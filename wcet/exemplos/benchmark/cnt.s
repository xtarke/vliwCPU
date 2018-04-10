	.file	"cnt.ll"
	.text
	.globl	main
	.type	main,@function
main:                                   # @main

# BB#0:
	addiu	$sp, $sp, -24
	sw	$ra, 20($sp)            # 4-byte Folded Spill
	sw	$zero, 16($sp)
	jal	InitSeed
	nop
	addiu	$1, $zero, %lo(Array)
	lui	$2, %hi(Array)
	addu	$4, $2, $1
	jal	Test
	nop
	addiu	$4, $zero, 1
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
	addiu	$4, $zero, 0
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
	jal	Initialize
	nop
	addiu	$1, $zero, 1000
	sw	$1, 24($sp)
	sw	$zero, 28($sp)
	lw	$4, 32($sp)
	jal	Sum
	nop
	addiu	$1, $zero, 1500
	sw	$1, 16($sp)
	sw	$zero, 20($sp)
	addiu	$4, $zero, 0
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
	addiu	$16, $zero, 40
	j	$BB3_2
	nop
$BB3_1:                                 #   in Loop: Header=BB3_2 Depth=1
	lw	$1, 20($sp)
	addiu	$1, $1, 1
	sw	$1, 20($sp)
$BB3_2:                                 # =>This Loop Header: Depth=1
                                        #     Child Loop BB3_5 Depth 2
	lw	$1, 20($sp)
	cmpgti	$p1, $1, 9
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
	cmpgti	$p1, $1, 9
	br	$p1, $BB3_1
	nop
$BB3_7:                                 #   in Loop: Header=BB3_5 Depth=2
	j	$BB3_4
	nop
$BB3_6:
	addiu	$4, $zero, 0
	lw	$16, 32($sp)            # 4-byte Folded Reload
	lw	$ra, 36($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 40
	jr	$ra
	nop
$tmp9:
	.size	Initialize, ($tmp9)-Initialize

	.globl	Sum
	.type	Sum,@function
Sum:                                    # @Sum

# BB#0:
	addiu	$sp, $sp, -32
	sw	$4, 24($sp)
	sw	$zero, 12($sp)
	sw	$zero, 8($sp)
	sw	$zero, 4($sp)
	sw	$zero, 0($sp)
	sw	$zero, 20($sp)
	addiu	$2, $zero, 40
	j	$BB4_2
	nop
$BB4_1:                                 #   in Loop: Header=BB4_2 Depth=1
	lw	$1, 20($sp)
	addiu	$1, $1, 1
	sw	$1, 20($sp)
$BB4_2:                                 # =>This Loop Header: Depth=1
                                        #     Child Loop BB4_5 Depth 2
	lw	$1, 20($sp)
	cmpgti	$p1, $1, 9
	br	$p1, $BB4_9
	nop
$BB4_3:                                 #   in Loop: Header=BB4_2 Depth=1
	sw	$zero, 16($sp)
	j	$BB4_5
	nop
$BB4_4:                                 #   in Loop: Header=BB4_5 Depth=2
	lw	$1, 16($sp)
	addiu	$1, $1, 1
	sw	$1, 16($sp)
$BB4_5:                                 #   Parent Loop BB4_2 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	lw	$1, 16($sp)
	cmpgti	$p1, $1, 9
	br	$p1, $BB4_1
	nop
$BB4_6:                                 #   in Loop: Header=BB4_5 Depth=2
	lw	$1, 20($sp)
	mul	$1, $1, $2
	lw	$3, 24($sp)
	addu	$1, $3, $1
	lw	$3, 16($sp)
	sll	$3, $3, 2
	addu	$1, $1, $3
	lw	$1, 0($1)
	cmpgti	$p1, $1, -1
	br	$p1, $BB4_8
	nop
$BB4_7:                                 #   in Loop: Header=BB4_5 Depth=2
	lw	$1, 20($sp)
	mul	$1, $1, $2
	lw	$3, 24($sp)
	addu	$1, $3, $1
	lw	$3, 16($sp)
	sll	$3, $3, 2
	addu	$1, $1, $3
	lw	$1, 0($1)
	lw	$3, 12($sp)
	addu	$1, $3, $1
	sw	$1, 12($sp)
	lw	$1, 4($sp)
	addiu	$1, $1, 1
	sw	$1, 4($sp)
	j	$BB4_4
	nop
$BB4_8:                                 #   in Loop: Header=BB4_5 Depth=2
	lw	$1, 20($sp)
	mul	$1, $1, $2
	lw	$3, 24($sp)
	addu	$1, $3, $1
	lw	$3, 16($sp)
	sll	$3, $3, 2
	addu	$1, $1, $3
	lw	$1, 0($1)
	lw	$3, 8($sp)
	addu	$1, $3, $1
	sw	$1, 8($sp)
	lw	$1, 0($sp)
	addiu	$1, $1, 1
	sw	$1, 0($sp)
	j	$BB4_4
	nop
$BB4_9:
	lw	$1, 12($sp)
	lui	$2, %hi(Postotal)
	sw	$1, %lo(Postotal)($2)
	lui	$1, %hi(Poscnt)
	lw	$2, 4($sp)
	sw	$2, %lo(Poscnt)($1)
	lui	$1, %hi(Negtotal)
	lw	$2, 8($sp)
	sw	$2, %lo(Negtotal)($1)
	lui	$1, %hi(Negcnt)
	lw	$2, 0($sp)
	sw	$2, %lo(Negcnt)($1)
	addiu	$sp, $sp, 32
	jr	$ra
	nop
$tmp11:
	.size	Sum, ($tmp11)-Sum

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

	.type	Array,@object           # @Array
	.comm	Array,400,16
	.type	Seed,@object            # @Seed
	.comm	Seed,4,4
	.type	Postotal,@object        # @Postotal
	.comm	Postotal,4,4
	.type	Poscnt,@object          # @Poscnt
	.comm	Poscnt,4,4
	.type	Negtotal,@object        # @Negtotal
	.comm	Negtotal,4,4
	.type	Negcnt,@object          # @Negcnt
	.comm	Negcnt,4,4

