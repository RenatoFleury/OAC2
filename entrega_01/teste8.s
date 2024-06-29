sort:   
	addi sp, sp, -20        # make room on stack for 5 registers
        sw ra, 16(sp)           # save return address on stack
        sw s6, 12(sp)          # save s6 on stack
        sw s5, 8(sp)           # save s5 on stack
        sw s4, 4(sp)           # save s4 on stack
        sw s3, 0(sp)           # save s3 on stack
        addi s5, a0, 0        # copy parameter a0 into s5
	addi s6, a1, 0        # copy parameter a1 into s6
        addi s3, zero, 0         # i = 0
for1tst:
        blt s6, s3, exit1 	   
        beq s6, s3, exit1     # Salta se s6 = s3
	beq s3,zero, for2tst
        addi s4, s3, -1       # j = i - 1
for2tst:
	blt s4, zero, exit2      
        slli t0, s4, 2         # t0 = j * 4
        add t0, s5, t0         # t0 = v + j * 4
        lw t1, 0(t0)            # t1 = v[j]
        lw t2, 4(t0)            # t2 = v[j + 1]
        blt t1, t2, exit2       
        beq t1, t2, exit2       # Salta se t1 = t2
        addi a0,s5,0          # first swap parameter is v
        addi a1,s4,0          # second swap parameter is j
        jal ra, swap            # call swap
        addi s4, s4, -1       # j -= 1
        jal zero, for2tst         # go to for2tst
exit1:     
        lw s3, 0(sp)           # restore s3 from stack
        lw s4, 4(sp)           # restore s4 from stack
        lw s5, 8(sp)           # restore s5 from stack
        lw s6, 12(sp)          # restore s6 from stack
        lw ra, 16(sp)          # restore return address from stack
        addi sp, sp, 20        # restore stack pointer
        jalr zero, 0(ra)       # returns to main
exit2:  
        addi s3, s3, 1        # i += 1
        jal zero, for1tst         # go to for1tst
swap:
        slli t1, a1, 2         # t1 = k * 4
        add t1, a0, t1         # t1 = v + k * 4
        lw t0, 0(t1)            # t0 (temp) = v[k]
        lw t2, 4(t1)            # t2 = v[k+1]
        sw t2, 0(t1)            # v[k] = t2
        sw t0, 4(t1)            # v[k+1] = t0
        jalr zero, 0(ra)          # return to calling routine

.rodata
.uploader:
	.word 0x50
	.word 0x37
	.word 0x35
	.word 0x39
	.word 0x40
	.word 0x10
	.word 0x5
	.word 0x1a
	.word 0x4d
	.word 0x17
	.word 0x4b
	.word 0x2f
	.word 0xd
	.word 0x36
	.word 0x43
	.word 0x4
	.word 0x20
	.word 0x15
	.word 0x41
	.word 0x7
	.word 0xb
	.word 0x32
	.word 0x49
	.word 0x16
	.word 0x45
	.word 0x9
	.word 0x25
	.word 0x29
	.word 0x2
	.word 0x44
	.word 0x1c
	.word 0x26
	.word 0x6
	.word 0x21
	.word 0x3c
	.word 0x38
	.word 0x27
	.word 0x3d
	.word 0x1d
	.word 0x1e
	.word 0x28
	.word 0x4f
	.word 0x22
	.word 0x2b
	.word 0x13
	.word 0x34
	.word 0x11
	.word 0x47
	.word 0x33
	.word 0x23
	.word 0x1b
	.word 0x1f
	.word 0x4c
	.word 0x18
	.word 0x2c
	.word 0x30
	.word 0x12
	.word 0xf
	.word 0x2e
	.word 0x1
	.word 0x31
	.word 0x3
	.word 0x2a
	.word 0x46
	.word 0x8
	.word 0x3b
	.word 0x14
	.word 0x2d
	.word 0xe
	.word 0xc
	.word 0x24
	.word 0x48
	.word 0x42
	.word 0x4a
	.word 0x4e
	.word 0x3a
	.word 0x19
	.word 0x3f
	.word 0xa
	.word 0x3e
	.word 0x0

	.text
	.align 2
	.globl	main
	.type	main, @function
main:      
	addi a0, zero, %lo(.uploader)
	lw a1, 0(a0)
	addi a0, a0, 4         
	jal ra, sort
	.size	main, .-main