	.file	"fdct.ll"
	.text
	.globl	fdct
	.type	fdct,@function
fdct:                                   # @fdct

# BB#0:
	addiu	$sp, $sp, -96
	sw	$16, 92($sp)            # 4-byte Folded Spill
	sw	$4, 88($sp)
	sw	$5, 84($sp)
	lw	$1, 88($sp)
	sw	$1, 8($sp)
	sw	$zero, 12($sp)
	addiu	$2, $zero, 4433
	addiu	$3, $zero, 6270
	addiu	$4, $zero, -15137
	addiu	$5, $zero, 9633
	addiu	$6, $zero, -3196
	addiu	$7, $zero, -16069
	addiu	$8, $zero, -20995
	addiu	$9, $zero, -7373
	addiu	$10, $zero, 12299
	addiu	$11, $zero, 25172
	addiu	$12, $zero, 16819
	addiu	$13, $zero, 2446
	j	$BB0_2
	nop
$BB0_1:                                 #   in Loop: Header=BB0_2 Depth=1
	lw	$1, 8($sp)
	lh	$14, 14($1)
	lh	$1, 0($1)
	addu	$1, $1, $14
	sw	$1, 80($sp)
	lw	$1, 8($sp)
	lh	$14, 14($1)
	lh	$1, 0($1)
	subu	$1, $1, $14
	sw	$1, 52($sp)
	lw	$1, 8($sp)
	lh	$14, 12($1)
	lh	$1, 2($1)
	addu	$1, $1, $14
	sw	$1, 76($sp)
	lw	$1, 8($sp)
	lh	$14, 12($1)
	lh	$1, 2($1)
	subu	$1, $1, $14
	sw	$1, 56($sp)
	lw	$1, 8($sp)
	lh	$14, 10($1)
	lh	$1, 4($1)
	addu	$1, $1, $14
	sw	$1, 72($sp)
	lw	$1, 8($sp)
	lh	$14, 10($1)
	lh	$1, 4($1)
	subu	$1, $1, $14
	sw	$1, 60($sp)
	lw	$1, 8($sp)
	lh	$14, 8($1)
	lh	$1, 6($1)
	addu	$1, $1, $14
	sw	$1, 68($sp)
	lw	$1, 8($sp)
	lh	$14, 8($1)
	lh	$1, 6($1)
	subu	$1, $1, $14
	sw	$1, 64($sp)
	lw	$1, 68($sp)
	lw	$14, 80($sp)
	addu	$1, $14, $1
	sw	$1, 48($sp)
	lw	$1, 68($sp)
	lw	$14, 80($sp)
	subu	$1, $14, $1
	sw	$1, 36($sp)
	lw	$1, 72($sp)
	lw	$14, 76($sp)
	addu	$1, $14, $1
	sw	$1, 44($sp)
	lw	$1, 72($sp)
	lw	$14, 76($sp)
	subu	$1, $14, $1
	sw	$1, 40($sp)
	lw	$1, 44($sp)
	lw	$14, 48($sp)
	addu	$1, $14, $1
	sll	$1, $1, 2
	lw	$14, 8($sp)
	sh	$1, 0($14)
	lw	$1, 44($sp)
	lw	$14, 48($sp)
	subu	$1, $14, $1
	sll	$1, $1, 2
	lw	$14, 8($sp)
	sh	$1, 8($14)
	sw	$2, 4($sp)
	lw	$1, 36($sp)
	lw	$14, 40($sp)
	addu	$1, $14, $1
	mul	$1, $1, $2
	sw	$1, 32($sp)
	sw	$3, 4($sp)
	lw	$1, 36($sp)
	mul	$1, $1, $3
	lw	$14, 32($sp)
	addu	$1, $14, $1
	srl	$1, $1, 11
	lw	$14, 8($sp)
	sh	$1, 4($14)
	sw	$4, 4($sp)
	lw	$1, 40($sp)
	mul	$1, $1, $4
	lw	$14, 32($sp)
	addu	$1, $14, $1
	srl	$1, $1, 11
	lw	$14, 8($sp)
	sh	$1, 12($14)
	lw	$1, 52($sp)
	lw	$14, 64($sp)
	addu	$1, $14, $1
	sw	$1, 32($sp)
	lw	$1, 56($sp)
	lw	$14, 60($sp)
	addu	$1, $14, $1
	sw	$1, 28($sp)
	lw	$1, 56($sp)
	lw	$14, 64($sp)
	addu	$1, $14, $1
	sw	$1, 24($sp)
	lw	$1, 52($sp)
	lw	$14, 60($sp)
	addu	$1, $14, $1
	sw	$1, 20($sp)
	sw	$5, 4($sp)
	lw	$1, 20($sp)
	lw	$14, 24($sp)
	addu	$1, $14, $1
	mul	$1, $1, $5
	sw	$1, 16($sp)
	sw	$13, 4($sp)
	lw	$1, 64($sp)
	mul	$1, $1, $13
	sw	$1, 64($sp)
	sw	$12, 4($sp)
	lw	$1, 60($sp)
	mul	$1, $1, $12
	sw	$1, 60($sp)
	sw	$11, 4($sp)
	lw	$1, 56($sp)
	mul	$1, $1, $11
	sw	$1, 56($sp)
	sw	$10, 4($sp)
	lw	$1, 52($sp)
	mul	$1, $1, $10
	sw	$1, 52($sp)
	sw	$9, 4($sp)
	lw	$1, 32($sp)
	mul	$1, $1, $9
	sw	$1, 32($sp)
	sw	$8, 4($sp)
	lw	$1, 28($sp)
	mul	$1, $1, $8
	sw	$1, 28($sp)
	sw	$7, 4($sp)
	lw	$1, 24($sp)
	mul	$1, $1, $7
	sw	$1, 24($sp)
	sw	$6, 4($sp)
	lw	$1, 20($sp)
	mul	$1, $1, $6
	sw	$1, 20($sp)
	lw	$1, 16($sp)
	lw	$14, 24($sp)
	addu	$1, $14, $1
	sw	$1, 24($sp)
	lw	$1, 16($sp)
	lw	$14, 20($sp)
	addu	$1, $14, $1
	sw	$1, 20($sp)
	lw	$1, 32($sp)
	lw	$14, 64($sp)
	addu	$1, $14, $1
	lw	$14, 24($sp)
	addu	$1, $1, $14
	srl	$1, $1, 11
	lw	$14, 8($sp)
	sh	$1, 14($14)
	lw	$1, 28($sp)
	lw	$14, 60($sp)
	addu	$1, $14, $1
	lw	$14, 20($sp)
	addu	$1, $1, $14
	srl	$1, $1, 11
	lw	$14, 8($sp)
	sh	$1, 10($14)
	lw	$1, 28($sp)
	lw	$14, 56($sp)
	addu	$1, $14, $1
	lw	$14, 24($sp)
	addu	$1, $1, $14
	srl	$1, $1, 11
	lw	$14, 8($sp)
	sh	$1, 6($14)
	lw	$1, 32($sp)
	lw	$14, 52($sp)
	addu	$1, $14, $1
	lw	$14, 20($sp)
	addu	$1, $1, $14
	srl	$1, $1, 11
	lw	$14, 8($sp)
	sh	$1, 2($14)
	lw	$1, 84($sp)
	sll	$1, $1, 1
	lw	$14, 8($sp)
	addu	$1, $14, $1
	sw	$1, 8($sp)
	lw	$1, 12($sp)
	addiu	$1, $1, 1
	sw	$1, 12($sp)
$BB0_2:                                 # =>This Inner Loop Header: Depth=1
	lw	$1, 12($sp)
	cmpgti	$p1, $1, 7
	brf	$p1, $BB0_1
	nop
$BB0_3:
	lw	$1, 88($sp)
	sw	$1, 8($sp)
	sw	$zero, 12($sp)
	addiu	$2, $zero, 7
	addiu	$3, $zero, 6
	addiu	$4, $zero, 5
	addiu	$5, $zero, 3
	addiu	$6, $zero, 4433
	addiu	$7, $zero, 6270
	addiu	$8, $zero, -15137
	addiu	$9, $zero, 9633
	addiu	$10, $zero, -3196
	addiu	$11, $zero, -16069
	addiu	$12, $zero, -20995
	addiu	$13, $zero, -7373
	addiu	$14, $zero, 12299
	addiu	$15, $zero, 25172
	addiu	$24, $zero, 16819
	addiu	$25, $zero, 2446
	j	$BB0_5
	nop
$BB0_4:                                 #   in Loop: Header=BB0_5 Depth=1
	lw	$1, 84($sp)
	mul	$1, $1, $2
	sll	$gp, $1, 1
	lw	$1, 8($sp)
	addu	$gp, $1, $gp
	lh	$gp, 0($gp)
	lh	$1, 0($1)
	addu	$1, $1, $gp
	sw	$1, 80($sp)
	lw	$1, 84($sp)
	mul	$1, $1, $2
	sll	$gp, $1, 1
	lw	$1, 8($sp)
	addu	$gp, $1, $gp
	lh	$gp, 0($gp)
	lh	$1, 0($1)
	subu	$1, $1, $gp
	sw	$1, 52($sp)
	lw	$1, 84($sp)
	sll	$16, $1, 1
	lw	$gp, 8($sp)
	addu	$16, $gp, $16
	lh	$16, 0($16)
	mul	$1, $1, $3
	sll	$1, $1, 1
	addu	$1, $gp, $1
	lh	$1, 0($1)
	addu	$1, $16, $1
	sw	$1, 76($sp)
	lw	$1, 84($sp)
	sll	$16, $1, 1
	lw	$gp, 8($sp)
	addu	$16, $gp, $16
	lh	$16, 0($16)
	mul	$1, $1, $3
	sll	$1, $1, 1
	addu	$1, $gp, $1
	lh	$1, 0($1)
	subu	$1, $16, $1
	sw	$1, 56($sp)
	lw	$1, 84($sp)
	sll	$16, $1, 2
	lw	$gp, 8($sp)
	addu	$16, $gp, $16
	lh	$16, 0($16)
	mul	$1, $1, $4
	sll	$1, $1, 1
	addu	$1, $gp, $1
	lh	$1, 0($1)
	addu	$1, $16, $1
	sw	$1, 72($sp)
	lw	$1, 84($sp)
	sll	$16, $1, 2
	lw	$gp, 8($sp)
	addu	$16, $gp, $16
	lh	$16, 0($16)
	mul	$1, $1, $4
	sll	$1, $1, 1
	addu	$1, $gp, $1
	lh	$1, 0($1)
	subu	$1, $16, $1
	sw	$1, 60($sp)
	lw	$1, 84($sp)
	sll	$16, $1, 3
	lw	$gp, 8($sp)
	addu	$16, $gp, $16
	lh	$16, 0($16)
	mul	$1, $1, $5
	sll	$1, $1, 1
	addu	$1, $gp, $1
	lh	$1, 0($1)
	addu	$1, $1, $16
	sw	$1, 68($sp)
	lw	$1, 84($sp)
	sll	$16, $1, 3
	lw	$gp, 8($sp)
	addu	$16, $gp, $16
	lh	$16, 0($16)
	mul	$1, $1, $5
	sll	$1, $1, 1
	addu	$1, $gp, $1
	lh	$1, 0($1)
	subu	$1, $1, $16
	sw	$1, 64($sp)
	lw	$1, 68($sp)
	lw	$gp, 80($sp)
	addu	$1, $gp, $1
	sw	$1, 48($sp)
	lw	$1, 68($sp)
	lw	$gp, 80($sp)
	subu	$1, $gp, $1
	sw	$1, 36($sp)
	lw	$1, 72($sp)
	lw	$gp, 76($sp)
	addu	$1, $gp, $1
	sw	$1, 44($sp)
	lw	$1, 72($sp)
	lw	$gp, 76($sp)
	subu	$1, $gp, $1
	sw	$1, 40($sp)
	lw	$1, 44($sp)
	lw	$gp, 48($sp)
	addu	$1, $gp, $1
	srl	$1, $1, 5
	lw	$gp, 8($sp)
	sh	$1, 0($gp)
	lw	$1, 84($sp)
	sll	$1, $1, 3
	lw	$gp, 8($sp)
	addu	$1, $gp, $1
	lw	$gp, 44($sp)
	lw	$16, 48($sp)
	subu	$gp, $16, $gp
	srl	$gp, $gp, 5
	sh	$gp, 0($1)
	sw	$6, 4($sp)
	lw	$1, 36($sp)
	lw	$gp, 40($sp)
	addu	$1, $gp, $1
	mul	$1, $1, $6
	sw	$1, 32($sp)
	sw	$7, 4($sp)
	lw	$1, 84($sp)
	sll	$1, $1, 2
	lw	$gp, 8($sp)
	addu	$1, $gp, $1
	lw	$gp, 36($sp)
	mul	$gp, $gp, $7
	lw	$16, 32($sp)
	addu	$gp, $16, $gp
	sra	$gp, $gp, 18
	sh	$gp, 0($1)
	sw	$8, 4($sp)
	lw	$1, 84($sp)
	mul	$1, $1, $3
	sll	$1, $1, 1
	lw	$gp, 8($sp)
	addu	$1, $gp, $1
	lw	$gp, 40($sp)
	mul	$gp, $gp, $8
	lw	$16, 32($sp)
	addu	$gp, $16, $gp
	sra	$gp, $gp, 18
	sh	$gp, 0($1)
	lw	$1, 52($sp)
	lw	$gp, 64($sp)
	addu	$1, $gp, $1
	sw	$1, 32($sp)
	lw	$1, 56($sp)
	lw	$gp, 60($sp)
	addu	$1, $gp, $1
	sw	$1, 28($sp)
	lw	$1, 56($sp)
	lw	$gp, 64($sp)
	addu	$1, $gp, $1
	sw	$1, 24($sp)
	lw	$1, 52($sp)
	lw	$gp, 60($sp)
	addu	$1, $gp, $1
	sw	$1, 20($sp)
	sw	$9, 4($sp)
	lw	$1, 20($sp)
	lw	$gp, 24($sp)
	addu	$1, $gp, $1
	mul	$1, $1, $9
	sw	$1, 16($sp)
	sw	$25, 4($sp)
	lw	$1, 64($sp)
	mul	$1, $1, $25
	sw	$1, 64($sp)
	sw	$24, 4($sp)
	lw	$1, 60($sp)
	mul	$1, $1, $24
	sw	$1, 60($sp)
	sw	$15, 4($sp)
	lw	$1, 56($sp)
	mul	$1, $1, $15
	sw	$1, 56($sp)
	sw	$14, 4($sp)
	lw	$1, 52($sp)
	mul	$1, $1, $14
	sw	$1, 52($sp)
	sw	$13, 4($sp)
	lw	$1, 32($sp)
	mul	$1, $1, $13
	sw	$1, 32($sp)
	sw	$12, 4($sp)
	lw	$1, 28($sp)
	mul	$1, $1, $12
	sw	$1, 28($sp)
	sw	$11, 4($sp)
	lw	$1, 24($sp)
	mul	$1, $1, $11
	sw	$1, 24($sp)
	sw	$10, 4($sp)
	lw	$1, 20($sp)
	mul	$1, $1, $10
	sw	$1, 20($sp)
	lw	$1, 16($sp)
	lw	$gp, 24($sp)
	addu	$1, $gp, $1
	sw	$1, 24($sp)
	lw	$1, 16($sp)
	lw	$gp, 20($sp)
	addu	$1, $gp, $1
	sw	$1, 20($sp)
	lw	$1, 84($sp)
	mul	$1, $1, $2
	sll	$1, $1, 1
	lw	$gp, 8($sp)
	addu	$1, $gp, $1
	lw	$gp, 32($sp)
	lw	$16, 64($sp)
	addu	$gp, $16, $gp
	lw	$16, 24($sp)
	addu	$gp, $gp, $16
	sra	$gp, $gp, 18
	sh	$gp, 0($1)
	lw	$1, 84($sp)
	mul	$1, $1, $4
	sll	$1, $1, 1
	lw	$gp, 8($sp)
	addu	$1, $gp, $1
	lw	$gp, 28($sp)
	lw	$16, 60($sp)
	addu	$gp, $16, $gp
	lw	$16, 20($sp)
	addu	$gp, $gp, $16
	sra	$gp, $gp, 18
	sh	$gp, 0($1)
	lw	$1, 84($sp)
	mul	$1, $1, $5
	sll	$1, $1, 1
	lw	$gp, 8($sp)
	addu	$1, $gp, $1
	lw	$gp, 28($sp)
	lw	$16, 56($sp)
	addu	$gp, $16, $gp
	lw	$16, 24($sp)
	addu	$gp, $gp, $16
	sra	$gp, $gp, 18
	sh	$gp, 0($1)
	lw	$1, 84($sp)
	sll	$1, $1, 1
	lw	$gp, 8($sp)
	addu	$1, $gp, $1
	lw	$gp, 32($sp)
	lw	$16, 52($sp)
	addu	$gp, $16, $gp
	lw	$16, 20($sp)
	addu	$gp, $gp, $16
	sra	$gp, $gp, 18
	sh	$gp, 0($1)
	lw	$1, 8($sp)
	addiu	$1, $1, 2
	sw	$1, 8($sp)
	lw	$1, 12($sp)
	addiu	$1, $1, 1
	sw	$1, 12($sp)
$BB0_5:                                 # =>This Inner Loop Header: Depth=1
	lw	$1, 12($sp)
	cmpgti	$p1, $1, 7
	brf	$p1, $BB0_4
	nop
$BB0_6:
	lw	$16, 92($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 96
	jr	$ra
	nop
$tmp2:
	.size	fdct, ($tmp2)-fdct

	.globl	main
	.type	main,@function
main:                                   # @main

# BB#0:
	addiu	$sp, $sp, -32
	sw	$ra, 28($sp)            # 4-byte Folded Spill
	sw	$16, 24($sp)            # 4-byte Folded Spill
	addiu	$1, $zero, %lo(block)
	lui	$16, %hi(block)
	addu	$4, $16, $1
	sw	$zero, 20($sp)
	addiu	$5, $zero, 8
	jal	fdct
	nop
	lh	$4, %lo(block)($16)
	lw	$16, 24($sp)            # 4-byte Folded Reload
	lw	$ra, 28($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 32
	jr	$ra
	nop
$tmp5:
	.size	main, ($tmp5)-main

	.type	block,@object           # @block
	.data
	.globl	block
	.align	4
block:
	.short	99                      # 0x63
	.short	104                     # 0x68
	.short	109                     # 0x6d
	.short	113                     # 0x71
	.short	115                     # 0x73
	.short	115                     # 0x73
	.short	55                      # 0x37
	.short	55                      # 0x37
	.short	104                     # 0x68
	.short	111                     # 0x6f
	.short	113                     # 0x71
	.short	116                     # 0x74
	.short	119                     # 0x77
	.short	56                      # 0x38
	.short	56                      # 0x38
	.short	56                      # 0x38
	.short	110                     # 0x6e
	.short	115                     # 0x73
	.short	120                     # 0x78
	.short	119                     # 0x77
	.short	118                     # 0x76
	.short	56                      # 0x38
	.short	56                      # 0x38
	.short	56                      # 0x38
	.short	119                     # 0x77
	.short	121                     # 0x79
	.short	122                     # 0x7a
	.short	120                     # 0x78
	.short	120                     # 0x78
	.short	59                      # 0x3b
	.short	59                      # 0x3b
	.short	59                      # 0x3b
	.short	119                     # 0x77
	.short	120                     # 0x78
	.short	121                     # 0x79
	.short	122                     # 0x7a
	.short	122                     # 0x7a
	.short	55                      # 0x37
	.short	55                      # 0x37
	.short	55                      # 0x37
	.short	121                     # 0x79
	.short	121                     # 0x79
	.short	121                     # 0x79
	.short	121                     # 0x79
	.short	60                      # 0x3c
	.short	57                      # 0x39
	.short	57                      # 0x39
	.short	57                      # 0x39
	.short	122                     # 0x7a
	.short	122                     # 0x7a
	.short	61                      # 0x3d
	.short	63                      # 0x3f
	.short	62                      # 0x3e
	.short	57                      # 0x39
	.short	57                      # 0x39
	.short	57                      # 0x39
	.short	62                      # 0x3e
	.short	62                      # 0x3e
	.short	61                      # 0x3d
	.short	61                      # 0x3d
	.short	63                      # 0x3f
	.short	58                      # 0x3a
	.short	58                      # 0x3a
	.short	58                      # 0x3a
	.size	block, 128

	.type	out,@object             # @out
	.comm	out,4,4

