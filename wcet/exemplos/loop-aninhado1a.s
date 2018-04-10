	.file	"loop-aninhado1a.ll"
	.text
	.globl	main
	.type	main,@function
main:                                   # @main

# BB#0:
	addiu	$sp, $sp, -16
	sw	$zero, 12($sp)
	sw	$zero, 8($sp)
	sw	$zero, 4($sp)
	sw	$zero, 8($sp)
	j	$BB0_2
	nop
$BB0_1:                                 #   in Loop: Header=BB0_2 Depth=1
	lw	$1, 8($sp)
	addiu	$1, $1, 1
	sw	$1, 8($sp)
$BB0_2:                                 # =>This Loop Header: Depth=1
                                        #     Child Loop BB0_5 Depth 2
	lw	$1, 8($sp)
	cmpgti	$p1, $1, 0
	br	$p1, $BB0_6
	nop
$BB0_3:                                 #   in Loop: Header=BB0_2 Depth=1
	sw	$zero, 4($sp)
	j	$BB0_5
	nop
$BB0_4:                                 #   in Loop: Header=BB0_5 Depth=2
	lw	$1, 4($sp)
	addiu	$1, $1, 1
	sw	$1, 4($sp)
$BB0_5:                                 #   Parent Loop BB0_2 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	lw	$1, 4($sp)
	cmpgti	$p1, $1, 0
	br	$p1, $BB0_1
	nop
$BB0_7:                                 #   in Loop: Header=BB0_5 Depth=2
	j	$BB0_4
	nop
$BB0_6:
	lw	$4, 12($sp)
	addiu	$sp, $sp, 16
	jr	$ra
	nop
$tmp1:
	.size	main, ($tmp1)-main


