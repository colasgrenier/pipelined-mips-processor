#write i type
#may need to implement or add some stalls


#set values to registers for testing
addi $1, $0, 1 
addi $2, $0, 2
addi $3, $0, 5
addi $4, $0, 7

#testing for arithmetic
add $5, $1, $3 #R5 = 6

sub $6, $4, $2 #R6 = 5

#multiplcation
mult $2, $3
add $0, $0, $0 #stall for _ amount
mflo $7 #R7 = the number assuming small
#mfhi $8 #would b 0s 

#division
div $4, $2
add $0, $0, $0 #stall for _ amount
mflo $8 #R8 = 3
mfhi $9 #R9 = 1

#set less than
slt $10, $4, $3 #R10 = 0 because not less than

slt $11, $1, $5 #R11 = 1 because less than

add $0, $0, $0 #stall for _ amount

slti $12, $4, 6 #R12 = 0 because not less than

slti $13, $4, 10 #R13 = 1 because less than





















