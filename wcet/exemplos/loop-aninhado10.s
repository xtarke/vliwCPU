	.file	"loop-aninhado10.ll"
	.text
	.globl	bar
	.type	bar,@function
bar:                                    # @bar

# BB#0:
	addiu	$sp, $sp, -8
	sw	$zero, 4($sp)
	sw	$zero, 4($sp)
	j	$BB0_2
	nop
$BB0_1:                                 #   in Loop: Header=BB0_2 Depth=1
	lw	$1, 4($sp)
	addiu	$1, $1, 1
	sw	$1, 4($sp)
$BB0_2:                                 # =>This Inner Loop Header: Depth=1
	lw	$1, 4($sp)
	cmpgti	$p1, $1, 0
	brf	$p1, $BB0_1
	nop
$BB0_3:
	addiu	$4, $zero, 0
	addiu	$sp, $sp, 8
	jr	$ra
	nop
$tmp1:
	.size	bar, ($tmp1)-bar

	.globl	foo
	.type	foo,@function
foo:                                    # @foo

# BB#0:
	addiu	$sp, $sp, -8
	sw	$zero, 4($sp)
	sw	$zero, 4($sp)
	j	$BB1_2
	nop
$BB1_1:                                 #   in Loop: Header=BB1_2 Depth=1
	lw	$1, 4($sp)
	addiu	$1, $1, 1
	sw	$1, 4($sp)
$BB1_2:                                 # =>This Inner Loop Header: Depth=1
	lw	$1, 4($sp)
	cmpgti	$p1, $1, 0
	brf	$p1, $BB1_1
	nop
$BB1_3:
	addiu	$4, $zero, 0
	addiu	$sp, $sp, 8
	jr	$ra
	nop
$tmp3:
	.size	foo, ($tmp3)-foo

	.globl	main
	.type	main,@function
main:                                   # @main

# BB#0:
	addiu	$sp, $sp, -32
	sw	$ra, 28($sp)            # 4-byte Folded Spill
	sw	$zero, 24($sp)
	sw	$zero, 20($sp)
	sw	$zero, 16($sp)
	sw	$zero, 20($sp)
	j	$BB2_2
	nop
$BB2_1:                                 #   in Loop: Header=BB2_2 Depth=1
	lw	$1, 20($sp)
	addiu	$1, $1, 1
	sw	$1, 20($sp)
$BB2_2:                                 # =>This Inner Loop Header: Depth=1
	lw	$1, 20($sp)
	cmpgti	$p1, $1, 1
	br	$p1, $BB2_6
	nop
$BB2_3:                                 #   in Loop: Header=BB2_2 Depth=1
	lw	$1, 16($sp)
	cmpnei	$p1, $1, 0
	br	$p1, $BB2_5
	nop
$BB2_4:                                 #   in Loop: Header=BB2_2 Depth=1
	lw	$1, 16($sp)
	addiu	$2, $1, 1
	sw	$2, 16($sp)
	sw	$1, 16($sp)
	sw	$2, 16($sp)
	sw	$1, 16($sp)
	sw	$2, 16($sp)
	sw	$1, 16($sp)
	sw	$2, 16($sp)
	sw	$1, 16($sp)
	jal	bar
	nop
	j	$BB2_1
	nop
$BB2_5:                                 #   in Loop: Header=BB2_2 Depth=1
	lw	$1, 16($sp)
	addiu	$2, $1, 1
	sw	$2, 16($sp)
	sw	$1, 16($sp)
	jal	foo
	nop
	j	$BB2_1
	nop
$BB2_6:
	addiu	$4, $zero, 0
	lw	$ra, 28($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 32
	jr	$ra
	nop
$tmp6:
	.size	main, ($tmp6)-main


