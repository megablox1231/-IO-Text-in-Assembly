#
#	Name:		Gomez, Alex
#	Project:		4
#	Due:		May 14, 2021
#	Course:		cs-2640-02-sp21
#
#	Description:
#			Takes a, b, and c of a quadratic equation
#			as input and output the results.
#

	.data
header:	.asciiz	"Quadratic Equation Solver by A. Gomez\n\n"
prompta:	.asciiz	"Enter values for a? "
promptb:	.asciiz	"Enter values for b? "
promptc:	.asciiz	"Enter values for c? "
imag:	.asciiz	"Roots are imaginary."
nosoln:	.asciiz	"Not a quadratic equation."
onesoln:	.asciiz	"x = "
x1soln:	.asciiz	"x1 = "
x2soln:	.asciiz	"x2 = "
newln:	.asciiz	"\n"

	.text
main:
	la	$a0, header		# print header
	li	$v0, 4
	syscall
	
	la	$a0, prompta	# print prompt A
	li	$v0, 4
	syscall
	li	$v0, 6		# read a
	syscall
	mov.s	$f12, $f0
	
	la	$a0, promptb	# print prompt B
	li	$v0, 4
	syscall
	li	$v0, 6		# read b
	syscall
	mov.s	$f13, $f0
	
	la	$a0, promptc	# print prompt C
	li	$v0, 4
	syscall
	li	$v0, 6		# read c
	syscall
	mov.s	$f14, $f0
	
	la	$a0, newln		# print new line
	li	$v0, 4
	syscall
	
	jal	solveqe
	
	bltz	$v0, imagin		# if status == -1, roots imaginary
	beqz	$v0, notquad	# if status == 0, not quadratic
	ble	$v0, 1, line	# if status == 1, one solution
twosoln:
	la	$a0, x1soln		# print first solution
	li	$v0, 4
	syscall
	mov.s	$f12, $f0
	li	$v0, 2
	syscall
	
	la	$a0, newln		# print new line
	li	$v0, 4
	syscall
	
	la	$a0, x2soln		# print second solution
	li	$v0, 4
	syscall
	mov.s	$f12, $f1
	li	$v0, 2
	syscall
	b	exit
imagin:
	la	$a0, imag		# print imaginary statement
	li	$v0, 4
	syscall
	b	exit
notquad:
	la	$a0, nosoln		# print no solutions statement
	li	$v0, 4
	syscall
	b	exit
line:
	la	$a0, onesoln	# print one solution
	li	$v0, 4
	syscall
	mov.s	$f12, $f0
	li	$v0, 2
	syscall
exit:
	la	$a0, newln		# print new line
	li	$v0, 4
	syscall
	
	li	$v0, 10
	syscall
	
	
#
# int solveqe(float a, float b, float c)
#   finds solution using quadratic formula and returns
#   solutions in f0-1 as appropriate and status of solutions in v0.
# parameters:
#   f12:  float coefficient a
#   f13:  float coefficient b
#   f14:  float coefficient c
#
# return values:
#   v0: solution status (-1: imaginary, 0: not quadratic,
#       1: 1 soultion, 2: 2 solutions)
#
	.globl solveqe
solveqe:
	addiu	$sp, $sp, -24	# space for params, ra, saved regs
	s.s	$f12, 20($sp)	# push a onto stack
	s.s	$f13, 16($sp)	# push b onto stack
	s.s	$f20, 8($sp)
	s.s	$f21, 4($sp)	# push saved regs onto stack
	sw	$ra, ($sp)		# push ra onto stack
	

	li.s	$f20, 0.0
	c.eq.s	$f12, $f20
	bc1f	dscrm		# if a != 0, go calc discrim
	
	c.eq.s	$f13, $f20
	bc1f	linear		# if b != 0, eq is linear
	li	$v0, 0		# status 0:v0
	b	end
linear:
	sub.s	$f13, $f20, $f13
	div.s	$f0, $f14, $f13	# linear solution x:f0
	li	$v0, 1		# status 1:v0
	b	end
dscrm:
	li.s	$f21, 4.0
	mul.s	$f21, $f21, $f12
	mul.s	$f21, $f21, $f14	# calc 4ac:f21
	mul.s	$f13, $f13, $f13
	sub.s	$f12, $f13, $f21	# calc b^2-4ac = d:f12
	
	c.lt.s	$f12, $f20
	bc1f	else		# if d >= 0, go calc 2 solutions
	
	li	$v0, -1		# status -1:v0
	b	end
else:
	jal	sqrt
	l.s	$f12, 20($sp)	# pop a from stack:f12
	l.s	$f13, 16($sp)	# pop b from stack:f13
	
	sub.s	$f21, $f20, $f13	# -b:f21
	sub.s	$f1, $f21, $f0	# -b - sqrt(d)
	li.s	$f20, 2.0
	mul.s	$f12, $f12, $f20
	div.s	$f1, $f1, $f12	# (-b-sqrt(d))/2a:f1 (soln x2)
	
	add.s	$f0, $f21, $f0	# -b + sqrt(d)
	div.s	$f0, $f0, $f12	# (-b+sqrt(d))/2a:f0 (soln x1)
	
	li	$v0, 2		# status 2:v0
end:
	lw	$ra, ($sp)		# pop ra off stack
	l.s	$f20, 8($sp)
	l.s	$f21, 4($sp)	# pop saved regs off stack
	addiu	$sp, $sp, 24
	jr	$ra
	
	
#
# float sqrt(float x)
#   finds and returns the square root of x
# parameters:
#   f12:  float x
#
# return values:
#   f0: square root of x
#
	.globl sqrt
sqrt:
	li.s	$f10, 0.000001	# epsilon:f10
	li.s	$f4, 2.0
	li.s	$f6, 0.0
	div.s	$f0, $f12, $f4	# x/2=guess:f0
	
	c.le.s	$f0, $f6
	bc1t	stop		# if guess <= 0, return guess
while:
	mov.s	$f7, $f0		# lastguess:f7
	
	div.s	$f8, $f12, $f0
	add.s	$f0, $f0, $f8
	div.s	$f0, $f0, $f4	# calc new guess
	
	sub.s	$f9, $f0, $f7
	abs.s	$f9, $f9		# fabs(guess-lastguess):f9
	c.lt.s	$f10, $f9
	bc1t	while		# if |x'-x|< e, stop guessing
stop:
	jr	$ra