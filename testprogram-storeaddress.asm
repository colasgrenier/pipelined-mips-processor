# Write a series of numbers to all points in memory.
        ori   $2, $2, 32763
loop:   sw    $1, 0($1) # store a word in the address at the address pointed to by R1 (initially 0)
        addi  $1, $1, 4 # increment R1 by 4
        beq   $1, $2, END
        j     loop
end:    j     end
