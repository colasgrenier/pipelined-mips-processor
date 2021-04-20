#Testing forwarding for execute using execute result and memory result together

addi $1, $1, 8
addi $2, $2, 16
addi $6, $6, 12
addi $16, $16, 159
#Just to start us off, do addi

#Arithmetic 

add $1, $1, $2
sub $2, $1, $2
#R1=24, R2=8

#need mult to get a 64 bit result (a 1 somewhere past bit 31)
LabelA: lui $5, 8193
mult $1, $5
mfhi $3
mflo $1
#R1=1572864, R3=3, R5=536936448

addi $2, $2, 9876
div $1, $2
mflo $1
mfhi $4
#R1=159, R2=9884, R4=1308

beq $4, $2, LabelA #Shouldn't work
bne $16, $1, LabelA
slt $5, $1, $4
slti $6, $2, 2037
#R5=1, R6=0


#Time for logical operators (if I messed this up I will be very mad)
ori $7, $1, 63
or $8, $7, $2
andi $8, $8, 717
and $9, $8, $7
addi $5, $5, 2
nor $9, $9, $5
xori $9, $9, 79
xor $10, $8, $7
#R5=3,R7=191,R8=653,R9=63,R10=562

sll $5, $5, 3
lui $11, 36223
sra $11, $11, 5
srl $11, $11, 10
#R5=24,R11=4135678

#Memory operations
sw $11, -8($5)
lw $12, -47($9)
#M[16]=4135678,R12=4135678

#And finally, jumps
#First two branches will work
beq $11, $12, LoopB
addi $14, $14, 384
LoopB: bne $14, $5, LoopC
addi $14, $14, 96
LoopC: j LoopD
addi $14, $14, 24
LoopD: jal Subroutine
addi $14, $14, 7
#R14=7,R15=7583

end: beq $0, $0, end

Subroutine: addi $15, $15, 7583
add $15, $14, $15
jr $31


#EXPECTED RESULTS: 
#R1 = 159, R2 = 9884, R3 = 3, R4 = 1308, R5 = 24, R6 = 0, R7 = 191, R8 = 653, R9 = 63, R10 = 562
#R11 = 4135678, R12 = 4135678, R13 = 0, R14 = 7, R15 = 7583, R16 = 159, R31 = SOMETHING (it's a PC address, will check itself) 
#(All other registers are 0)

#M[16] = 4135678
#or in words...
#M[4] = 4135678
