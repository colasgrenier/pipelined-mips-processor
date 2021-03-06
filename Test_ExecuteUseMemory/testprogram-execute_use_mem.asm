#Testing Execute depends on Memory

addi $3, $3, 1200

#Delay so no hazard
addi $2, $2, 400
addi $1, $1, 400

#Store r3 in memory address 12
sw $3, 12($0)

#Will make R2 hold 1200 and R3 hold 11300
addi $2, $2, 800
addi $3, $3, 10100

#Restore R3 to 1200 (this shouldn't be using addi results, or error will appear)
lw $3, 12($0)

#If no stall here, R3 used will be 11200 and it will not branch
beq $3, $2, end

addi $1, $1, 10000
addi $2, $2, 10000
addi $3, $3, 10000
addi $4, $4, 10000
addi $5, $5, 10000
addi $6, $6, 10000
addi $7, $7, 10000
addi $8, $8, 10000

end: beq $0, $0, end

#EXPECTED RESULT, R1 = 400, R2 = 1200, R3 = 1200, all other Rs are 0
