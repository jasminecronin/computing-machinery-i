// This program gets two integers as user input from the command line,
// checks if they represent a date, then prints the date and the season
// that date falls in.
// Jasmine Roebuck, 30037334, Computing Machinery I, Nov. 30, 2018

	.text						// open .text section
fmt:	.string "%s %d%s is %s\n"			// final print string

jan_m:	.string "January"				// string array of month names
feb_m:	.string "February"
mar_m:	.string "March"
apr_m:	.string "April"
may_m:	.string "May"
jun_m:	.string "June"
jul_m:	.string "July"
aug_m:	.string "August"
sep_m:	.string "September"
oct_m:	.string "October"
nov_m:	.string "November"
dec_m:	.string "December"

spr_m:	.string "Spring"				// string array of season names
sum_m:	.string "Summer"
fal_m:	.string "Fall"
win_m:	.string "Winter"

st_m:	.string "st"					// string array of ordinal suffixed
nd_m:	.string "nd"
rd_m:	.string "rd"
th_m:	.string "th"

argError: .string "Error: Too few arguments.\n"			// < 2 user arguments error string
numError: .string "Error: Input not valid for date format.\n"	// invalid numbers error string

define(argc_r, w19)					// arg count register
define(argv_r, x20)					// arg array address register
define(month_r, w21)					// month register
define(day_r, w22)					// day register
define(date_r, w23)					// day of year register
define(season_r, w24)					// season register


	.data						// open .data section
	.balign 8					// doubleword align instructions
month_m: .dword jan_m, feb_m, mar_m, apr_m, may_m, jun_m, jul_m, aug_m, sep_m, oct_m, nov_m, dec_m	// month name array
season_m: .dword spr_m, sum_m, fal_m, win_m		// season name array
suffix_m: .dword st_m, nd_m, rd_m, th_m, th_m, th_m, th_m, th_m, th_m, th_m, th_m, th_m, th_m, th_m, th_m, th_m, th_m, th_m, th_m, th_m, st_m, nd_m, rd_m, th_m, th_m, th_m, th_m, th_m, th_m, th_m, st_m	// ordinal suffix array


	.text						// open .text section
	.balign 4					// word align instructions
	.global main					// make main visible to OS
main:	stp	x29, x30, [sp, -16]!			// allocate stack space
	mov	x29, sp					// set fp
	
	mov	argv_r, x1				// save the address of the input array
	mov	argc_r, w0				// save the number of arguments
	cmp	argc_r, 3				// test if we have enough arguments
	b.ge	next					// skip to next if >= 3
	adrp	x0, argError				// set 1st print arg
	add	x0, x0, :lo12:argError			// set 1st print arg
	bl	printf					// print argument error string
	b	done					// skip to end

next:	mov	w23, 1					// get value 1
	mov	w24, 2					// get value 2
	ldr	x0, [argv_r, w23, SXTW 3]		// get arg at index 1
	bl	atoi					// convert to int
	mov	month_r, w0				// store as month number
	ldr	x0, [argv_r, w24, SXTW 3]		// get arg at index 2
	bl	atoi					// convert to int
	mov	day_r, w0 				// store as day number

	cmp	month_r, 1				// check if month >= 1
	b.lt	error					// exit if not
	cmp	month_r, 12				// check if month <= 12
	b.gt	error					// exit if not
	cmp	day_r, 1				// check if day >= 1
	b.lt	error					// exit if not
	cmp	day_r, 31				// check if day <= 31
	b.gt	error					// exit if not
	b	pass					// numbers in correct range, skip error print

error:	adrp	x0, numError				// set 1st print arg
	add	x0, x0, :lo12:numError			// set 1st print arg
	bl	printf					// print number error string
	b	done					// skip to end

pass:	sub	date_r, month_r, 1			// day of year = month - 1
	mov	w24, 30					// get value 30 (days in a month)
	madd	date_r, date_r, w24, day_r		// day of year = (month - 1) * 30 + day

	adrp	x0, fmt					// set 1st print arg
	add	x0, x0, :lo12:fmt			// set 1st print arg
	sub	w25, month_r, 1				// month index = month - 1
	adrp	x26, month_m				// get month array address
	add	x26, x26, :lo12:month_m			// get month array address
	ldr	x1, [x26, w25, SXTW 3]			// get month argument
	mov	w2, day_r				// get day print argument
	sub	w25, day_r, 1				// day index = day - 1
	adrp	x26, suffix_m				// get suffix array address
	add	x26, x26, :lo12:suffix_m		// get suffix array address
	ldr	x3, [x26, w25, SXTW 3]			// get suffix print argument
	
	cmp	date_r, 80				// if day of year <= 80
	b.le	winter					// season is winter
	cmp	date_r, 170				// if day of year <= 170
	b.le	spring					// season is spring
	cmp	date_r, 260				// if day of year <= 260
	b.le	summer					// season is summer
	cmp	date_r, 350				// if day of year <= 350
	b.le	fall					// season is fall
	b	winter					// if day of year > 350, season is winter
				
winter:	mov	season_r, 3				// get winter index for season array
	b	print					// skip to print
spring:	mov	season_r, 0				// get spring index for season array
	b	print					// skip to print
summer:	mov	season_r, 1				// get summer index for season array
	b	print					// skip to print
fall:	mov	season_r, 2				// get fall index for season array
	b	print					// skip to print

print:	adrp	x26, season_m				// get address of season array
	add	x26, x26, :lo12:season_m		// get address of season array
	ldr	x4, [x26, season_r, SXTW 3]		// get season print arg
	bl	printf					// final print statement

done:	mov	w0, 0					// restore register
	ldp	x29, x30, [sp], 16			// deallocate stack space
	ret						// return

