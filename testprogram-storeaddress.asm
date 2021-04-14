# Write a series of numbers to all points in memory.

	ORI   $2, $2, 32763
LOOP:	SW    $1, 0($1)	# store a word in the address at the address pointed to by R1 (initially 0)
	ADDI  $1, $1, 4	# increment R1 by 4
	BEQ   $1, $2, END
	J     LOOP
END:	J     LOOP
