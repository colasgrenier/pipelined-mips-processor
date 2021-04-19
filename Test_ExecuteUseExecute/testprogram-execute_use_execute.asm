#Testing forwarding for execute using execute result

#I'm just having some fun here, give a nice setup time for r2
addi $2, $2, 400
addi $1, $1, 87
addi $6, $6, 278

addi $3, $3, 600
add $3, $2, $3

end: beq $0, $0, end

#EXPECTED RESULTS: R1 = 87, R2 = 400, R3 = 1000, R6 = 278, all other registers are 0
