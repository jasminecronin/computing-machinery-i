// This program finds the maximum y-value of the expression:
// y = -5x^3 - 31x^2 + 4x + 31
// in the range -6 <= x <= 5
// Author: Jasmine Roebuck	30037334	Computing Machinery I	Sep 27, 2018

fmt:	.string "x = %2ld\t y = %5ld\t max = %3ld\n" // Formatted printing string

	.balign	4			// align instructions
	.global	main			// make main visible to OS

main:	stp	x29, x30, [sp, -16]!	// allocate stack space
	mov	x29, sp			// update the frame pointer

	mov	x19, -5000		// min-value for first comparison
	mov	x20, -5			// first coefficient
	mov	x21, 31			// second coefficient, constant
	mov	x22, 4			// third coefficient
	mov	x23, -6			// first value for x

test:	cmp	x23, 5			// x <= 5
	b.gt	done			// finished loop

	mul	x24, x23, x23		// x * x
	mul	x25, x23, x24		// y = x * x^2
	mul	x25, x25, x20		// y = y * -5
	mul	x26, x21, x24		// 31 * x^2
	sub	x25, x25, x26		// y = y - 31x^2
	mul	x26, x23, x22		// x * 4
	add	x25, x25, x26		// y = y + 4x
	add	x25, x25, x21		// y = y + 31

	cmp	x25, x19		// compare y with current max
	b.le	next			// if y <= max, skip next line
	mov	x19, x25		// set y as new max

next:	adrp	x0, fmt			// printing results
	add	x0, x0, :lo12:fmt	// get string address
	mov	x1, x23			// current x
	mov	x2, x25			// y result
	mov	x3, x19			// current max value
	bl 	printf			// print formatted string

	add	x23, x23, 1		// increment x
	b	test			// branch back to loop condition

done:	ldp	x29, x30, [sp], 16	// restore the stack
	ret				// return to the OS
