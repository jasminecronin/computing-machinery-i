// This program reads a list of floating point values from
// a bin file, then uses Newton's Method to find the cube roots
// of each floating point value. These are then printed out to
// a formatted table.
// Jasmine Roebuck, 30037334, Computing Machinery I, Dec. 7, 2018

buf_size = 8						// equate for binary string size
alloc = -(16 + buf_size) & -16				// amount for memory allocation in main
dealloc = -alloc					// amount for memory deallocation in main
buf_s = 16						// offset for read in buffer

define(fd_r, w19)					// register for file descriptor
define(nread_r, w20)					// register for number of bytes read
define(buf_base_r, x21)					// register for base address of buffer
define(argv_r, x22)					// register for command line argument array

	.text						// open text section
fmt:	.string "%14.10f \t %14.10f\n"			// format string for table printing
header:	.string "  Input Value \t   Cube Root\n"	// table header string
openerror: .string "Error: could not open file.\n"	// error string for error opening file

	.balign 4					// word align instructions
	.global main					// make main visible to OS

main:	stp	x29, x30, [sp, alloc]!			// allocate stack memory
	mov	x29, sp					// set fp

	mov	argv_r, x1				// get address of argument array
	mov	w23, 1					// get index 1
	ldr	x24, [argv_r, w23, SXTW 3]		// address of filename is in x25

	mov	w0, -100				// 1st arg
	mov	x1, x24					// 2nd arg (pathname from command line)
	mov	w2, 0					// 3rd arg (read only)
	mov	w3, 0					// 4th arg (not used)
	mov	x8, 56					// openat I/O request
	svc	0					// call system function
	mov	fd_r, w0				// save file descriptor
	cmp	fd_r, 0					// error check
	b.ge	open_ok					// branch if file successfully opened

	adrp	x0, openerror				// get 1st arg error string
	add	x0, x0, :lo12:openerror			// get 1st arg error string
	bl	printf					// call print
	mov	w0, -1					// return an error value
	b	quit					// branch to end
	
open_ok:						// file successfully opened
	add	buf_base_r, x29, buf_s			// get address of read buffer
	adrp	x0, header				// set 1st arg table header string
	add	x0, x0, :lo12:header			// set 1st arg table header string
	bl	printf					// call print

top:	mov	w0, fd_r				// 1st arg file descriptor
	mov	x1, buf_base_r				// 2nd arg address to read buffer
	mov	x2, buf_size				// 3rd arg read n bytes
	mov	x8, 63					// 4th arg read I/O request
	svc	0					// call sys function, n_read is in x0

	mov	nread_r, w0				// save n_read
	cmp	nread_r, buf_size			// did we read n bytes?
	b.ne	close					// if not, hit end of file, branch to close file

	ldr	d0, [buf_base_r]			// load what was saved in the buffer into 1st arg
	bl	cuberoot				// call cube root
	fmov	d8, d0					// save returned value	
	adrp	x0, fmt					// set 1st arg format string
	add	x0, x0, :lo12:fmt			// set 1st arg format string
	ldr	d0, [buf_base_r]			// 2nd arg, value read from the file
	fmov	d1, d8					// 3rd arg, computed cube root
	bl	printf					// call print
	b	top					// repeat for next 8 bytes in the file

close:	mov	w0, fd_r				// get file descriptor arg
	mov	x8, 57					// close I/O request
	svc	0					// call sys function
	mov	w0, 0					// return no error
		
quit:	ldp	x29, x30, [sp], dealloc			// deallocate stack memory
	ret						// return


	.data						// open data section
prec_m:	.double	0r1.0e-10				// set precision for Newton's method

	.text						// open text section
define(input_r, d16)					// register for input value passed
define(three_r, d17)					// register for 3.0f
define(err_r, d18)					// register for error tolerance
define(x_r, d19)					// register for x value
define(y_r, d20)					// register for y value
define(dy_r, d21)					// register for calculated dy
define(dydx_r, d22)					// register for calculated dy/dx
define(absdy_r, d23)					// register for absolute value of dy

	.balign 4					// word align instructions
	.global cuberoot				// make cuberoot visible to OS
cuberoot:						// cuberoot function
	stp	x29, x30, [sp, -16]!			// allocate stack memory
	mov	x29, sp					// set fp

	fmov	input_r, d0				// get input value
	fmov	three_r, 3.0				// get value 3.0f
	fdiv	x_r, input_r, three_r			// x = input / 3.0
	adrp	x9, prec_m				// get address of precision
	add	x9, x9, :lo12:prec_m			// get address of precision
	ldr	err_r, [x9]				// get value of precision
	fmul	err_r, err_r, input_r			// error tolerance = input * precision

loop:	fmul	y_r, x_r, x_r				// y + x * x
	fmul	y_r, y_r, x_r				// y = y * x = x * x * x
	fsub	dy_r, y_r, input_r			// dy = y - input
	fabs	absdy_r, dy_r				// get absolute value of dy
	fcmp	absdy_r, err_r				// test for precision
	b.lt	done					// if value precise enough, skip to return
	fmul	dydx_r, x_r, x_r			// dy/dx = x * x
	fmul	dydx_r, dydx_r, three_r			// dy/dx = x * x * 3.0
	fdiv	d31, dy_r, dydx_r			// get dy / (dy/dx)
	fsub	x_r, x_r, d31				// x = x - (dy / (dy/dx))
	b	loop					// repeat calculation

done:	fmov	d0, x_r					// put final value in return register
	ldp	x29, x30, [sp], 16			// deallocate stack memory
	ret						// return
