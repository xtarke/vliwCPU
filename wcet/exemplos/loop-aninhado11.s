	.file	"loop-aninhado11.ll"
	.text
	.globl	main
	.type	main,@function
main:                                   # @main

# BB#0:
	addiu	$sp, $sp, -32
	sw	$zero, 28($sp)
	sw	$zero, 24($sp)
	sw	$zero, 20($sp)
	sw	$zero, 16($sp)
	sw	$zero, 12($sp)
	sw	$zero, 8($sp)
	sw	$zero, 4($sp)
	j	$BB0_46
	nop
$BB0_1:                                 #   in Loop: Header=BB0_46 Depth=1
	sw	$zero, 8($sp)
	j	$BB0_3
	nop
$BB0_2:                                 #   in Loop: Header=BB0_3 Depth=2
	lw	$1, 8($sp)
	addiu	$1, $1, 1
	sw	$1, 8($sp)
$BB0_3:                                 #   Parent Loop BB0_46 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB0_6 Depth 3
                                        #         Child Loop BB0_9 Depth 4
                                        #         Child Loop BB0_12 Depth 4
                                        #       Child Loop BB0_15 Depth 3
	lw	$1, 8($sp)
	cmpgti	$p1, $1, 9
	br	$p1, $BB0_16
	nop
$BB0_4:                                 #   in Loop: Header=BB0_3 Depth=2
	sw	$zero, 24($sp)
	j	$BB0_6
	nop
$BB0_5:                                 #   in Loop: Header=BB0_6 Depth=3
	lw	$1, 24($sp)
	addiu	$1, $1, 1
	sw	$1, 24($sp)
$BB0_6:                                 #   Parent Loop BB0_46 Depth=1
                                        #     Parent Loop BB0_3 Depth=2
                                        # =>    This Loop Header: Depth=3
                                        #         Child Loop BB0_9 Depth 4
                                        #         Child Loop BB0_12 Depth 4
	lw	$1, 24($sp)
	cmpgti	$p1, $1, 9
	br	$p1, $BB0_13
	nop
$BB0_7:                                 #   in Loop: Header=BB0_6 Depth=3
	sw	$zero, 20($sp)
	j	$BB0_9
	nop
$BB0_8:                                 #   in Loop: Header=BB0_9 Depth=4
	lw	$1, 20($sp)
	addiu	$1, $1, 1
	sw	$1, 20($sp)
$BB0_9:                                 #   Parent Loop BB0_46 Depth=1
                                        #     Parent Loop BB0_3 Depth=2
                                        #       Parent Loop BB0_6 Depth=3
                                        # =>      This Inner Loop Header: Depth=4
	lw	$1, 20($sp)
	cmpgti	$p1, $1, 9
	brf	$p1, $BB0_8
	nop
$BB0_10:                                #   in Loop: Header=BB0_6 Depth=3
	sw	$zero, 16($sp)
	j	$BB0_12
	nop
$BB0_11:                                #   in Loop: Header=BB0_12 Depth=4
	lw	$1, 16($sp)
	addiu	$1, $1, 1
	sw	$1, 16($sp)
$BB0_12:                                #   Parent Loop BB0_46 Depth=1
                                        #     Parent Loop BB0_3 Depth=2
                                        #       Parent Loop BB0_6 Depth=3
                                        # =>      This Inner Loop Header: Depth=4
	lw	$1, 16($sp)
	cmpgti	$p1, $1, 9
	br	$p1, $BB0_5
	nop
$BB0_48:                                #   in Loop: Header=BB0_12 Depth=4
	j	$BB0_11
	nop
$BB0_13:                                #   in Loop: Header=BB0_3 Depth=2
	sw	$zero, 12($sp)
	j	$BB0_15
	nop
$BB0_14:                                #   in Loop: Header=BB0_15 Depth=3
	lw	$1, 12($sp)
	addiu	$1, $1, 1
	sw	$1, 12($sp)
$BB0_15:                                #   Parent Loop BB0_46 Depth=1
                                        #     Parent Loop BB0_3 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	lw	$1, 12($sp)
	cmpgti	$p1, $1, 9
	br	$p1, $BB0_2
	nop
$BB0_49:                                #   in Loop: Header=BB0_15 Depth=3
	j	$BB0_14
	nop
$BB0_16:                                #   in Loop: Header=BB0_46 Depth=1
	sw	$zero, 8($sp)
	j	$BB0_18
	nop
$BB0_17:                                #   in Loop: Header=BB0_18 Depth=2
	lw	$1, 8($sp)
	addiu	$1, $1, 1
	sw	$1, 8($sp)
$BB0_18:                                #   Parent Loop BB0_46 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB0_21 Depth 3
                                        #         Child Loop BB0_24 Depth 4
                                        #         Child Loop BB0_27 Depth 4
                                        #       Child Loop BB0_30 Depth 3
	lw	$1, 8($sp)
	cmpgti	$p1, $1, 9
	br	$p1, $BB0_31
	nop
$BB0_19:                                #   in Loop: Header=BB0_18 Depth=2
	sw	$zero, 24($sp)
	j	$BB0_21
	nop
$BB0_20:                                #   in Loop: Header=BB0_21 Depth=3
	lw	$1, 24($sp)
	addiu	$1, $1, 1
	sw	$1, 24($sp)
$BB0_21:                                #   Parent Loop BB0_46 Depth=1
                                        #     Parent Loop BB0_18 Depth=2
                                        # =>    This Loop Header: Depth=3
                                        #         Child Loop BB0_24 Depth 4
                                        #         Child Loop BB0_27 Depth 4
	lw	$1, 24($sp)
	cmpgti	$p1, $1, 9
	br	$p1, $BB0_28
	nop
$BB0_22:                                #   in Loop: Header=BB0_21 Depth=3
	sw	$zero, 20($sp)
	j	$BB0_24
	nop
$BB0_23:                                #   in Loop: Header=BB0_24 Depth=4
	lw	$1, 20($sp)
	addiu	$1, $1, 1
	sw	$1, 20($sp)
$BB0_24:                                #   Parent Loop BB0_46 Depth=1
                                        #     Parent Loop BB0_18 Depth=2
                                        #       Parent Loop BB0_21 Depth=3
                                        # =>      This Inner Loop Header: Depth=4
	lw	$1, 20($sp)
	cmpgti	$p1, $1, 9
	brf	$p1, $BB0_23
	nop
$BB0_25:                                #   in Loop: Header=BB0_21 Depth=3
	sw	$zero, 16($sp)
	j	$BB0_27
	nop
$BB0_26:                                #   in Loop: Header=BB0_27 Depth=4
	lw	$1, 16($sp)
	addiu	$1, $1, 1
	sw	$1, 16($sp)
$BB0_27:                                #   Parent Loop BB0_46 Depth=1
                                        #     Parent Loop BB0_18 Depth=2
                                        #       Parent Loop BB0_21 Depth=3
                                        # =>      This Inner Loop Header: Depth=4
	lw	$1, 16($sp)
	cmpgti	$p1, $1, 9
	br	$p1, $BB0_20
	nop
$BB0_50:                                #   in Loop: Header=BB0_27 Depth=4
	j	$BB0_26
	nop
$BB0_28:                                #   in Loop: Header=BB0_18 Depth=2
	sw	$zero, 12($sp)
	j	$BB0_30
	nop
$BB0_29:                                #   in Loop: Header=BB0_30 Depth=3
	lw	$1, 12($sp)
	addiu	$1, $1, 1
	sw	$1, 12($sp)
$BB0_30:                                #   Parent Loop BB0_46 Depth=1
                                        #     Parent Loop BB0_18 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	lw	$1, 12($sp)
	cmpgti	$p1, $1, 9
	br	$p1, $BB0_17
	nop
$BB0_51:                                #   in Loop: Header=BB0_30 Depth=3
	j	$BB0_29
	nop
$BB0_31:                                #   in Loop: Header=BB0_46 Depth=1
	sw	$zero, 8($sp)
	j	$BB0_33
	nop
$BB0_32:                                #   in Loop: Header=BB0_33 Depth=2
	lw	$1, 8($sp)
	addiu	$1, $1, 1
	sw	$1, 8($sp)
$BB0_33:                                #   Parent Loop BB0_46 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB0_36 Depth 3
                                        #         Child Loop BB0_39 Depth 4
                                        #         Child Loop BB0_42 Depth 4
                                        #       Child Loop BB0_45 Depth 3
	lw	$1, 8($sp)
	cmpgti	$p1, $1, 9
	br	$p1, $BB0_46
	nop
$BB0_34:                                #   in Loop: Header=BB0_33 Depth=2
	sw	$zero, 24($sp)
	j	$BB0_36
	nop
$BB0_35:                                #   in Loop: Header=BB0_36 Depth=3
	lw	$1, 24($sp)
	addiu	$1, $1, 1
	sw	$1, 24($sp)
$BB0_36:                                #   Parent Loop BB0_46 Depth=1
                                        #     Parent Loop BB0_33 Depth=2
                                        # =>    This Loop Header: Depth=3
                                        #         Child Loop BB0_39 Depth 4
                                        #         Child Loop BB0_42 Depth 4
	lw	$1, 24($sp)
	cmpgti	$p1, $1, 9
	br	$p1, $BB0_43
	nop
$BB0_37:                                #   in Loop: Header=BB0_36 Depth=3
	sw	$zero, 20($sp)
	j	$BB0_39
	nop
$BB0_38:                                #   in Loop: Header=BB0_39 Depth=4
	lw	$1, 20($sp)
	addiu	$1, $1, 1
	sw	$1, 20($sp)
$BB0_39:                                #   Parent Loop BB0_46 Depth=1
                                        #     Parent Loop BB0_33 Depth=2
                                        #       Parent Loop BB0_36 Depth=3
                                        # =>      This Inner Loop Header: Depth=4
	lw	$1, 20($sp)
	cmpgti	$p1, $1, 9
	brf	$p1, $BB0_38
	nop
$BB0_40:                                #   in Loop: Header=BB0_36 Depth=3
	sw	$zero, 16($sp)
	j	$BB0_42
	nop
$BB0_41:                                #   in Loop: Header=BB0_42 Depth=4
	lw	$1, 16($sp)
	addiu	$1, $1, 1
	sw	$1, 16($sp)
$BB0_42:                                #   Parent Loop BB0_46 Depth=1
                                        #     Parent Loop BB0_33 Depth=2
                                        #       Parent Loop BB0_36 Depth=3
                                        # =>      This Inner Loop Header: Depth=4
	lw	$1, 16($sp)
	cmpgti	$p1, $1, 9
	br	$p1, $BB0_35
	nop
$BB0_52:                                #   in Loop: Header=BB0_42 Depth=4
	j	$BB0_41
	nop
$BB0_43:                                #   in Loop: Header=BB0_33 Depth=2
	sw	$zero, 12($sp)
	j	$BB0_45
	nop
$BB0_44:                                #   in Loop: Header=BB0_45 Depth=3
	lw	$1, 12($sp)
	addiu	$1, $1, 1
	sw	$1, 12($sp)
$BB0_45:                                #   Parent Loop BB0_46 Depth=1
                                        #     Parent Loop BB0_33 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	lw	$1, 12($sp)
	cmpgti	$p1, $1, 9
	br	$p1, $BB0_32
	nop
$BB0_53:                                #   in Loop: Header=BB0_45 Depth=3
	j	$BB0_44
	nop
$BB0_46:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB0_3 Depth 2
                                        #       Child Loop BB0_6 Depth 3
                                        #         Child Loop BB0_9 Depth 4
                                        #         Child Loop BB0_12 Depth 4
                                        #       Child Loop BB0_15 Depth 3
                                        #     Child Loop BB0_18 Depth 2
                                        #       Child Loop BB0_21 Depth 3
                                        #         Child Loop BB0_24 Depth 4
                                        #         Child Loop BB0_27 Depth 4
                                        #       Child Loop BB0_30 Depth 3
                                        #     Child Loop BB0_33 Depth 2
                                        #       Child Loop BB0_36 Depth 3
                                        #         Child Loop BB0_39 Depth 4
                                        #         Child Loop BB0_42 Depth 4
                                        #       Child Loop BB0_45 Depth 3
	lw	$1, 4($sp)
	addiu	$2, $1, 1
	sw	$2, 4($sp)
	cmpgti	$p1, $1, 9
	brf	$p1, $BB0_1
	nop
$BB0_47:
	lw	$4, 28($sp)
	addiu	$sp, $sp, 32
	jr	$ra
	nop
$tmp1:
	.size	main, ($tmp1)-main


