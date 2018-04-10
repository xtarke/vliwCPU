	.file	"loop-aninhado4.ll"
	.text
	.globl	main
	.type	main,@function
main:                                   # @main

# BB#0:
	addiu	$sp, $sp, -24
	sw	$zero, 20($sp)
	sw	$zero, 16($sp)
	sw	$zero, 12($sp)
	sw	$zero, 8($sp)
	sw	$zero, 4($sp)
	sw	$zero, 0($sp)
	sw	$zero, 0($sp)
	j	$BB0_2
	nop
$BB0_1:                                 #   in Loop: Header=BB0_2 Depth=1
	lw	$1, 0($sp)
	addiu	$1, $1, 1
	sw	$1, 0($sp)
$BB0_2:                                 # =>This Loop Header: Depth=1
                                        #     Child Loop BB0_5 Depth 2
                                        #       Child Loop BB0_8 Depth 3
                                        #       Child Loop BB0_11 Depth 3
                                        #     Child Loop BB0_14 Depth 2
	lw	$1, 0($sp)
	cmpgti	$p1, $1, 4
	br	$p1, $BB0_15
	nop
$BB0_3:                                 #   in Loop: Header=BB0_2 Depth=1
	sw	$zero, 16($sp)
	j	$BB0_5
	nop
$BB0_4:                                 #   in Loop: Header=BB0_5 Depth=2
	lw	$1, 16($sp)
	addiu	$1, $1, 1
	sw	$1, 16($sp)
$BB0_5:                                 #   Parent Loop BB0_2 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB0_8 Depth 3
                                        #       Child Loop BB0_11 Depth 3
	lw	$1, 16($sp)
	cmpgti	$p1, $1, 4
	br	$p1, $BB0_12
	nop
$BB0_6:                                 #   in Loop: Header=BB0_5 Depth=2
	sw	$zero, 12($sp)
	j	$BB0_8
	nop
$BB0_7:                                 #   in Loop: Header=BB0_8 Depth=3
	lw	$1, 12($sp)
	addiu	$1, $1, 1
	sw	$1, 12($sp)
$BB0_8:                                 #   Parent Loop BB0_2 Depth=1
                                        #     Parent Loop BB0_5 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	lw	$1, 12($sp)
	cmpgti	$p1, $1, 4
	brf	$p1, $BB0_7
	nop
$BB0_9:                                 #   in Loop: Header=BB0_5 Depth=2
	sw	$zero, 8($sp)
	j	$BB0_11
	nop
$BB0_10:                                #   in Loop: Header=BB0_11 Depth=3
	lw	$1, 8($sp)
	addiu	$1, $1, 1
	sw	$1, 8($sp)
$BB0_11:                                #   Parent Loop BB0_2 Depth=1
                                        #     Parent Loop BB0_5 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	lw	$1, 8($sp)
	cmpgti	$p1, $1, 4
	br	$p1, $BB0_4
	nop
$BB0_16:                                #   in Loop: Header=BB0_11 Depth=3
	j	$BB0_10
	nop
$BB0_12:                                #   in Loop: Header=BB0_2 Depth=1
	sw	$zero, 4($sp)
	j	$BB0_14
	nop
$BB0_13:                                #   in Loop: Header=BB0_14 Depth=2
	lw	$1, 4($sp)
	addiu	$1, $1, 1
	sw	$1, 4($sp)
$BB0_14:                                #   Parent Loop BB0_2 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	lw	$1, 4($sp)
	cmpgti	$p1, $1, 4
	br	$p1, $BB0_1
	nop
$BB0_17:                                #   in Loop: Header=BB0_14 Depth=2
	j	$BB0_13
	nop
$BB0_15:
	lw	$4, 20($sp)
	addiu	$sp, $sp, 24
	jr	$ra
	nop
$tmp1:
	.size	main, ($tmp1)-main


