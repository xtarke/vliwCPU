	.file	"fibcall.ll"
	.text
	.globl	fib
	.type	fib,@function
fib:                                    # @fib

# BB#0:
	addiu	$sp, $sp, -24
	sw	$4, 20($sp)
	addiu	$1, $zero, 1
	sw	$1, 12($sp)
	sw	$zero, 8($sp)
	addiu	$1, $zero, 2
	sw	$1, 16($sp)
	cmpne	$p1, $zero, $zero
	cmpeq	$p2, $zero, $zero
	j	$BB0_2
	nop
$BB0_1:                                 #   in Loop: Header=BB0_2 Depth=1
	lw	$1, 12($sp)
	sw	$1, 4($sp)
	lw	$1, 8($sp)
	lw	$2, 12($sp)
	addu	$1, $2, $1
	sw	$1, 12($sp)
	lw	$1, 4($sp)
	sw	$1, 8($sp)
	lw	$1, 16($sp)
	addiu	$1, $1, 1
	sw	$1, 16($sp)
$BB0_2:                                 # =>This Inner Loop Header: Depth=1
	lw	$1, 16($sp)
	cmpgti	$p4, $1, 30
	cmpne	$p3, $zero, $zero
	orl	$p3, $p1, $p3
	br	$p4, $BB0_4
	nop
$BB0_3:                                 #   in Loop: Header=BB0_2 Depth=1
	lw	$1, 20($sp)
	lw	$2, 16($sp)
	cmple	$p3, $2, $1
$BB0_4:                                 #   in Loop: Header=BB0_2 Depth=1
	nandl	$p3, $p3, $p2
	brf	$p3, $BB0_1
	nop
$BB0_5:
	lw	$4, 12($sp)
	sw	$4, 0($sp)
	addiu	$sp, $sp, 24
	jr	$ra
	nop
$tmp1:
	.size	fib, ($tmp1)-fib

	.globl	main
	.type	main,@function
main:                                   # @main

# BB#0:
	addiu	$sp, $sp, -32
	sw	$ra, 28($sp)            # 4-byte Folded Spill
	sw	$zero, 24($sp)
	addiu	$1, $zero, 30
	sw	$1, 20($sp)
	addiu	$4, $zero, 30
	jal	fib
	nop
	lw	$4, 20($sp)
	lw	$ra, 28($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 32
	jr	$ra
	nop
$tmp4:
	.size	main, ($tmp4)-main


