#Testing memory results using for memory

ori $1, $1, 16
addi $2, $2, 800
#Interesting case, memory needs writeback and execute needs memory in the same instruction
sw $1, -4($1)

end: beq $0, $0, end

#EXPECTED RESULT: Mem[12]=16, R1=16, R2=800
