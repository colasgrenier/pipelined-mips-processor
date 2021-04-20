#Testing forwarding for execute using execute result and memory result together

addi $1, $1, 8
addi $10, $10, 16
#R1=8,R10=16

#Both ex and mem results are needed in ex
addi $2, $2, 8
addi $3, $3, 12
add $3, $2, $3
#R1=8,R2=8,R3=20,R10=16

#Same deal but other way
addi $2, $2, 4
addi $3, $3, 8
add $3, $3, $2
#R1=8,R2=12,R3=40,R10=16

#And trying immediate instruction forwarding to ex

#Same deal (ex use ex) with immediate
sub $3, $3, $2
ori $12, $3, 37
#R1=8,R2=12,R3=28,R10=16,R12=61

#And using mem (ex use mem)
addi $3, $3, 12
addi $15, $10, -16
xori $15, $3, 63
#R1=8,R2=12,R3=40,R10=16,R12=61,R15=23


sw $1, 4($4) #M[4] = 8
sw $10, 8($16) #M[8] = 16

#Forward to memory

lw $2, 4($0)
add $5, $3, $0
#The memory stage will need to use values currently in memory_result ($5) and writeback ($2)
sw $5, 4($2) #M[12]=40
#R1=8,R2=8,R3=40,R5=40,R10=16,R12=61,R15=23

#Mem needs ex and mem results, but it actually needs mem (lw) in its ex (4R5), there should be a stall
sub $2, $3, $2 
lw $5, -24($2)
sw $2, 4($5) #M[20]=32
#R1=8,R2=32,R3=40,R5=16,R10=16,R12=61,R15=23

#Finally stall case, execute needs memory result
lw $1, 0($1)
lw $2, -12($10)
add $16, $1, $2
#R1=16,R2=8,R3=40,R5=16,R10=16,R12=61,R15=23,R16=24

end: beq $0, $0, end

#EXPECTED RESULTS: 
#R1 = 16, R2 = 8, R3 = 40, R5 = 16, R10 = 16, R12 = 61, R15 = 23, R16 = 24 (All other registers are 0)

#M[4] = 8, M[8] = 16, M[12] = 40, M[20] = 32
#or in words...
#M[1] = 8, M[2] = 16, M[3] = 40, M[5] = 32
