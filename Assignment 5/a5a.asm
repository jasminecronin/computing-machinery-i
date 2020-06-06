// The program defines all called functions from a5aMain.c
// These are the enqueue, dequeue, queueFull, queueEmpty, and display functions
// Jasmine Roebuck, 30037334  Nov. 30, 2018

define(QUEUESIZE, 8)				// number of elements that can be stored in the queue
define(MODMASK, 0x7)				// modmask for determining index in circular array
define(FALSE, 0)				// give FALSE value of 0
define(TRUE, 1)					// give TRUE value of 1

	.bss					// open .bss section
	.global queue_m				// make queue array global
queue_m: .skip	QUEUESIZE*4			// allocate space for uninitialized queue array
	.data					// open .data section
	.global head_m				// make head index global
head_m:	.word	-1				// initialize head index to -1
	.global tail_m				// make tail index global
tail_m:	.word	-1				// initialize tail index to -1

	.text									// open .text section
fullError: .string "\nQueue overflow! Cannot enqueue into a full queue.\n"	// print string for inserting into full queue
emptyError: .string "\nQueue underflow! Cannot dequeue from an empty queue.\n"	// print string for dequeueing from empty queue
emptyQueue: .string "\nEmpty queue\n"						// contents of empty queue
contents: .string "\nCurrent queue contents:\n"					// print string for display queue
element: .string "  %d"								// print string for queue element
queueHead: .string " <-- head of queue"						// label for head queue element
queueTail: .string " <-- tail of queue"						// label for tail queue element
newline: .string "\n"								// newline character string

value_size = 4					// size of enqueued value
allocVal = -(16 + value_size) & -16		// stack allocation for enqueue
deallocVal = -allocVal				// stack deallocation for enqueue
value_save = 16					// offset of enqueued value

	.balign 4				// word align instructions
	.global enqueue				// make enqueue visible to OS
enqueue:					// enqueue function
	stp	x29, x30, [sp, allocVal]!	// allocation stack space
	mov	x29, sp				// change fp

	str	w0, [x29, value_save]		// value to be enqueued now stored on stack

	bl	queueFull			// call queueFull, return value in w0
	mov	w9, w0				// get return value
	cmp	w9, TRUE			// was return value TRUE?
	b.ne	next1				// skip to next1
	adrp	x0, fullError			// set 1st print arg
	add	x0, x0, :lo12:fullError		// set 1st print arg
	bl	printf				// print error message
	b	fin1				// skip to end

next1:	bl	queueEmpty			// call queueEmpty, return value in w0
	mov	w9, w0				// get return value
	cmp	w9, TRUE			// was return value TRUE?
	b.ne	else1				// skip to else1
	mov	w9, 0				// get zero
	adrp	x10, head_m			// get address of head
	add	x10, x10, :lo12:head_m		// get address of head
	str	w9, [x10]			// head = 0
	adrp	x10, tail_m			// get address of tail
	add	x10, x10, :lo12:tail_m		// get address of tail
	str	w9, [x10]			// tail = 0
	b	next2				// skip to next 2
else1:	adrp	x9, tail_m			// get address of tail
	add	x9, x9, :lo12:tail_m		// get address of tail
	ldr	w10, [x9]			// get value of tail
	add	w10, w10, 1			// ++tail
	and	w10, w10, MODMASK		// bitwise and with modmask
	str	w10, [x9]			// tail == ++tail & MODMASK	
	
next2:	ldr	w9, [x29, value_save]		// get the value to enqueue
	
	adrp	x10, tail_m			// get address of tail
	add	x10, x10, :lo12:tail_m		// get address of tail
	ldr	w10, [x10]			// get value of tail index
	adrp	x11, queue_m			// get address of queue
	add	x11, x11, :lo12:queue_m		// get address of queue
	str	w9, [x11, w10, SXTW 2]		// queue[tail] = value
fin1:						// end of function
	ldp	x29, x30, [sp], deallocVal	// restore stack space
	ret					// return


val_size = 4					// size of dequeued value
allocV = -(16 + val_size) & -16			// stack allocation for dequeue
deallocV = -allocV				// stack deallocation for dequeue
val_save = 16					// offset for dequeued value

	.balign 4				// word align instructions
	.global dequeue				// make dequeue visible to OS
dequeue:					// dequeue function
	stp	x29, x30, [sp, allocV]!		// allocation stack space
	mov	x29, sp				// set fp

	bl	queueEmpty			// call queueEmpty, return value in w0
	mov	w9, w0				// get return value
	cmp	w9, TRUE			// was return value TRUE?
	b.ne	next7				// skip to next7
	adrp	x0, emptyError			// set 1st print arg
	add	x0, x0, :lo12:emptyError	// set 1st print arg
	bl	printf				// print queue empty error
	mov	w9, -1				// get value -1
	str	w9, [x29, val_save]		// value = -1
	b	fin2				// skip to end
	
next7:	adrp	x9, head_m			// get address of head
	add	x9, x9, :lo12:head_m		// get address of head
	ldr	w10, [x9]			// get value of head index
	adrp	x9, queue_m			// get address of queue
	add	x9, x9, :lo12:queue_m		// get address of queue
	ldr	w9, [x9, w10, SXTW 2]		// get value of queue[head]
	str	w9, [x29, val_save]		// store value to be returned
	
	adrp	x9, head_m			// get address of head
	add	x9, x9, :lo12:head_m		// get address of head
	ldr	w10, [x9]			// get value of head

	adrp	x9, tail_m			// get address of tail
	add	x9, x9, :lo12:tail_m		// get address of tail
	ldr	w11, [x9]			// get value of tail
	
	cmp	w10, w11			// if (head == tail)
	b.ne	next8				// skip to next8 if !=
	mov	w10, -1				// get value -1
	adrp	x9, head_m			// get address of head
	add	x9, x9, :lo12:head_m		// get address of head
	str	w10, [x9]			// head = -1
	adrp	x9, tail_m			// get address of tail
	add	x9, x9, :lo12:tail_m		// get address of tail
	str	w10, [x9]			// tail = -1
	b	fin2				// skip to end

next8:	adrp	x9, head_m			// get address of head
	add	x9, x9, :lo12:head_m		// get address of head
	ldr	w10, [x9]			// get head value
	add	w10, w10, 1			// increment head
	and	w10, w10, MODMASK		// bitwise and with modmask
	str	w10, [x9]			// store head
	
fin2:	ldr	w0, [x29, val_save]		// put dequeued value into return register
	ldp	x29, x30, [sp], deallocV	// deallocate stack space
	ret					// return


	.balign 4				// word align instructions
	.global queueFull			// make queueFull visible to the OS
queueFull:					// queueFull function
	stp	x29, x30, [sp, -16]!		// allocate stack space
	mov	x29, sp				// set fp

	adrp	x9, head_m			// get address of head
	add	x9, x9, :lo12:head_m		// get address of head
	ldr	w10, [x9]			// get value of head
	adrp	x9, tail_m			// get address of tail
	add	x9, x9, :lo12:tail_m		// get address of tail
	ldr	w11, [x9]			// get value of tail

	add	w11, w11, 1			// tail + 1
	and	w11, w11, MODMASK		// (tail + 1) & MODMASK
	cmp	w10, w11			// if (((tail + 1) & MODMASK) == head)
	b.ne	notfull				// skip to notfull
	mov	w0, TRUE			// set return value to TRUE
	b	full				// skip to full
notfull:					// queue is not full
	mov	w0, FALSE			// set return value to FALSE
full:	ldp	x29, x30, [sp], 16		// deallocate stack space
	ret					// return


	.balign 4				// word align instructions
	.global queueEmpty			// make queueEmpty visible to OS
queueEmpty:					// queueEmpty function
	stp	x29, x30, [sp, -16]!		// allocate stack space
	mov	x29, sp				// set fp

	adrp	x9, head_m			// get address of head
	add	x9, x9, :lo12:head_m		// get address of head
	ldr	w10, [x9]			// get value of head

	mov	w11, -1				// get value -1
	cmp	w10, w11			// if (head == -1)
	b.ne	notempty			// skip to notempty if !=
	mov	w0, TRUE			// set return value to TRUE
	b	empty				// skip to empty
notempty:					// queue was not empty
	mov	w0, FALSE			// set return value to FALSE
empty:						// queue was empty
	ldp	x29, x30, [sp], 16		// deallocate stack space
	ret					// return


count_size = 4							// size of count variable
i_size = 4							// size of index variable
j_size = 4							// size of iteration variables
allocDisplay = -(16 + count_size + i_size + j_size) & -16	// amount of stack space to allocate
deallocDisplay = -allocDisplay					// amount of stack space to deallocate
count_save = 16							// offset of count
i_save = 20							// offset of i
j_save = 24							// offset of j

	.balign 4				// word align instructions
	.global display				// make display visible to OS
display:					// display function
	stp	x29, x30, [sp, allocDisplay]!	// allocate stack space
	mov	x29, sp				// set fp

	bl	queueEmpty			// call queueEmpty, return value in w0
	mov	w9, w0				// get return value
	cmp	w9, TRUE			// was return value TRUE?
	b.ne	next3				// skip to next3 if !=
	adrp	x0, emptyQueue			// set 1st print arg
	add	x0, x0, :lo12:emptyQueue	// set 1st print arg
	bl	printf				// print empty queue message
	b	donePrint			// skip to end

next3:	adrp	x9, tail_m			// get address of tail
	add	x9, x9, :lo12:tail_m		// get address of tail
	ldr	w10, [x9]			// get value of tail

	adrp	x9, head_m			// get address of head
	add	x9, x9, :lo12:head_m		// get address of head
	ldr	w11, [x9]			// get value of head

	sub	w12, w10, w11			// count = tail - head
	add	w12, w12, 1			// count = tail - head + 1
	str	w12, [x29, count_save]		// store count

	cmp	w12, 0				// if (count <= 0)
	b.gt	next4				// skip to next4 if >
	add	w12, w12, QUEUESIZE		// count += QUEUESIZE
	str	w12, [x29, count_save]		// save count

next4:	adrp	x0, contents			// set 1st print arg
	add	x0, x0, :lo12:contents		// set 1st print arg
	bl	printf				// print contents string
	adrp	x9, head_m			// get address of head
	add	x9, x9, :lo12:head_m		// get address of head
	ldr	w13, [x9]			// get value of head
	str	w13, [x29, i_save]		// i = head

	mov	w14, 0				// get value -
	str	w14, [x29, j_save]		// store j = 0
	b	looptest			// branch to for loop test

loop:	adrp	x0, element			// set 1st print arg
	add	x0, x0, :lo12:element		// set 1st print arg
	adrp	x9, queue_m			// get address of queue array
	add	x9, x9, :lo12:queue_m		// get address of queue array
	ldr	w13, [x29, i_save]		// get value of i
	ldr	w1, [x9, w13, SXTW 2]		// set 2nd print arg, queue[i]
	bl	printf				// print element string

	ldr	w13, [x29, i_save]		// get value of i
	adrp	x9, head_m			// get address of head
	add	x9, x9, :lo12:head_m		// get address of head
	ldr	w11, [x9]			// get value of head
	cmp	w13, w11			// if (i == head)
	b.ne	next5				// skip to next5 if !=
	adrp	x0, queueHead			// set 1st print arg
	add	x0, x0, :lo12:queueHead		// set 1st print arg
	bl	printf				// print head of queue label

next5:	ldr	w13, [x29, i_save]		// get value of i
	adrp	x9, tail_m			// get address of tail
	add	x9, x9, :lo12:tail_m		// get address of tail
	ldr	w10, [x9]			// get value of tail
	cmp	w13, w10			// if (i == tail)
	b.ne	next6				// skip to next6 if !=
	adrp	x0, queueTail			// set 1st print arg
	add	x0, x0, :lo12:queueTail		// set 1st print arg
	bl	printf				// print tail of queue label

next6:	adrp	x0, newline			// set 1st print arg
	add	x0, x0, :lo12:newline		// set 1st print arg
	bl	printf				// print newline
	ldr	w13, [x29, i_save]		// get value of i
	add	w13, w13, 1			// increment i
	and	w13, w13, MODMASK		// bitwise and with modmask
	str	w13, [x29, i_save]		// store i
	ldr	w14, [x29, j_save]		// get value of j
	add	w14, w14, 1			// increment j
	str	w14, [x29, j_save]		// store j

looptest:					// for loop test
	ldr	w12, [x29, count_save]		// get count value
	ldr	w14, [x29, j_save]		// get j value
	cmp	w14, w12			// if (j < count)
	b.lt	loop				// continue loop if <

donePrint:					// end of function
	ldp	x29, x30, [sp], deallocDisplay	// deallocate stack space
	ret					// return
