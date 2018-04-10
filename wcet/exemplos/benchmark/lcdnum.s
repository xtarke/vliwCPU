	.file	"lcdnum.ll"
	.text
	.globl	num_to_lcd
	.type	num_to_lcd,@function
num_to_lcd:                             # @num_to_lcd

# BB#0:
	addiu	$sp, $sp, -8
	sb	$4, 0($sp)
	lbu	$2, 0($sp)
	cmpgti	$p1, $2, 15
	br	$p1, $BB0_3
	nop
$BB0_1:
	sll	$1, $2, 2
	lui	$2, %hi($JTI0_0)
	addu	$1, $1, $2
	lw	$1, %lo($JTI0_0)($1)
	jr	$1
	nop
$BB0_2:
	addiu	$1, $zero, 93
	j	$BB0_4
	nop
$BB0_3:
	addiu	$1, $zero, 0
$BB0_4:
	sb	$1, 4($sp)
	lbu	$4, 4($sp)
	addiu	$sp, $sp, 8
	jr	$ra
	nop
$BB0_5:
	addiu	$1, $zero, 36
	j	$BB0_4
	nop
$BB0_6:
	addiu	$1, $zero, 109
	j	$BB0_4
	nop
$BB0_7:
	addiu	$1, $zero, 46
	j	$BB0_4
	nop
$BB0_8:
	addiu	$1, $zero, 123
	j	$BB0_4
	nop
$BB0_9:
	addiu	$1, $zero, 37
	j	$BB0_4
	nop
$BB0_10:
	addiu	$1, $zero, 127
	j	$BB0_4
	nop
$BB0_11:
	addiu	$1, $zero, 111
	j	$BB0_4
	nop
$BB0_12:
	addiu	$1, $zero, 63
	j	$BB0_4
	nop
$BB0_13:
	addiu	$1, $zero, 122
	j	$BB0_4
	nop
$BB0_14:
	addiu	$1, $zero, 83
	j	$BB0_4
	nop
$BB0_15:
	addiu	$1, $zero, 124
	j	$BB0_4
	nop
$BB0_16:
	addiu	$1, $zero, 91
	j	$BB0_4
	nop
$BB0_17:
	addiu	$1, $zero, 27
	j	$BB0_4
	nop
$tmp1:
	.size	num_to_lcd, ($tmp1)-num_to_lcd
	.section	.rodata,"a",@progbits
	.align	2
$JTI0_0:
	.long	($BB0_3)
	.long	($BB0_5)
	.long	($BB0_2)
	.long	($BB0_6)
	.long	($BB0_7)
	.long	($BB0_2)
	.long	($BB0_8)
	.long	($BB0_9)
	.long	($BB0_10)
	.long	($BB0_11)
	.long	($BB0_12)
	.long	($BB0_13)
	.long	($BB0_14)
	.long	($BB0_15)
	.long	($BB0_16)
	.long	($BB0_17)

	.text
	.globl	main
	.type	main,@function
main:                                   # @main

# BB#0:
	addiu	$sp, $sp, -48
	sw	$ra, 44($sp)            # 4-byte Folded Spill
	sw	$18, 40($sp)            # 4-byte Folded Spill
	sw	$17, 36($sp)            # 4-byte Folded Spill
	sw	$16, 32($sp)            # 4-byte Folded Spill
	sw	$zero, 28($sp)
	addiu	$1, $zero, 10
	sw	$1, 16($sp)
	sw	$zero, 24($sp)
	lui	$16, %hi(IN)
	addiu	$17, $zero, 15
	lui	$18, %hi(OUT)
	j	$BB1_2
	nop
$BB1_1:                                 #   in Loop: Header=BB1_2 Depth=1
	lw	$1, 24($sp)
	addiu	$1, $1, 1
	sw	$1, 24($sp)
$BB1_2:                                 # =>This Inner Loop Header: Depth=1
	lw	$1, 16($sp)
	lw	$2, 24($sp)
	cmpge	$p1, $2, $1
	br	$p1, $BB1_5
	nop
$BB1_3:                                 #   in Loop: Header=BB1_2 Depth=1
	lbu	$1, %lo(IN)($16)
	sb	$1, 20($sp)
	lw	$1, 24($sp)
	cmpgti	$p1, $1, 4
	br	$p1, $BB1_1
	nop
$BB1_4:                                 #   in Loop: Header=BB1_2 Depth=1
	lbu	$1, 20($sp)
	and	$1, $1, $17
	sb	$1, 20($sp)
	lbu	$4, 20($sp)
	jal	num_to_lcd
	nop
	sb	$4, %lo(OUT)($18)
	j	$BB1_1
	nop
$BB1_5:
	addiu	$4, $zero, 0
	lw	$16, 32($sp)            # 4-byte Folded Reload
	lw	$17, 36($sp)            # 4-byte Folded Reload
	lw	$18, 40($sp)            # 4-byte Folded Reload
	lw	$ra, 44($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 48
	jr	$ra
	nop
$tmp4:
	.size	main, ($tmp4)-main

	.type	IN,@object              # @IN
	.comm	IN,1,1
	.type	OUT,@object             # @OUT
	.comm	OUT,1,1

