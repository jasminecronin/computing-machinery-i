// This program initializes an array with random integers between 0 and 255
// The array is sorted using insertion sort and then printed to the console
// Jasmine Roebuck    30037334    October 26, 2018

size = 50					// number of elements in the array
array_size = size * 4				// equates for size of array
i_size = 4					// size of iteration variable i
j_size = 4					// size of iteration variable j
min_size = 4					// size of current minimum for sorting
array_s = 16					// equates for stack offset of array
i_s = array_s + array_size			// 16 + (50*4), stack offset of i
j_s = i_s + i_size				// stack offset of j
min_s = j_s + j_size				// stack offset of min
var_size = array_size + i_size + j_size + min_size	// memory needed for local variables
alloc = -(16 + var_size) & -16			// amount of memory to allocate
dealloc = -alloc				// amount of memory to deallocate

fp	.req	x29				// define FP register alias
lr	.req	x30				// define LR register alias

printArray: .string "v[%d]: %d\n"		// string for array printing

	.balign 4				// word align instructions
	.global main				// make main visible to the OS

main:	stp 	fp, lr, [sp, alloc]!		// allocate space for local variables
	mov	fp, sp				// update FP to the current SP


	// Initialize array to random positive integers, mod 256
	mov	w19, 0				// initialize i to 0
	str	w19, [fp, i_s]			// store i
	b	test1				// branch to test at bottom of loop1
loop1:	bl	rand				// call rand() function to get a random number
	and	w20, w0, 0xFF			// mod 256 the result
	add	x21, fp, array_s		// get array address
	ldr	w19, [fp, i_s]			// get current value of i
	str	w20, [x21, w19, SXTW 2]		// store result w20 into array[i]
	ldr	w19, [fp, i_s]			// get current value of i

	// Print out the array as it gets created
	adrp	x0, printArray			// set 1st arg of printf high
	add	x0, x0, :lo12:printArray	// set 1st arg of printf low
	ldr	w1, [fp, i_s]			// 2nd arg, current i
	ldr	w2, [x21, w19, SXTW 2]		// 3rd arg, array[i]
	bl	printf				// print

	add	w19, w19, 1			// increment i by 1
	str	w19, [fp, i_s]			// store new i
test1:	cmp	w19, size			// until i > 50
	b.lt	loop1				// branch to top of loop1


	// Sort the array using an insertion sort
	mov	w19, 0				// reset i to 0
	str	w19, [fp, i_s]			// store i
	b	test2a				// branch to outer sort loop

loop2a:	ldr	w19, [fp, i_s]			// get current value of i
	ldr	w26, [x21, w19, SXTW 2]		// set min to array[i]
	str	w26, [fp, min_s]		// store value of min
	ldr	w22, [fp, i_s]			// get current value of i
	str	w22, [fp, j_s]			// initialize j to current value of i
	b	test2b				// branch to inner sort loop

loop2b:	ldr	w22, [fp, j_s]			// get current value of j
	sub	w23, w22, 1			// to get j-1
	ldr	w25, [x21, w23, SXTW 2]		// get array[j-1]
	str	w25, [x21, w22, SXTW 2]		// arr[j] = arr[j-1]
	
	sub	w22, w22, 1			// decrement j
	str	w22, [fp, j_s]			// store j
test2b:	cmp	w22, 0				// test j > 0			
	b.le	cont				// branch to remainder of outer loop
	sub	w23, w22, 1			// get j-1
	ldr	w26, [fp, min_s]		// get current min value
	ldr	w25, [x21, w23, SXTW 2]		// get array[j-1]
	cmp	w26, w25			// test min < array[j-1]
	b.lt	loop2b				// branch to top of inner loop

cont:	str	w26, [x21, w22, SXTW 2]		// v[j] = min
	add	w19, w19, 1			// increment i
	str	w19, [fp, i_s]			// store i

test2a:	cmp	w19, size			// until i > 50
	b.lt	loop2a				// branch to top of outer sort loop


	// Print out the sorted array
	mov	w19, 0				// reset i to 0
	str	w19, [fp, i_s]			// store i
	b	test3				// branch to final loop test

loop3:	adrp	x0, printArray			// set 1st arg of printf high
	add	x0, x0, :lo12:printArray	// set 1st arg of printf low
	ldr	w1, [fp, i_s]			// 2nd arg, current i
	ldr	w2, [x21, w19, SXTW 2]		// 3rd arg, array[i]
	bl	printf				// print

	add	w19, w19, 1			// increment i by 1
	str	w19, [fp, i_s]			// store new i
test3:	cmp	w19, size			// until i > 50
	b.lt	loop3				// branch to top of loop3

	mov	x0, 0				// restore registers
	ldp	x29, x30, [sp], 16		// restore FP and LR from stack
	ret					// return to caller
