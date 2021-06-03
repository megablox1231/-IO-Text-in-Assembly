#	Description:
#			Take input text, store it in an array,
#			and output the text back.
#
	.data
MAXLINES = 10
LINELEN = 32

lines:	.word	0:MAXLINES
inbuf:	.space	LINELEN
header:	.asciiz	"Lines by A. Gomez\n\n"
prompt:	.asciiz	"Enter text? "
newln:	.asciiz	"\n"

	.text
main:
	li	$s0, '\n'
	li	$s1, 0		# line counter 1:s1
	la	$s2, lines		# lines iterator:s2
	li	$a1, LINELEN
	
	la	$a0, header		# print header
	li	$v0, 4
	syscall
input:
	la	$a0, prompt		# print prompt
	li	$v0, 4
	syscall

	la	$a0, inbuf
	jal	gets		# get input line from user
	
	lb	$t0, ($a0)		# inbuf[0]:t0
	beq	$s0, $t0, prep	# if inbuf[0] == '\n', no more input
	
	jal	strdup
	sw	$v0, ($s2)		# add inbuf to lines
	
	addi	$s1, $s1, 1
	addi	$s2, $s2, 4
	bge	$s1, MAXLINES, prep	# if lines full, no more input
	b	input
prep:
	la	$s2, lines
	
	la	$a0, newln		# new line
	li	$v0, 4
	syscall
output:
	beqz	$s2, exit		# if no more lines left, exit
	
	lw	$a0, ($s2)		# load cur address in lines
	jal	puts
	
	addi	$s2, 4
	addi	$s1, $s1, -1
	b	output
exit:	
	li	$v0, 10		# exit
	syscall


#
# int strlen(cstring source)
#   returns the length of source
# parameters:
#   a0:  the cstring source address
#
# return values:
#   v0:  the length of the cstring
#
strlen:
	li	$v0, 0		# count:v0
	move	$t0, $a0		# cstring source:t0
loop:
	lb	$t1, ($t0)		# load current char in s:t1
	beqz	$t1, endl		# if end of source reached, end loop
	addi	$t0, 1
	addi	$v0, 1
	b	loop
endl:
	jr	$ra
	
	
#
# address malloc(int size)
#   allocates a block of size bytes of dynamic memory
#   and returns the address of the block's beggining
# parameters:
#   a0:  the size of the block
#
# return values:
#   v0:  the address of the beggining of the block
#
malloc:
	addi	$a0, 3		# round up size to nearest mult of 4
	andi	$a0, 0xfffc
	
	li	$v0, 9
	syscall
	
	jr	$ra
	
	
#
# cstring strdup(cstring source)
#   duplicates source and returns address of duplicate
# parameters:
#   a0:  the address of source cstring
#
# return values:
#   v0:  the address of the duplicate
#
strdup:
	addiu	$sp, $sp, -8	# space on stack for ra and source address
	sw	$ra, 4($sp)		# push ra onto stack
	sw	$a0, ($sp)		# push source onto stack
	
	jal	strlen
	
	addi	$v0, $v0, 1		# memory block size must include \0
	move	$a0, $v0
	jal	malloc		# duplicate cstring:v0
	
	lw	$t0, ($sp)		# source cstring iterator:t0
	move	$t1, $v0		# duplicate char iterator:t1
build:
	lb	$t2, ($t0)
	sb	$t2, ($t1)		# dup[t1] = source[t0]
	
	beqz	$t2, result		# if source[t0] = \0, end of source reached
	addi	$t0, $t0, 1
	addi	$t1, $t1, 1
	b	build
result:
	lw	$a0, ($sp)		# pop source cstring
	lw	$ra, 4($sp)		# pop ra from stack
	addiu	$sp, $sp, 8
	jr	$ra
	
	
#
# void gets(cstring dest, int num)
#   reads input string from keyboard, stores chars into dest
#   until (num-1) chars read or '\n' reached
# parameters:
#   a0:  the cstring dest that will hold the input string
#   a1:  1 more than the max number of input chars
#
# return values:
#   void
#
gets:
	li	$v0, 8		# read input string
	syscall
	jr	$ra
	
	
#
# void puts(cstring source)
#   output source to terminal
# parameters:
#   a0:  the cstring source that will be outputted
#
# return values:
#   void
#
puts:
	li	$v0, 4
	syscall
	jr	$ra