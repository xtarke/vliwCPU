	.file	"crc.ll"
	.text
	.globl	icrc1
	.type	icrc1,@function
icrc1:                                  # @icrc1

# BB#0:
	addiu	$sp, $sp, -16
	sh	$4, 12($sp)
	sb	$5, 8($sp)
	lbu	$1, 8($sp)
	sll	$1, $1, 8
	lhu	$2, 12($sp)
	xor	$1, $2, $1
	sh	$1, 0($sp)
	sw	$zero, 4($sp)
	addiu	$2, $zero, 128
	j	$BB0_2
	nop
$BB0_1:                                 #   in Loop: Header=BB0_2 Depth=1
	sh	$1, 0($sp)
	lw	$1, 4($sp)
	addiu	$1, $1, 1
	sw	$1, 4($sp)
$BB0_2:                                 # =>This Inner Loop Header: Depth=1
	lw	$1, 4($sp)
	cmpgti	$p1, $1, 7
	br	$p1, $BB0_6
	nop
$BB0_3:                                 #   in Loop: Header=BB0_2 Depth=1
	lbu	$1, 1($sp)
	and	$1, $1, $2
	cmpeqi	$p1, $1, 0
	br	$p1, $BB0_5
	nop
$BB0_4:                                 #   in Loop: Header=BB0_2 Depth=1
	lhu	$1, 0($sp)
	sll	$1, $1, 1
	sh	$1, 0($sp)
	xori	$1, $1, 4129
	j	$BB0_1
	nop
$BB0_5:                                 #   in Loop: Header=BB0_2 Depth=1
	lhu	$1, 0($sp)
	sll	$1, $1, 1
	j	$BB0_1
	nop
$BB0_6:
	lhu	$4, 0($sp)
	addiu	$sp, $sp, 16
	jr	$ra
	nop
$tmp1:
	.size	icrc1, ($tmp1)-icrc1

	.globl	icrc
	.type	icrc,@function
icrc:                                   # @icrc

# BB#0:
	addiu	$sp, $sp, -80
	sw	$ra, 76($sp)            # 4-byte Folded Spill
	sw	$20, 72($sp)            # 4-byte Folded Spill
	sw	$19, 68($sp)            # 4-byte Folded Spill
	sw	$18, 64($sp)            # 4-byte Folded Spill
	sw	$17, 60($sp)            # 4-byte Folded Spill
	sw	$16, 56($sp)            # 4-byte Folded Spill
	sh	$4, 52($sp)
	sw	$6, 44($sp)
	sw	$5, 40($sp)
	sh	$7, 36($sp)
	lw	$1, 96($sp)
	sw	$1, 32($sp)
	lhu	$1, 52($sp)
	sh	$1, 16($sp)
	lui	$2, %hi(icrc.init)
	lhu	$1, %lo(icrc.init)($2)
	cmpnei	$p1, $1, 0
	br	$p1, $BB1_4
	nop
$BB1_1:
	addiu	$1, $zero, 1
	sh	$1, %lo(icrc.init)($2)
	addiu	$1, $zero, 0
	sh	$1, 20($sp)
	ori	$16, $zero, 65280
	addiu	$1, $zero, %lo(icrc.icrctb)
	lui	$2, %hi(icrc.icrctb)
	addu	$17, $2, $1
	addiu	$1, $zero, %lo(icrc.it)
	lui	$2, %hi(icrc.it)
	addu	$18, $2, $1
	addiu	$19, $zero, 15
	addiu	$1, $zero, %lo(icrc.rchr)
	lui	$2, %hi(icrc.rchr)
	addu	$20, $2, $1
	j	$BB1_3
	nop
$BB1_2:                                 #   in Loop: Header=BB1_3 Depth=1
	lhu	$1, 20($sp)
	sll	$1, $1, 8
	and	$4, $1, $16
	addiu	$5, $zero, 0
	jal	icrc1
	nop
	lhu	$1, 20($sp)
	sll	$1, $1, 1
	addu	$1, $17, $1
	sh	$4, 0($1)
	lhu	$1, 20($sp)
	and	$2, $1, $19
	addu	$2, $18, $2
	lbu	$2, 0($2)
	sll	$2, $2, 4
	srl	$3, $1, 4
	addu	$3, $18, $3
	lbu	$3, 0($3)
	or	$2, $2, $3
	addu	$1, $20, $1
	sb	$2, 0($1)
	lhu	$1, 20($sp)
	addiu	$1, $1, 1
	sh	$1, 20($sp)
$BB1_3:                                 # =>This Inner Loop Header: Depth=1
	lhu	$1, 20($sp)
	cmpgti	$p1, $1, 255
	brf	$p1, $BB1_2
	nop
$BB1_4:
	lh	$1, 36($sp)
	cmplti	$p1, $1, 0
	br	$p1, $BB1_6
	nop
$BB1_5:
	lbu	$1, 36($sp)
	sll	$2, $1, 8
	or	$1, $1, $2
	j	$BB1_8
	nop
$BB1_6:
	lw	$1, 32($sp)
	cmpgti	$p1, $1, -1
	br	$p1, $BB1_9
	nop
$BB1_7:
	addiu	$2, $zero, 255
	lhu	$1, 16($sp)
	and	$3, $1, $2
	addiu	$2, $zero, %lo(icrc.rchr)
	lui	$4, %hi(icrc.rchr)
	addu	$2, $4, $2
	addu	$3, $2, $3
	lbu	$3, 0($3)
	sll	$3, $3, 8
	srl	$1, $1, 8
	addu	$1, $2, $1
	lbu	$1, 0($1)
	or	$1, $1, $3
$BB1_8:
	sh	$1, 16($sp)
$BB1_9:
	addiu	$1, $zero, 1
	sh	$1, 20($sp)
	addiu	$1, $zero, %lo(icrc.rchr)
	lui	$2, %hi(icrc.rchr)
	addu	$2, $2, $1
	addiu	$1, $zero, %lo(lin)
	lui	$3, %hi(lin)
	addu	$3, $3, $1
	addiu	$1, $zero, %lo(icrc.icrctb)
	lui	$4, %hi(icrc.icrctb)
	addu	$4, $4, $1
	j	$BB1_11
	nop
$BB1_10:                                #   in Loop: Header=BB1_11 Depth=1
	lbu	$1, 0($1)
	lbu	$5, 17($sp)
	xor	$1, $1, $5
	sh	$1, 28($sp)
	lhu	$1, 28($sp)
	sll	$1, $1, 1
	addu	$1, $4, $1
	lhu	$1, 0($1)
	lhu	$5, 16($sp)
	sll	$5, $5, 8
	xor	$1, $1, $5
	sh	$1, 16($sp)
	lhu	$1, 20($sp)
	addiu	$1, $1, 1
	sh	$1, 20($sp)
$BB1_11:                                # =>This Inner Loop Header: Depth=1
	lw	$1, 40($sp)
	lhu	$5, 20($sp)
	cmpgt	$p1, $5, $1
	lw	$1, 44($sp)
	cmpeqi	$p2, $1, 0
	andl	$p1, $p2, $p1
	br	$p1, $BB1_15
	nop
$BB1_12:                                #   in Loop: Header=BB1_11 Depth=1
	lw	$1, 32($sp)
	cmpgti	$p1, $1, -1
	br	$p1, $BB1_14
	nop
$BB1_13:                                #   in Loop: Header=BB1_11 Depth=1
	lhu	$1, 20($sp)
	addu	$1, $3, $1
	lbu	$1, 0($1)
	addu	$1, $2, $1
	j	$BB1_10
	nop
$BB1_14:                                #   in Loop: Header=BB1_11 Depth=1
	lhu	$1, 20($sp)
	addu	$1, $3, $1
	j	$BB1_10
	nop
$BB1_15:
	lw	$1, 32($sp)
	cmplti	$p1, $1, 0
	br	$p1, $BB1_17
	nop
$BB1_16:
	lhu	$1, 16($sp)
	j	$BB1_18
	nop
$BB1_17:
	addiu	$2, $zero, 255
	lhu	$1, 16($sp)
	and	$3, $1, $2
	addiu	$2, $zero, %lo(icrc.rchr)
	lui	$4, %hi(icrc.rchr)
	addu	$2, $4, $2
	addu	$3, $2, $3
	lbu	$3, 0($3)
	sll	$3, $3, 8
	srl	$1, $1, 8
	addu	$1, $2, $1
	lbu	$1, 0($1)
	or	$1, $1, $3
$BB1_18:
	sh	$1, 24($sp)
	lhu	$4, 24($sp)
	lw	$16, 56($sp)            # 4-byte Folded Reload
	lw	$17, 60($sp)            # 4-byte Folded Reload
	lw	$18, 64($sp)            # 4-byte Folded Reload
	lw	$19, 68($sp)            # 4-byte Folded Reload
	lw	$20, 72($sp)            # 4-byte Folded Reload
	lw	$ra, 76($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 80
	jr	$ra
	nop
$tmp4:
	.size	icrc, ($tmp4)-icrc

	.globl	main
	.type	main,@function
main:                                   # @main

# BB#0:
	addiu	$sp, $sp, -64
	sw	$ra, 60($sp)            # 4-byte Folded Spill
	sw	$18, 56($sp)            # 4-byte Folded Spill
	sw	$17, 52($sp)            # 4-byte Folded Spill
	sw	$16, 48($sp)            # 4-byte Folded Spill
	sw	$zero, 44($sp)
	addiu	$1, $zero, 40
	sw	$1, 24($sp)
	addiu	$1, $zero, %lo(lin)
	lui	$2, %hi(lin)
	addu	$18, $2, $1
	sw	$zero, 28($sp)
	addiu	$16, $zero, 0
	sb	$16, 41($18)
	lw	$6, 28($sp)
	lw	$5, 24($sp)
	addiu	$17, $zero, 1
	sw	$17, 16($sp)
	addiu	$4, $zero, 0
	addiu	$7, $zero, 0
	jal	icrc
	nop
	addiu	$1, $zero, 2
	sh	$4, 40($sp)
	srl	$2, $4, 8
	lw	$3, 24($sp)
	addu	$3, $3, $18
	sb	$2, 1($3)
	lw	$2, 24($sp)
	addu	$2, $2, $18
	lhu	$3, 40($sp)
	sb	$3, 2($2)
	lhu	$4, 40($sp)
	lw	$2, 28($sp)
	lw	$3, 24($sp)
	sw	$17, 16($sp)
	addiu	$5, $3, 2
	sltu	$1, $5, $1
	addu	$1, $1, $16
	addu	$6, $2, $1
	addiu	$7, $zero, 0
	jal	icrc
	nop
	sh	$4, 36($sp)
	addiu	$4, $zero, 0
	lw	$16, 48($sp)            # 4-byte Folded Reload
	lw	$17, 52($sp)            # 4-byte Folded Reload
	lw	$18, 56($sp)            # 4-byte Folded Reload
	lw	$ra, 60($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 64
	jr	$ra
	nop
$tmp7:
	.size	main, ($tmp7)-main

	.type	lin,@object             # @lin
	.data
	.globl	lin
	.align	4
lin:
	.asciz	 "asdffeagewaHAFEFaeDsFEawFdsFaefaeerdjgp\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000"
	.size	lin, 256

	.type	icrc.icrctb,@object     # @icrc.icrctb
	.local	icrc.icrctb
	.comm	icrc.icrctb,512,16
	.type	icrc.init,@object       # @icrc.init
	.local	icrc.init
	.comm	icrc.init,2,2
	.type	icrc.rchr,@object       # @icrc.rchr
	.local	icrc.rchr
	.comm	icrc.rchr,256,16
	.type	icrc.it,@object         # @icrc.it
	.align	4
icrc.it:
	.ascii	 "\000\b\004\f\002\n\006\016\001\t\005\r\003\013\007\017"
	.size	icrc.it, 16


