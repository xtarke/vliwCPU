	.file	"bs.ll"
	.text
	.globl	main
	.type	main,@function
main:                                   # @main

# BB#0:
	addiu	$sp, $sp, -24
	sw	$ra, 20($sp)            # 4-byte Folded Spill
	addiu	$4, $zero, 8
	jal	binary_search
	nop
	addiu	$4, $zero, 0
	lw	$ra, 20($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 24
	jr	$ra
	nop
$tmp2:
	.size	main, ($tmp2)-main

	.globl	binary_search
	.type	binary_search,@function
binary_search:                          # @binary_search

# BB#0:
	addiu	$sp, $sp, -24
	sw	$4, 20($sp)
	sw	$zero, 4($sp)
	addiu	$1, $zero, 14
	sw	$1, 8($sp)
	addiu	$1, $zero, -1
	sw	$1, 16($sp)
	addiu	$1, $zero, %lo(data)
	lui	$2, %hi(data)
	addu	$2, $2, $1
	j	$BB1_2
	nop
$BB1_1:                                 #   in Loop: Header=BB1_2 Depth=1
	lw	$1, 4($sp)
	addiu	$1, $1, -1
	sw	$1, 8($sp)
	lw	$1, 12($sp)
	sll	$1, $1, 3
	addu	$1, $2, $1
	lw	$1, 4($1)
	sw	$1, 16($sp)
$BB1_2:                                 # =>This Inner Loop Header: Depth=1
	lw	$1, 8($sp)
	lw	$3, 4($sp)
	cmpgt	$p1, $3, $1
	br	$p1, $BB1_7
	nop
$BB1_3:                                 #   in Loop: Header=BB1_2 Depth=1
	lw	$1, 8($sp)
	lw	$3, 4($sp)
	addu	$1, $3, $1
	sra	$1, $1, 1
	sw	$1, 12($sp)
	sll	$1, $1, 3
	addu	$1, $2, $1
	lw	$1, 0($1)
	lw	$3, 20($sp)
	cmpne	$p1, $1, $3
	brf	$p1, $BB1_1
	nop
$BB1_4:                                 #   in Loop: Header=BB1_2 Depth=1
	lw	$1, 12($sp)
	sll	$1, $1, 3
	addu	$1, $2, $1
	lw	$1, 0($1)
	lw	$3, 20($sp)
	cmple	$p1, $1, $3
	br	$p1, $BB1_6
	nop
$BB1_5:                                 #   in Loop: Header=BB1_2 Depth=1
	lw	$1, 12($sp)
	addiu	$1, $1, -1
	sw	$1, 8($sp)
	j	$BB1_2
	nop
$BB1_6:                                 #   in Loop: Header=BB1_2 Depth=1
	lw	$1, 12($sp)
	addiu	$1, $1, 1
	sw	$1, 4($sp)
	j	$BB1_2
	nop
$BB1_7:
	lw	$4, 16($sp)
	addiu	$sp, $sp, 24
	jr	$ra
	nop
$tmp4:
	.size	binary_search, ($tmp4)-binary_search

	.type	data,@object            # @data
	.data
	.globl	data
	.align	4
data:
	.long	1                       # 0x1
	.long	100                     # 0x64
	.long	5                       # 0x5
	.long	200                     # 0xc8
	.long	6                       # 0x6
	.long	300                     # 0x12c
	.long	7                       # 0x7
	.long	700                     # 0x2bc
	.long	8                       # 0x8
	.long	900                     # 0x384
	.long	9                       # 0x9
	.long	250                     # 0xfa
	.long	10                      # 0xa
	.long	400                     # 0x190
	.long	11                      # 0xb
	.long	600                     # 0x258
	.long	12                      # 0xc
	.long	800                     # 0x320
	.long	13                      # 0xd
	.long	1500                    # 0x5dc
	.long	14                      # 0xe
	.long	1200                    # 0x4b0
	.long	15                      # 0xf
	.long	110                     # 0x6e
	.long	16                      # 0x10
	.long	140                     # 0x8c
	.long	17                      # 0x11
	.long	133                     # 0x85
	.long	18                      # 0x12
	.long	10                      # 0xa
	.size	data, 120


