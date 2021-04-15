
#may need to implement or add some stalls


#set values to registers for testing
addi $1, $0, 1 
addi $2, $0, 2
addi $3, $0, 5
addi $4, $0, 7



#testing for logical
and $5, $2, $1 #bitwise and, R5= $2 & $1

add $0, $0, $0
add $0, $0, $0

or $6, $3, $4 #bitwise or, R6= $3 OR $4

add $0, $0, $0
add $0, $0, $0
		
nor $7, $3, $4 #bitwise nor, R7= $3 OR $4 (then flip bits)

add $0, $0, $0
add $0, $0, $0
		
xor $8, $3, $4 #bitwise xor, R8 = $3 XOR $4


add $0, $0, $0
add $0, $0, $0
		
andi $9, $3, 10 #bitwise and, R9= $3 & 10 immediate val

add $0, $0, $0
add $0, $0, $0
		
ori $10, $3, 10 #bitwise or, R5= $3 OR 10 immediate val

add $0, $0, $0
add $0, $0, $0
		
xori $11, $3, 10 #bitwise xor, R5= $3 XOR 10






































