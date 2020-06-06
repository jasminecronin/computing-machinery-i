// This program finds the maximum y-value of the expression:
// y = -5x^3 - 31x^2 + 4x + 31
// in the range -6 <= x <= 5
// Author: Jasmine Roebuck	30037334	Computing Machinery I	Sep 27, 2018

fmt:	.string "x = %2ld\t y = %5ld\t max = %3ld\n"	// formatted string for printing
	define(max_r, x19)		// current max
	define(x_r, x23)		// x-value
	define(y_r, x25)		// y-value

	.balign	4			// align text
	.global	main			// make main visible to OS

main:	stp	x29, x30, [sp, -16]!	// allocate stack space
	mov	x29, sp			// update the frame pointer

	mov	max_r, -5000		// min-value for first comparison
	mov	x_r, -6			// first value for x
	mov	x20, -5			// first coefficient
	mov	x21, 31			// second coefficient, constant
	mov	x22, 4			// third coefficient

	b	test			// branch to loop conditional

top:	mul	x24, x_r, x_r		// x * x
	mul	y_r, x_r, x24		// y = x * x^2
	mul	y_r, y_r, x20		// y = y * -5
	msub	y_r, x21, x24, y_r	// y = y - (31 * x^2)
	madd	y_r, x_r, x22, y_r	// y = y + (x * 4)
	add	y_r, y_r, x21		// y = y + 31

	cmp	y_r, max_r		// compare y and max
	b.le	next			// if y <= max, skip to next
	mov	max_r, y_r		// set y as new max

next:	adrp	x0, fmt			// printing results
	add	x0, x0, :lo12:fmt	// get string address
	mov	x1, x_r			// current x
	mov	x2, y_r			// y result
	mov	x3, max_r		// max value
	bl 	printf			// print formatted string

	add	x_r, x_r, 1		// increment x
test:	cmp	x_r, 5			// compare x and 5
	b.le	top			// if x <= 5, run another loop

	ldp	x29, x30, [sp], 16	// restore the stack
	ret				// return to the OS
