#Testing memory results using for memory

#Avoid forwarding
addi $1, $1, 4
addi $2, $2, 800
xori $8, $8, 0

#Store 4 in address 12
sw $1, 8($1)

#Avoid forwarding
addi $3, $3, 1200
addi $4, $4, 1500

#Here is the main dependency. We are storing the result of load word
lw $5, 12($0)
sw $5, 12($1)

#To be honest this is an execute use memory in disguise
lw $6, 12($0)
sw $2, 16($6)

#This is the above scenario, (execute use memory) but with no stall needed, and (memory use memory) when result is ready before mem
lw $7, 12($0)
ori $8, $8, 200
sw $8, 20($7)

end: beq $0, $0, end

#EXPECTED RESULT: Mem[12]=4,Mem[16]=4,M[20]=800,M[24]=200
