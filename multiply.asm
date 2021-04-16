#preschool multiply
#R1 added to itself R2 amount 
#n= 5, m= 3, n+n+n (3times)
#set values to registers testing

addi $1, $0, 5 #R1 = n
addi $2, $0, 3 #R2 = m

addi $3, $0, 0 #storing value for adding for temp 
addi $4, $0, 0 #condition to end
addi $5, $0, 1 #subtracting counter

loop: 	beq $2, $4, END #when R2 = 0 done adding
		add $3, $1, $1 #add n to itself and into R3
		sub $2, $2, $5 #decrement amount of times (R2)
		j loop


END: addi $1, $3, 0 #store value back to R1
