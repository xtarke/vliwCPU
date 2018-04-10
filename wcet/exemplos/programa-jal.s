	.file	"../../../exemplos/programa-jal.ll"
	.text
	.globl	bar
	.type	bar,@function
bar:                                    # @bar

# BB#0:
	addiu	$2, $zero, 0
	jr	$ra
	nop
$tmp0:
	.size	bar, ($tmp0)-bar

	.globl	main
	.type	main,@function
main:                                   # @main

# BB#0:
	addiu	$sp, $sp, -24
	sw	$ra, 20($sp)            # 4-byte Folded Spill
	jal	bar
	nop
	lw	$ra, 20($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 24
	jr	$ra
	nop
$tmp2:
	.size	main, ($tmp2)-main


