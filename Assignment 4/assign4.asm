// This program creates 2 box structures, makes changes to each and prints
// their values before and after. It will make use of closed subroutines, 
// nested structures, and argument passing with registers and memory.
// Jasmine Roebuck, 30037334   Computing Machinery I

initial: .string "Initial box values:\n"		// string for initial print values
changed: .string "\nChanged box values:\n"		// string for changed print values

x_s = 0							// offset for point.x
y_s = 4							// offset for point.y
point_size = 8						// size for point structure

width_s = 0						// offset for dimension.width
height_s = 4						// offset for dimension.height
dimension_size = 8					// size for dimension structure

area_s = 0						// offset for box.area
point_s = 4						// offset for box.origin
dimension_s = 12					// offset for box.size
box_size = 20						// size of box structure
b_s = 16						// offset for box structure

allocBox = -(16 + box_size) & -16			// memory needed for 1 box structure
deallocBox = -allocBox					// equate for deallocation

define(FALSE, 0)					// define FALSE to be 0
define(TRUE, 1)						// define TRUE to be 1

	.balign 4					// ensure word alignment
newBox:	stp	x29, x30, [sp, allocBox]!		// function to create a new box
	mov	x29, sp					// set FP

	str	wzr, [x29, b_s + point_s + x_s]		// set box.origin.x = 0
	str	wzr, [x29, b_s + point_s + y_s]		// set box.origin.y = 0
	mov	w9, 1					// initialize value for width & height
	str	w9, [x29, b_s + dimension_s + width_s]	// set box.size.width = 1
	str	w9, [x29, b_s + dimension_s + height_s]	// set box.size.height = 1
	str	w9, [x29, b_s + area_s]			// set box.area = width * height = 1

	ldr	w9, [x29, b_s + point_s + x_s]		// load box.origin.x
	str	w9, [x8, point_s + x_s]			// return box.origin.x
	ldr	w9, [x29, b_s + point_s + y_s]		// load box.origin.y
	str	w9, [x8, point_s + y_s]			// return box.origin.y
	ldr	w9, [x29, b_s + dimension_s + width_s]	// load box.size.width
	str	w9, [x8, dimension_s + width_s]		// return box.size.width
	ldr	w9, [x29, b_s + dimension_s + height_s]	// load box.size.height
	str	w9, [x8, dimension_s + height_s]	// return box.size.height
	ldr	w9, [x29, b_s + area_s]			// load box.area
	str	w9, [x8, area_s]			// return box.area

	ldp	x29, x30, [sp], deallocBox		// restore stack memory
	ret						// return

move:	stp	x29, x30, [sp, -16]!			// function for changing box's origin
	mov	x29, sp					// set FP
	
	mov	w9, w1					// load first parameter
	str	w9, [x0, point_s + x_s]			// store first parameter as x value
	mov	w9, w2					// load second parameter
	str	w9, [x0, point_s + y_s]			// store second parameter as y value
	
	ldp	x29, x30, [sp], 16			// restore pointers
	ret						// return

expand:	stp	x29, x30, [sp, -16]!			// function to scale size of box
	mov	x29, sp					// set FP

	mov	w9, w1					// multiplication factor
	ldr	w10, [x0, dimension_s + width_s]	// load width
	mul	w10, w10, w9				// multiply by factor
	str	w10, [x0, dimension_s + width_s]	// store new width
	ldr	w11, [x0, dimension_s + height_s]	// load height
	mul	w11, w11, w9				// multiply by factor
	str	w11, [x0, dimension_s + height_s]	// store new height
	mul	w9, w10, w11				// calculate new area
	str	w9, [x0, area_s]			// store new area

	ldp	x29, x30, [sp], 16			// restore pointers
	ret						// return

equal:	stp	x29, x30, [sp, -16]!			// function to see if two boxes are equal
	mov	x29, sp					// set FP

	mov	w11, FALSE				// return value if a test fails
	ldr	w9, [x0, point_s + x_s]			// get box 1 x
	ldr	w10, [x1, point_s + x_s]		// get box 2 x
	cmp	w9, w10					// compare
	b.ne	fail					// return if !=
	ldr	w9, [x0, point_s + y_s]			// get box 1 y
	ldr	w10, [x1, point_s + y_s]		// get box 2 y
	cmp	w9, w10					// compare
	b.ne	fail					// return if !=
	ldr	w9, [x0, dimension_s + width_s]		// get box 1 width
	ldr	w10, [x1, dimension_s + width_s]	// get box 2 width
	cmp	w9, w10					// compare
	b.ne	fail					// return if !=
	ldr	w9, [x0, dimension_s + height_s]	// get box 1 height
	ldr	w10, [x1, dimension_s + height_s]	// get box 2 height
	cmp	w9, w10					// compare
	b.ne	fail					// return if !=
	mov	w11, TRUE				// if all tests pass, return true

fail:	mov	w0, w11					// get return value
	ldp	x29, x30, [sp], 16			// restore pointers
	ret						// return


boxStats: .string "Box %s origin = (%d, %d)  width = %d  height = %d  area = %d\n"	// print string for box stats
first:	.string "first"					// box 1 label
second:	.string "second"				// box 2 label

	.balign 4					// ensure word alignment
printBox:						// function to print box attributes
	stp	x29, x30, [sp, -16]!			// allocate memory
	mov	x29, sp					// set FP
	ldr	w2, [x0, point_s + x_s]			// set 3rd arg
	ldr	w3, [x0, point_s + y_s]			// set 4th arg
	ldr	w4, [x0, dimension_s + width_s]		// set 5th arg
	ldr	w5, [x0, dimension_s + height_s]	// set 6th arg
	ldr	w6, [x0, area_s]			// set 7th arg
	adrp	x0, boxStats				// set 1st arg high
	add	x0, x0, :lo12:boxStats			// set 1st arg low
	bl	printf					// call print
	ldp	x29, x30, [sp], 16			// restore pointers
	ret						// return

alloc = -(16 + box_size * 2) & -16			// allocate memory for 2 boxes
dealloc = -alloc					// equate for deallocation
box1_s = 16						// offset for box 1
box2_s = box1_s + box_size				// offset for box 2

	.global main					// make main visible to OS
main:	stp	x29, x30, [sp, alloc]!			// allocate stack memory
	mov	x29, sp					// set FP

	add	x8, x29, box1_s				// address for box 1
	bl	newBox					// create box 1
	add	x8, x29, box2_s				// address for box 2
	bl	newBox					// create box 2

	adrp	x0, initial				// set 1st arg high
	add	x0, x0, :lo12:initial			// set 1st arg low
	bl	printf					// call print
	adrp	x1, first				// label for box 1
	add	x1, x1, :lo12:first			// label for box 1
	add	x0, x29, box1_s				// set arg for box 1
	bl	printBox				// print box 1
	adrp	x1, second				// label for box 2
	add	x1, x1, :lo12:second			// label for box 2
	add	x0, x29, box2_s				// set arg for box 2
	bl	printBox				// print box 2

	add	x0, x29, box1_s				// set pointer for box 1
	add	x1, x29, box2_s				// set pointer for box 2
	bl	equal					// result is in x0
	mov	w24, TRUE				// get value for TRUE
	cmp	w0, TRUE				// compare
	b.ne	next					// skip next 2 functions if not equal

	add	x0, x29, box1_s				// set pointer arg for box 1
	mov	w1, -5					// set x-value arg
	mov	w2, 7					// set y-value arg
	bl	move					// move box 1

	add	x0, x29, box2_s				// set pointer arg for box 2
	mov	w1, 3					// set scale factor arg
	bl	expand					// expand box 2

next:							// dest if boxes were not equal
	adrp	x0, changed				// set 1st arg high
	add	x0, x0, :lo12:changed			// set 1st arg low
	bl	printf					// call print
	adrp	x1, first				// label for box 1
	add	x1, x1, :lo12:first			// label for box 1
	add	x0, x29, box1_s				// set arg for box 1
	bl	printBox				// print box 1
	adrp	x1, second				// label for box 2
	add	x1, x1, :lo12:second			// lebel for box 2
	add	x0, x29, box2_s				// set arg for box 2
	bl	printBox				// print box 2

	ldp	x29, x30, [sp], dealloc			// restore stack memory
	ret						// return
