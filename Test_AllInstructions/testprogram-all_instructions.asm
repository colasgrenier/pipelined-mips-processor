#Testing forwarding for execute using execute result and memory result together

	#Just to start us off, do addi
	addi $1, $1, 8
	addi $2, $2, 16
	addi $6, $6, 12
	addi $16, $16, 159
	

	#Arithmetic 
	add $1, $1, $2
	sw $1, 0($0)
	sub $2, $1, $2
	sw $2, 4($0)
	#R1=24, R2=8

	#need mult to get a 64 bit result (a 1 somewhere past bit 31)
LabelA: lui $5, 8193
	sw $5, 8($0)
	mult $1, $5
	mfhi $3
	sw $3, 12($0)
	mflo $1
	sw $1, 16($0)
	#R1=1572864, R3=3, R5=536936448

	addi $2, $2, 9876
	div $1, $2
	mflo $1
	sw $1, 20($0)
	mfhi $4
	sw $4, 24($0)
	#R1=159, R2=9884, R4=1308

	beq $4, $2, LabelA #Shouldn't work, if they do we'll get funky mult and div outputs because 1 is bigger
	bne $16, $1, LabelA
	slt $5, $1, $4
	sw $5, 28($0)
	sw $16, 32($0) #so we know slti is doing something
	slti $6, $2, 2637
	sw $6, 32($0)
	#R5=1, R6=0


	#Time for logical operators (if I messed this up I will be very mad)
	ori $7, $1, 63
	sw $7, 36($0)
	or $8, $7, $2
	sw $8, 40($0)
	andi $8, $8, 717
	sw $8, 44($0)
	and $9, $8, $7
	sw $9, 48($0)
	addi $5, $5, 2
	nor $9, $9, $5
	sw $9, 52($0)
	xori $9, $8, 79
	sw $9, 56($0)
	xor $10, $8, $7
	sw $10, 60($0)
	#R5=3,R7=191,R8=653,R9=63,R10=562

	sll $5, $5, 3
	sw $5, 64($0)
	lui $11, 36223
	sra $11, $11, 5
	srl $11, $11, 10
	sw $11, 68($0)
	#R5=24,R11=4135678

	#Memory operations
	lw $12, -4($5)
	sw $12, 72($0)

	addi $12, $12, -135

	#And finally, jumps
	#All four (five with subroutinebranches will work
	beq $5, $12, LoopB
	addi $14, $14, 384
LoopB:  bne $14, $5, LoopC
	addi $14, $14, 96
LoopC:  j LoopD
	addi $14, $14, 24
LoopD:  jal Subroutine
	addi $14, $14, 7
	sw $14, 76($0)
	sw $15, 80($0)
	#R14=7,R15=7583

end: beq $0, $0, end

Subroutine: addi $15, $15, 7583
	add $15, $14, $15
	jr $31

#EXPECTED RESULTS: 
#Mem[0]=24,Mem[4]=8,Mem[8]=0b100000000000010000000000000000,Mem[12]=3,Mem[16]=0b00000000000110000000000000000000,Mem[20]=159,
#Mem[24]=1308,Mem[28]=1,Mem[32]=0,Mem[36]=0b10111111,Mem[40]=0b10011010111111,M[44]=0b1010001101,Mem[48]=0b10001101,
#Mem[52]=0b...11101110000,Mem[56]=0b1011000010,Mem[60]=0b1000110010,Mem[64]=24,Mem[68]=0b1111110001101011111110,
#Mem[72]=159,Mem[76]=0,Mem[80]=7583
#or in words...
#Mem[0]=24,Mem[1]=8,Mem[2]=0b100000000000010000000000000000,Mem[3]=3,Mem[4]=0b00000000000110000000000000000000,Mem[5]=159,
#Mem[6]=1308,Mem[7]=1,Mem[8]=0,Mem[9]=0b10111111,Mem[10]=0b10011010111111,M[11]=0b1010001101,Mem[12]=0b10001101,
#Mem[13]=0b...11101110000,Mem[14]=0b1011000010,Mem[15]=0b1000110010,Mem[16]=24,Mem[17]=0b1111110001101011111110,
#Mem[18]=159,Mem[19]=0,Mem[20]=7583

