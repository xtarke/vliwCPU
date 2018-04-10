	.file	"janne_complex.ll"
	.text
	.globl	complex
	.type	complex,@function
complex:                                # @complex

# BB#0:
	addiu	$sp, $sp, -8
	sw	$4, 4($sp)
	sw	$5, 0($sp)
	addiu	$2, $zero, 3
	j	$BB0_2
	nop
$BB0_1:                                 #   in Loop: Header=BB0_2 Depth=1
	lw	$1, 4($sp)
	addiu	$1, $1, 2
	sw	$1, 4($sp)
	lw	$1, 0($sp)
	addiu	$1, $1, -10
	sw	$1, 0($sp)
$BB0_2:                                 # =>This Loop Header: Depth=1
                                        #     Child Loop BB0_4 Depth 2
	lw	$1, 4($sp)
	cmpgti	$p1, $1, 29
	br	$p1, $BB0_11
	nop
$BB0_12:                                #   in Loop: Header=BB0_2 Depth=1
	j	$BB0_4
	nop
$BB0_3:                                 #   in Loop: Header=BB0_4 Depth=2
	lw	$1, 4($sp)
	addiu	$1, $1, 1
	sw	$1, 4($sp)
$BB0_4:                                 #   Parent Loop BB0_2 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	lw	$1, 4($sp)
	lw	$3, 0($sp)
	cmpge	$p1, $3, $1
	br	$p1, $BB0_1
	nop
$BB0_5:                                 #   in Loop: Header=BB0_4 Depth=2
	lw	$1, 0($sp)
	cmplti	$p1, $1, 6
	br	$p1, $BB0_7
	nop
$BB0_6:                                 #   in Loop: Header=BB0_4 Depth=2
	lw	$1, 0($sp)
	mul	$1, $1, $2
	j	$BB0_8
	nop
$BB0_7:                                 #   in Loop: Header=BB0_4 Depth=2
	lw	$1, 0($sp)
	addiu	$1, $1, 2
$BB0_8:                                 #   in Loop: Header=BB0_4 Depth=2
	sw	$1, 0($sp)
	lw	$1, 0($sp)
	cmplti	$p1, $1, 10
	br	$p1, $BB0_3
	nop
$BB0_9:                                 #   in Loop: Header=BB0_4 Depth=2
	lw	$1, 0($sp)
	cmpgti	$p1, $1, 12
	br	$p1, $BB0_3
	nop
$BB0_10:                                #   in Loop: Header=BB0_4 Depth=2
	lw	$1, 4($sp)
	addiu	$1, $1, 10
	sw	$1, 4($sp)
	j	$BB0_4
	nop
$BB0_11:
	addiu	$4, $zero, 1
	addiu	$sp, $sp, 8
	jr	$ra
	nop
$tmp1:
	.size	complex, ($tmp1)-complex

	.globl	main
	.type	main,@function
main:                                   # @main

# BB#0:
	addiu	$sp, $sp, -40
	sw	$ra, 36($sp)            # 4-byte Folded Spill
	sw	$zero, 32($sp)
	addiu	$1, $zero, 1
	sw	$1, 28($sp)
	sw	$1, 24($sp)
	sw	$zero, 20($sp)
	lw	$5, 24($sp)
	lw	$4, 28($sp)
	jal	complex
	nop
	sw	$4, 20($sp)
	lw	$ra, 36($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 40
	jr	$ra
	nop
$tmp4:
	.size	main, ($tmp4)-main


