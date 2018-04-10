	.file	"jfdctint.ll"
	.text
	.globl	jpeg_fdct_islow
	.type	jpeg_fdct_islow,@function
jpeg_fdct_islow:                        # @jpeg_fdct_islow

# BB#0:
	addiu	$sp, $sp, -80
	addiu	$1, $zero, %lo(data)
	lui	$2, %hi(data)
	addu	$1, $2, $1
	sw	$1, 8($sp)
	addiu	$1, $zero, 7
	sw	$1, 4($sp)
	addiu	$2, $zero, 6270
	addiu	$3, $zero, 4433
	addiu	$4, $zero, -15137
	addiu	$5, $zero, -3196
	addiu	$6, $zero, -16069
	addiu	$7, $zero, -20995
	addiu	$8, $zero, -7373
	addiu	$9, $zero, 12299
	addiu	$10, $zero, 25172
	addiu	$11, $zero, 16819
	addiu	$12, $zero, 2446
	addiu	$13, $zero, 9633
	j	$BB0_2
	nop
$BB0_1:                                 #   in Loop: Header=BB0_2 Depth=1
	lw	$1, 8($sp)
	lw	$14, 28($1)
	lw	$1, 0($1)
	addu	$1, $1, $14
	sw	$1, 76($sp)
	lw	$1, 8($sp)
	lw	$14, 28($1)
	lw	$1, 0($1)
	subu	$1, $1, $14
	sw	$1, 48($sp)
	lw	$1, 8($sp)
	lw	$14, 24($1)
	lw	$1, 4($1)
	addu	$1, $1, $14
	sw	$1, 72($sp)
	lw	$1, 8($sp)
	lw	$14, 24($1)
	lw	$1, 4($1)
	subu	$1, $1, $14
	sw	$1, 52($sp)
	lw	$1, 8($sp)
	lw	$14, 20($1)
	lw	$1, 8($1)
	addu	$1, $1, $14
	sw	$1, 68($sp)
	lw	$1, 8($sp)
	lw	$14, 20($1)
	lw	$1, 8($1)
	subu	$1, $1, $14
	sw	$1, 56($sp)
	lw	$1, 8($sp)
	lw	$14, 16($1)
	lw	$1, 12($1)
	addu	$1, $1, $14
	sw	$1, 64($sp)
	lw	$1, 8($sp)
	lw	$14, 16($1)
	lw	$1, 12($1)
	subu	$1, $1, $14
	sw	$1, 60($sp)
	lw	$1, 64($sp)
	lw	$14, 76($sp)
	addu	$1, $14, $1
	sw	$1, 44($sp)
	lw	$1, 64($sp)
	lw	$14, 76($sp)
	subu	$1, $14, $1
	sw	$1, 32($sp)
	lw	$1, 68($sp)
	lw	$14, 72($sp)
	addu	$1, $14, $1
	sw	$1, 40($sp)
	lw	$1, 68($sp)
	lw	$14, 72($sp)
	subu	$1, $14, $1
	sw	$1, 36($sp)
	lw	$1, 40($sp)
	lw	$14, 44($sp)
	addu	$1, $14, $1
	sll	$1, $1, 2
	lw	$14, 8($sp)
	sw	$1, 0($14)
	lw	$1, 40($sp)
	lw	$14, 44($sp)
	subu	$1, $14, $1
	sll	$1, $1, 2
	lw	$14, 8($sp)
	sw	$1, 16($14)
	lw	$1, 32($sp)
	lw	$14, 36($sp)
	addu	$1, $14, $1
	mul	$1, $1, $3
	sw	$1, 28($sp)
	lw	$14, 32($sp)
	mul	$14, $14, $2
	addu	$1, $1, $14
	addiu	$1, $1, 1024
	sra	$1, $1, 11
	lw	$14, 8($sp)
	sw	$1, 8($14)
	lw	$1, 36($sp)
	mul	$1, $1, $4
	lw	$14, 28($sp)
	addu	$1, $14, $1
	addiu	$1, $1, 1024
	sra	$1, $1, 11
	lw	$14, 8($sp)
	sw	$1, 24($14)
	lw	$1, 48($sp)
	lw	$14, 60($sp)
	addu	$1, $14, $1
	sw	$1, 28($sp)
	lw	$1, 52($sp)
	lw	$14, 56($sp)
	addu	$1, $14, $1
	sw	$1, 24($sp)
	lw	$1, 52($sp)
	lw	$14, 60($sp)
	addu	$1, $14, $1
	sw	$1, 20($sp)
	lw	$1, 48($sp)
	lw	$14, 56($sp)
	addu	$1, $14, $1
	sw	$1, 16($sp)
	lw	$14, 20($sp)
	addu	$1, $14, $1
	mul	$1, $1, $13
	sw	$1, 12($sp)
	lw	$1, 60($sp)
	mul	$1, $1, $12
	sw	$1, 60($sp)
	lw	$1, 56($sp)
	mul	$1, $1, $11
	sw	$1, 56($sp)
	lw	$1, 52($sp)
	mul	$1, $1, $10
	sw	$1, 52($sp)
	lw	$1, 48($sp)
	mul	$1, $1, $9
	sw	$1, 48($sp)
	lw	$1, 28($sp)
	mul	$1, $1, $8
	sw	$1, 28($sp)
	lw	$1, 24($sp)
	mul	$1, $1, $7
	sw	$1, 24($sp)
	lw	$1, 20($sp)
	mul	$1, $1, $6
	sw	$1, 20($sp)
	lw	$1, 16($sp)
	mul	$1, $1, $5
	sw	$1, 16($sp)
	lw	$1, 12($sp)
	lw	$14, 20($sp)
	addu	$1, $14, $1
	sw	$1, 20($sp)
	lw	$1, 12($sp)
	lw	$14, 16($sp)
	addu	$1, $14, $1
	sw	$1, 16($sp)
	lw	$1, 28($sp)
	lw	$14, 60($sp)
	addu	$1, $14, $1
	lw	$14, 20($sp)
	addu	$1, $1, $14
	addiu	$1, $1, 1024
	sra	$1, $1, 11
	lw	$14, 8($sp)
	sw	$1, 28($14)
	lw	$1, 24($sp)
	lw	$14, 56($sp)
	addu	$1, $14, $1
	lw	$14, 16($sp)
	addu	$1, $1, $14
	addiu	$1, $1, 1024
	sra	$1, $1, 11
	lw	$14, 8($sp)
	sw	$1, 20($14)
	lw	$1, 24($sp)
	lw	$14, 52($sp)
	addu	$1, $14, $1
	lw	$14, 20($sp)
	addu	$1, $1, $14
	addiu	$1, $1, 1024
	sra	$1, $1, 11
	lw	$14, 8($sp)
	sw	$1, 12($14)
	lw	$1, 28($sp)
	lw	$14, 48($sp)
	addu	$1, $14, $1
	lw	$14, 16($sp)
	addu	$1, $1, $14
	addiu	$1, $1, 1024
	sra	$1, $1, 11
	lw	$14, 8($sp)
	sw	$1, 4($14)
	lw	$1, 8($sp)
	addiu	$1, $1, 32
	sw	$1, 8($sp)
	lw	$1, 4($sp)
	addiu	$1, $1, -1
	sw	$1, 4($sp)
$BB0_2:                                 # =>This Inner Loop Header: Depth=1
	lw	$1, 4($sp)
	cmplti	$p1, $1, 0
	brf	$p1, $BB0_1
	nop
$BB0_3:
	addiu	$1, $zero, %lo(data)
	lui	$2, %hi(data)
	addu	$1, $2, $1
	sw	$1, 8($sp)
	addiu	$1, $zero, 7
	sw	$1, 4($sp)
	addiu	$2, $zero, 6270
	addiu	$3, $zero, 4433
	addiu	$4, $zero, -15137
	addiu	$5, $zero, -3196
	addiu	$6, $zero, -16069
	addiu	$7, $zero, -20995
	addiu	$8, $zero, -7373
	addiu	$9, $zero, 12299
	addiu	$10, $zero, 25172
	addiu	$11, $zero, 16819
	addiu	$12, $zero, 2446
	addiu	$13, $zero, 9633
	j	$BB0_5
	nop
$BB0_4:                                 #   in Loop: Header=BB0_5 Depth=1
	lw	$1, 8($sp)
	lw	$14, 224($1)
	lw	$1, 0($1)
	addu	$1, $1, $14
	sw	$1, 76($sp)
	lw	$1, 8($sp)
	lw	$14, 224($1)
	lw	$1, 0($1)
	subu	$1, $1, $14
	sw	$1, 48($sp)
	lw	$1, 8($sp)
	lw	$14, 192($1)
	lw	$1, 32($1)
	addu	$1, $1, $14
	sw	$1, 72($sp)
	lw	$1, 8($sp)
	lw	$14, 192($1)
	lw	$1, 32($1)
	subu	$1, $1, $14
	sw	$1, 52($sp)
	lw	$1, 8($sp)
	lw	$14, 160($1)
	lw	$1, 64($1)
	addu	$1, $1, $14
	sw	$1, 68($sp)
	lw	$1, 8($sp)
	lw	$14, 160($1)
	lw	$1, 64($1)
	subu	$1, $1, $14
	sw	$1, 56($sp)
	lw	$1, 8($sp)
	lw	$14, 128($1)
	lw	$1, 96($1)
	addu	$1, $1, $14
	sw	$1, 64($sp)
	lw	$1, 8($sp)
	lw	$14, 128($1)
	lw	$1, 96($1)
	subu	$1, $1, $14
	sw	$1, 60($sp)
	lw	$1, 64($sp)
	lw	$14, 76($sp)
	addu	$1, $14, $1
	sw	$1, 44($sp)
	lw	$1, 64($sp)
	lw	$14, 76($sp)
	subu	$1, $14, $1
	sw	$1, 32($sp)
	lw	$1, 68($sp)
	lw	$14, 72($sp)
	addu	$1, $14, $1
	sw	$1, 40($sp)
	lw	$1, 68($sp)
	lw	$14, 72($sp)
	subu	$1, $14, $1
	sw	$1, 36($sp)
	lw	$1, 40($sp)
	lw	$14, 44($sp)
	addu	$1, $14, $1
	addiu	$1, $1, 2
	sra	$1, $1, 2
	lw	$14, 8($sp)
	sw	$1, 0($14)
	lw	$1, 40($sp)
	lw	$14, 44($sp)
	subu	$1, $14, $1
	addiu	$1, $1, 2
	sra	$1, $1, 2
	lw	$14, 8($sp)
	sw	$1, 128($14)
	lw	$1, 32($sp)
	lw	$14, 36($sp)
	addu	$1, $14, $1
	mul	$1, $1, $3
	sw	$1, 28($sp)
	lw	$14, 32($sp)
	mul	$14, $14, $2
	addu	$1, $1, $14
	addiu	$1, $1, 16384
	sra	$1, $1, 15
	lw	$14, 8($sp)
	sw	$1, 64($14)
	lw	$1, 36($sp)
	mul	$1, $1, $4
	lw	$14, 28($sp)
	addu	$1, $14, $1
	addiu	$1, $1, 16384
	sra	$1, $1, 15
	lw	$14, 8($sp)
	sw	$1, 192($14)
	lw	$1, 48($sp)
	lw	$14, 60($sp)
	addu	$1, $14, $1
	sw	$1, 28($sp)
	lw	$1, 52($sp)
	lw	$14, 56($sp)
	addu	$1, $14, $1
	sw	$1, 24($sp)
	lw	$1, 52($sp)
	lw	$14, 60($sp)
	addu	$1, $14, $1
	sw	$1, 20($sp)
	lw	$1, 48($sp)
	lw	$14, 56($sp)
	addu	$1, $14, $1
	sw	$1, 16($sp)
	lw	$14, 20($sp)
	addu	$1, $14, $1
	mul	$1, $1, $13
	sw	$1, 12($sp)
	lw	$1, 60($sp)
	mul	$1, $1, $12
	sw	$1, 60($sp)
	lw	$1, 56($sp)
	mul	$1, $1, $11
	sw	$1, 56($sp)
	lw	$1, 52($sp)
	mul	$1, $1, $10
	sw	$1, 52($sp)
	lw	$1, 48($sp)
	mul	$1, $1, $9
	sw	$1, 48($sp)
	lw	$1, 28($sp)
	mul	$1, $1, $8
	sw	$1, 28($sp)
	lw	$1, 24($sp)
	mul	$1, $1, $7
	sw	$1, 24($sp)
	lw	$1, 20($sp)
	mul	$1, $1, $6
	sw	$1, 20($sp)
	lw	$1, 16($sp)
	mul	$1, $1, $5
	sw	$1, 16($sp)
	lw	$1, 12($sp)
	lw	$14, 20($sp)
	addu	$1, $14, $1
	sw	$1, 20($sp)
	lw	$1, 12($sp)
	lw	$14, 16($sp)
	addu	$1, $14, $1
	sw	$1, 16($sp)
	lw	$1, 28($sp)
	lw	$14, 60($sp)
	addu	$1, $14, $1
	lw	$14, 20($sp)
	addu	$1, $1, $14
	addiu	$1, $1, 16384
	sra	$1, $1, 15
	lw	$14, 8($sp)
	sw	$1, 224($14)
	lw	$1, 24($sp)
	lw	$14, 56($sp)
	addu	$1, $14, $1
	lw	$14, 16($sp)
	addu	$1, $1, $14
	addiu	$1, $1, 16384
	sra	$1, $1, 15
	lw	$14, 8($sp)
	sw	$1, 160($14)
	lw	$1, 24($sp)
	lw	$14, 52($sp)
	addu	$1, $14, $1
	lw	$14, 20($sp)
	addu	$1, $1, $14
	addiu	$1, $1, 16384
	sra	$1, $1, 15
	lw	$14, 8($sp)
	sw	$1, 96($14)
	lw	$1, 28($sp)
	lw	$14, 48($sp)
	addu	$1, $14, $1
	lw	$14, 16($sp)
	addu	$1, $1, $14
	addiu	$1, $1, 16384
	sra	$1, $1, 15
	lw	$14, 8($sp)
	sw	$1, 32($14)
	lw	$1, 8($sp)
	addiu	$1, $1, 4
	sw	$1, 8($sp)
	lw	$1, 4($sp)
	addiu	$1, $1, -1
	sw	$1, 4($sp)
$BB0_5:                                 # =>This Inner Loop Header: Depth=1
	lw	$1, 4($sp)
	cmplti	$p1, $1, 0
	brf	$p1, $BB0_4
	nop
$BB0_6:
	addiu	$sp, $sp, 80
	jr	$ra
	nop
$tmp1:
	.size	jpeg_fdct_islow, ($tmp1)-jpeg_fdct_islow

	.globl	main
	.type	main,@function
main:                                   # @main

# BB#0:
	addiu	$sp, $sp, -32
	sw	$ra, 28($sp)            # 4-byte Folded Spill
	addiu	$1, $zero, 1
	sw	$1, 20($sp)
	sw	$zero, 24($sp)
	addiu	$2, $zero, 133
	lui	$1, 32768
	ori	$3, $1, 32769
	addiu	$1, $zero, %lo(data)
	lui	$5, %hi(data)
	ori	$4, $zero, 65535
	addu	$5, $5, $1
	j	$BB1_2
	nop
$BB1_1:                                 #   in Loop: Header=BB1_2 Depth=1
	lw	$1, 20($sp)
	mul	$1, $1, $2
	addiu	$1, $1, 81
	mult	$1, $3
	mfhi	$6
	addu	$6, $6, $1
	srl	$7, $6, 31
	sra	$6, $6, 15
	addu	$6, $6, $7
	mul	$6, $6, $4
	subu	$1, $1, $6
	sw	$1, 20($sp)
	lw	$6, 24($sp)
	sll	$6, $6, 2
	addu	$6, $5, $6
	sw	$1, 0($6)
	lw	$1, 24($sp)
	addiu	$1, $1, 1
	sw	$1, 24($sp)
$BB1_2:                                 # =>This Inner Loop Header: Depth=1
	lw	$1, 24($sp)
	cmpgti	$p1, $1, 63
	brf	$p1, $BB1_1
	nop
$BB1_3:
	jal	jpeg_fdct_islow
	nop
	lw	$ra, 28($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 32
	jr	$ra
	nop
$tmp4:
	.size	main, ($tmp4)-main

	.type	data,@object            # @data
	.comm	data,256,16

