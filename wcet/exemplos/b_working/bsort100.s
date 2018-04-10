	.file	"bsort100.c"
	.comm	Array,404,64
	.comm	Seed,4,4
	.comm	factor,4,4
	.text
	.globl	main
	.type	main, @function
main:
.LFB2:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	$Array, %edi
	movl	$0, %eax
	call	Initialize
	movl	$Array, %edi
	movl	$0, %eax
	call	BubbleSort
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE2:
	.size	main, .-main
	.globl	Initialize
	.type	Initialize, @function
Initialize:
.LFB3:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movq	%rdi, -24(%rbp)
	movl	$-1, factor(%rip)
	movl	factor(%rip), %eax
	movl	%eax, -8(%rbp)
	movl	$1, -4(%rbp)
	jmp	.L3
.L4:
	movl	-4(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	movq	-24(%rbp), %rax
	addq	%rax, %rdx
	movl	$500, %eax
	subl	-4(%rbp), %eax
	movl	%eax, (%rdx)
	addl	$1, -4(%rbp)
.L3:
	cmpl	$100, -4(%rbp)
	jle	.L4
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE3:
	.size	Initialize, .-Initialize
	.globl	BubbleSort
	.type	BubbleSort, @function
BubbleSort:
.LFB4:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movq	%rdi, -24(%rbp)
	movl	$0, -4(%rbp)
	movl	$1, -12(%rbp)
	jmp	.L6
.L14:
	movl	$1, -4(%rbp)
	movl	$1, -8(%rbp)
	jmp	.L7
.L11:
	movl	$100, %eax
	subl	-12(%rbp), %eax
	cmpl	-8(%rbp), %eax
	jge	.L8
	jmp	.L9
.L8:
	movl	-8(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	movq	-24(%rbp), %rax
	addq	%rdx, %rax
	movl	(%rax), %edx
	movl	-8(%rbp), %eax
	cltq
	addq	$1, %rax
	leaq	0(,%rax,4), %rcx
	movq	-24(%rbp), %rax
	addq	%rcx, %rax
	movl	(%rax), %eax
	cmpl	%eax, %edx
	jle	.L10
	movl	-8(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	movq	-24(%rbp), %rax
	addq	%rdx, %rax
	movl	(%rax), %eax
	movl	%eax, -16(%rbp)
	movl	-8(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	movq	-24(%rbp), %rax
	addq	%rax, %rdx
	movl	-8(%rbp), %eax
	cltq
	addq	$1, %rax
	leaq	0(,%rax,4), %rcx
	movq	-24(%rbp), %rax
	addq	%rcx, %rax
	movl	(%rax), %eax
	movl	%eax, (%rdx)
	movl	-8(%rbp), %eax
	cltq
	addq	$1, %rax
	leaq	0(,%rax,4), %rdx
	movq	-24(%rbp), %rax
	addq	%rax, %rdx
	movl	-16(%rbp), %eax
	movl	%eax, (%rdx)
	movl	$0, -4(%rbp)
.L10:
	addl	$1, -8(%rbp)
.L7:
	cmpl	$99, -8(%rbp)
	jle	.L11
.L9:
	cmpl	$0, -4(%rbp)
	je	.L12
	jmp	.L13
.L12:
	addl	$1, -12(%rbp)
.L6:
	cmpl	$99, -12(%rbp)
	jle	.L14
.L13:
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE4:
	.size	BubbleSort, .-BubbleSort
	.ident	"GCC: (GNU) 4.9.1"
	.section	.note.GNU-stack,"",@progbits
