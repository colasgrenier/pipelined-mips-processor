addi $2, $0, 270    #A
addi $3, $0, 192    #B

loop:   beq $2, $0, ENDA
		addi $0, $0, 0
        beq $3, $0, ENDB
        div $2, $3
        add $2, $0, $3
        mfhi $3
        j loop

ENDA:    add $5, $0, $3
ENDB:    add $6, $0, $2