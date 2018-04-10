	.file	"procs.ll"
	.text
	.globl	proc1
	.type	proc1,@function
proc1:                                  # @proc1

# BB#0:
	addiu	$4, $zero, 1
	jr	$ra
	nop
$tmp0:
	.size	proc1, ($tmp0)-proc1

	.globl	proc2
	.type	proc2,@function
proc2:                                  # @proc2

# BB#0:
	addiu	$sp, $sp, -24
	sw	$ra, 20($sp)            # 4-byte Folded Spill
	jal	proc1
	nop
	jal	proc1
	nop
	lw	$ra, 20($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 24
	jr	$ra
	nop
$tmp3:
	.size	proc2, ($tmp3)-proc2

	.globl	main
	.type	main,@function
main:                                   # @main

# BB#0:
	addiu	$sp, $sp, -24
	sw	$ra, 20($sp)            # 4-byte Folded Spill
	jal	proc1
	nop
	jal	proc2
	nop
	jal	proc2
	nop
	addiu	$4, $zero, 0
	lw	$ra, 20($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 24
	jr	$ra
	nop
$tmp6:
	.size	main, ($tmp6)-main


