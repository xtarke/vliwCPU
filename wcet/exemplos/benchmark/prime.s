	.file	"prime.ll"
	.text
	.globl	divides
	.type	divides,@function
divides:                                # @divides

# BB#0:
	addiu	$sp, $sp, -8
	sw	$4, 4($sp)
	sw	$5, 0($sp)
	lw	$1, 4($sp)
	divu	$5, $1
	mfhi	$1
	cmpeqi	$p1, $1, 0
	pmov	$4, $p1
	addiu	$sp, $sp, 8
	jr	$ra
	nop
$tmp1:
	.size	divides, ($tmp1)-divides

	.globl	even
	.type	even,@function
even:                                   # @even

# BB#0:
	addiu	$sp, $sp, -24
	sw	$ra, 20($sp)            # 4-byte Folded Spill
	or	$1, $4, $zero
	sw	$1, 16($sp)
	addiu	$4, $zero, 2
	or	$5, $1, $zero
	jal	divides
	nop
	lw	$ra, 20($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 24
	jr	$ra
	nop
$tmp4:
	.size	even, ($tmp4)-even

	.globl	prime
	.type	prime,@function
prime:                                  # @prime

# BB#0:
	addiu	$sp, $sp, -32
	sw	$ra, 28($sp)            # 4-byte Folded Spill
	sw	$4, 20($sp)
	jal	even
	nop
	cmpeqi	$p1, $4, 0
	br	$p1, $BB2_2
	nop
$BB2_1:
	lw	$1, 20($sp)
	cmpeqi	$p1, $1, 2
	j	$BB2_8
	nop
$BB2_2:
	addiu	$1, $zero, 3
	j	$BB2_4
	nop
$BB2_3:                                 #   in Loop: Header=BB2_4 Depth=1
	lw	$1, 16($sp)
	addiu	$1, $1, 2
$BB2_4:                                 # =>This Inner Loop Header: Depth=1
	sw	$1, 16($sp)
	lw	$1, 16($sp)
	mul	$1, $1, $1
	lw	$2, 20($sp)
	cmpgt	$p1, $1, $2
	br	$p1, $BB2_7
	nop
$BB2_5:                                 #   in Loop: Header=BB2_4 Depth=1
	lw	$5, 20($sp)
	lw	$4, 16($sp)
	jal	divides
	nop
	cmpeqi	$p1, $4, 0
	br	$p1, $BB2_3
	nop
$BB2_6:
	addiu	$1, $zero, 0
	j	$BB2_9
	nop
$BB2_7:
	lw	$1, 20($sp)
	cmpgti	$p1, $1, 1
$BB2_8:
	pmov	$1, $p1
$BB2_9:
	sb	$1, 24($sp)
	lbu	$4, 24($sp)
	lw	$ra, 28($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 32
	jr	$ra
	nop
$tmp7:
	.size	prime, ($tmp7)-prime

	.globl	swap
	.type	swap,@function
swap:                                   # @swap

# BB#0:
	addiu	$sp, $sp, -24
	sw	$4, 16($sp)
	sw	$5, 8($sp)
	lw	$1, 16($sp)
	lw	$1, 0($1)
	sw	$1, 4($sp)
	lw	$1, 8($sp)
	lw	$1, 0($1)
	lw	$2, 16($sp)
	sw	$1, 0($2)
	lw	$1, 8($sp)
	lw	$2, 4($sp)
	sw	$2, 0($1)
	addiu	$sp, $sp, 24
	jr	$ra
	nop
$tmp9:
	.size	swap, ($tmp9)-swap

	.globl	main
	.type	main,@function
main:                                   # @main

# BB#0:
	addiu	$sp, $sp, -32
	sw	$ra, 28($sp)            # 4-byte Folded Spill
	sw	$zero, 24($sp)
	addiu	$1, $zero, 21649
	sw	$1, 20($sp)
	lui	$1, 7
	ori	$1, $1, 54487
	sw	$1, 16($sp)
	addiu	$4, $sp, 20
	addiu	$5, $sp, 16
	jal	swap
	nop
	lw	$4, 20($sp)
	jal	prime
	nop
	cmpeqi	$p1, $4, 0
	br	$p1, $BB4_2
	nop
$BB4_1:
	lw	$4, 16($sp)
	jal	prime
	nop
	cmpnei	$p1, $4, 0
	j	$BB4_3
	nop
$BB4_2:
	cmpne	$p1, $zero, $zero
$BB4_3:
	cmpeq	$p2, $zero, $zero
	xorl	$p1, $p1, $p2
	pmov	$4, $p1
	lw	$ra, 28($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 32
	jr	$ra
	nop
$tmp12:
	.size	main, ($tmp12)-main


