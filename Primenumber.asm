li $1, 10 
li $2, 0 

addi $3, $0, 1
addi $4, $0, 2

loop:
beq $1,$2,end 
#do something

addi$2,$1,2 #add1tot1
j loop # jump back to the top 
end:
