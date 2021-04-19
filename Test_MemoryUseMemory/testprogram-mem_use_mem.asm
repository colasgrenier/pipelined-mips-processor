#Testing memory results using for memory

addi $1, $1, 4
addi $2, $2, 800
#Store 500 in address 10
sw $1, 8($0)
addi $3, $3, 1200
addi $4, $4, 1500
#Here is the dependency. We are storing the result of load word
lw $5, 8($0)
sw $5, 16($0)

#Here's another, We are storing into an address given by 6. To be honest this is an execute use memory in disguise
lw $6, 8($0)
sw $2, 8($6)
end: beq $0, $0, end

#EXPECTED RESULT: Mem address 8 holds 4, Mem address 16 holds 4, Mem address 12 holds 800
