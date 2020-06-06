// This program performs the multiplication 200 * 522133279

// Jasmine Roebuck, 30037334
// Computing Machinery I, October 12, 2018

	define(FALSE, w27)			// value for false boolean
	define(TRUE, w28)			// value for true boolean

	define(multiplier, w19)			// multiplier for multiplication
	define(multiplicand, w20)		// multiplicant for multiplication
	define(product, w21)			// product of multiplication
	define(i, w22)				// iteration variable
	define(negative, w23)			// boolean to track negatives
	define(result, x24)			// extended register to finish result
	define(temp1, x25)			// first register for result
	define(temp2, x26)			// second register for result

initialValues:		.string	"Multiplier = 0x%08x (%d) \t Multiplicand = 0x%08x (%d)\n\n"	// print string for starting values
productMultiplier:	.string "Product = 0x%08x \t Multiplier = 0x%08x\n"			// print string for product and multiplier
finalResult:		.string "64-bit results = 0x%016lx (%ld)\n"				// print string for result

	.balign 4				// word align instructions
	.global main				// make main visible to the OS

main:	stp	x29, x30, [sp, -16]!		// 
	mov	x29, sp				// update to current SP

	mov	FALSE, 0			// give FALSE value of 0
	mov	TRUE, 1				// give TRUE value of 1
	mov	multiplicand, 522133279		// give multiplicand value of 522133279
	mov	multiplier, 200			// give multiplier value of 200
	mov	product, 0			// give product value of 0
	mov	i, 0				// give i value of 0

	adrp	x0, initialValues		// set 1st arg of printf high
	add	x0, x0, :lo12:initialValues	// set 1st arg of printf low
	mov	w1, multiplier			// 2nd arg
	mov	w2, multiplier			// 3rd arg
	mov	w3, multiplicand		// 4th arg
	mov	w4, multiplicand		// 5th arg
	bl	printf				// print initial values

	cmp	multiplier, 0			// if test, multiplier < 0
	b.ge	else				// if multiplier >= 0, go to else
	mov	negative, TRUE			// multiplier is negative
	b	next				// go to next

else:	mov	negative, FALSE			// multiplier is not negative	

next:	b	test				// go to for loop condition

top:	tst	multiplier, 0x1			// test if bit-0 in multiplier == 1
	b.eq	nextIf				// go to nextIf
	add	product, product, multiplicand	// add multiplicand to product

nextIf:	asr	multiplier, multiplier, 1	// shift right multiplier

	tst	product, 0x1			// test if bit-0 in product == 1
	b.eq	else2				// go to else2
	orr	multiplier, multiplier, 0x80000000	// bitwise OR
	b	nextIf2				// go to nextIf2

else2:	and	multiplier, multiplier, 0x7FFFFFFF	// bitwise AND

nextIf2:asr	product, product, 1		// shift right product

	add	i, i, 1				// i++

test:	cmp	i, 32				// if i < 32
	b.lt	top				// repeat loop

	cmp	negative, TRUE			// if test, negative == FALSE
	b.ne	next2				// if negative == 1, go to else2
	sub	product, product, multiplicand	// product = product - multiplicand

next2:	adrp	x0, productMultiplier		// set 1st arg of printf high
	add	x0, x0, :lo12:productMultiplier	// set 1st arg of printf low
	mov	w1, product			// 2nd arg
	mov	w2, multiplier			// 3rd arg
	bl	printf				// print product and multiplier

	sxtw	temp1, product			// sign extend product into temp1
	and	temp1, temp1, 0xFFFFFFFF	// bitwise AND
	lsl	temp1, temp1, 32		// shift temp1 left by 32 bits
	sxtw	temp2, multiplier		// sign extend multiplier into temp2
	and	temp2, temp2, 0xFFFFFFFF	// bitwise AND
	add	result, temp1, temp2		// result = temp1 + temp2

	adrp	x0, finalResult			// set 1st arg of printf high
	add	x0, x0, :lo12:finalResult	// set 1st arg of printf low
	mov	x1, result			// 2nd arg
	mov	x2, result			// 3rd arg
	bl	printf				// print final result

final:
	mov	w0, 0				// restore registers
	ldp	x29, x30, [sp], 16		// restore FP and LR from stack
	ret					// return to caller
