#testing store load
addi $1, $0, 4
addi $2, $0, 2


sw $1, 0($3)
addi $3, $3, 1 #next
div $1, $2
mflo $1

sw $1, 0($3)
addi $3, $3, 1 #next
addi $1, $1, 6

sw $1, 0($3)
addi $3, $3, 1 #next

lw $5, 0($3)
addi $3, $3, 1 #next
addi $5, $0, 1






