	.file	"loop-aninhado8.ll"
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

	.globl	main
	.type	main,@function
main:                                   # @main

# BB#0:
	addiu	$sp, $sp, -48
	sw	$ra, 44($sp)            # 4-byte Folded Spill
	sw	$zero, 40($sp)
	sw	$zero, 36($sp)
	sw	$zero, 32($sp)
	sw	$zero, 28($sp)
	sw	$zero, 24($sp)
	sw	$zero, 20($sp)
	sw	$zero, 16($sp)
	sw	$zero, 20($sp)
	j	$BB1_2
	nop
$BB1_1:                                 #   in Loop: Header=BB1_2 Depth=1
	lw	$1, 20($sp)
	addiu	$1, $1, 1
	sw	$1, 20($sp)
$BB1_2:                                 # =>This Loop Header: Depth=1
                                        #     Child Loop BB1_6 Depth 2
                                        #       Child Loop BB1_9 Depth 3
                                        #       Child Loop BB1_12 Depth 3
                                        #     Child Loop BB1_16 Depth 2
	lw	$1, 20($sp)
	cmpgti	$p1, $1, 0
	br	$p1, $BB1_17
	nop
$BB1_3:                                 #   in Loop: Header=BB1_2 Depth=1
	lw	$1, 16($sp)
	cmpeqi	$p1, $1, 0
	br	$p1, $BB1_13
	nop
$BB1_4:                                 #   in Loop: Header=BB1_2 Depth=1
	sw	$zero, 36($sp)
	j	$BB1_6
	nop
$BB1_5:                                 #   in Loop: Header=BB1_6 Depth=2
	lw	$1, 36($sp)
	addiu	$1, $1, 1
	sw	$1, 36($sp)
$BB1_6:                                 #   Parent Loop BB1_2 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB1_9 Depth 3
                                        #       Child Loop BB1_12 Depth 3
	lw	$1, 36($sp)
	cmpgti	$p1, $1, 0
	br	$p1, $BB1_14
	nop
$BB1_7:                                 #   in Loop: Header=BB1_6 Depth=2
	sw	$zero, 32($sp)
	j	$BB1_9
	nop
$BB1_8:                                 #   in Loop: Header=BB1_9 Depth=3
	jal	bar
	nop
	lw	$1, 32($sp)
	addiu	$1, $1, 1
	sw	$1, 32($sp)
$BB1_9:                                 #   Parent Loop BB1_2 Depth=1
                                        #     Parent Loop BB1_6 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	lw	$1, 32($sp)
	cmpgti	$p1, $1, 0
	brf	$p1, $BB1_8
	nop
$BB1_10:                                #   in Loop: Header=BB1_6 Depth=2
	sw	$zero, 28($sp)
	j	$BB1_12
	nop
$BB1_11:                                #   in Loop: Header=BB1_12 Depth=3
	jal	bar
	nop
	lw	$1, 28($sp)
	addiu	$1, $1, 1
	sw	$1, 28($sp)
$BB1_12:                                #   Parent Loop BB1_2 Depth=1
                                        #     Parent Loop BB1_6 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	lw	$1, 28($sp)
	cmpgti	$p1, $1, 0
	br	$p1, $BB1_5
	nop
$BB1_18:                                #   in Loop: Header=BB1_12 Depth=3
	j	$BB1_11
	nop
$BB1_13:                                #   in Loop: Header=BB1_2 Depth=1
	jal	bar
	nop
	jal	bar
	nop
	jal	bar
	nop
	jal	bar
	nop
	jal	bar
	nop
	jal	bar
	nop
	jal	bar
	nop
	jal	bar
	nop
	jal	bar
	nop
	jal	bar
	nop
	jal	bar
	nop
	jal	bar
	nop
	jal	bar
	nop
	jal	bar
	nop
	jal	bar
	nop
	jal	bar
	nop
	jal	bar
	nop
	jal	bar
	nop
	jal	bar
	nop
	jal	bar
	nop
	jal	bar
	nop
	jal	bar
	nop
	jal	bar
	nop
	jal	bar
	nop
	j	$BB1_1
	nop
$BB1_14:                                #   in Loop: Header=BB1_2 Depth=1
	sw	$zero, 24($sp)
	j	$BB1_16
	nop
$BB1_15:                                #   in Loop: Header=BB1_16 Depth=2
	jal	bar
	nop
	lw	$1, 24($sp)
	addiu	$1, $1, 1
	sw	$1, 24($sp)
$BB1_16:                                #   Parent Loop BB1_2 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	lw	$1, 24($sp)
	cmpgti	$p1, $1, 0
	br	$p1, $BB1_1
	nop
$BB1_19:                                #   in Loop: Header=BB1_16 Depth=2
	j	$BB1_15
	nop
$BB1_17:
	addiu	$4, $zero, 0
	lw	$ra, 44($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 48
	jr	$ra
	nop
$tmp4:
	.size	main, ($tmp4)-main


