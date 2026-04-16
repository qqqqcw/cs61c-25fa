.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
classify:
    li t0 5
    bne a0 t0 fail2

    addi sp sp -64
    sw ra 0(sp)
    sw s0 28(sp)
    sw s1 32(sp)
    sw s2 36(sp)
    sw s3 40(sp)
    sw s4 44(sp)
    sw s5 48(sp)
    sw s6 52(sp)
    sw s7 56(sp)
    sw s8 60(sp)

    mv s6 a0
    mv s7 a1
    mv s8 a2
    # Read pretrained m0
    lw a0 4(s7) 
    addi a1 sp 4 #4(sp) is pointer to row
    addi a2 sp 8 #8(sp) is pointer to col
    jal ra read_matrix
    mv s0 a0 #pointer to m0

    # Read pretrained m1
    lw a0 8(s7) 
    addi a1 sp 12 #12(sp) is pointer to row
    addi a2 sp 16 #16(sp) is pointer to col
    jal ra read_matrix
    mv s1 a0 #pointer to m1

    # Read input matrix
    lw a0 12(s7) 
    addi a1 sp 20 #20(sp) is pointer to row
    addi a2 sp 24 #24(sp) is pointer to col
    jal ra read_matrix
    mv s2 a0 #pointer to input

    # Compute h = matmul(m0, input)
    lw t0 4(sp) #row of m0
    lw t1 24(sp) #col of input
    mul a0 t0 t1
    slli a0 a0 2
    jal ra malloc
    beq a0 zero fail1
    mv s3 a0 #s3 is the pointer to h

    mv a0 s0
    lw a1 4(sp)
    lw a2 8(sp)
    mv a3 s2
    lw a4 20(sp)
    lw a5 24(sp)
    mv a6 s3
    jal ra matmul

    # Compute h = relu(h)
    mv a0 s3
    lw t0 4(sp) #row of m0
    lw t1 24(sp) #col of input
    mul a1 t0 t1
    jal ra relu

    # Compute o = matmul(m1, h)
    lw t0 12(sp) #row of m1
    lw t1 24(sp) #col of h(also input)
    mul a0 t0 t1
    slli a0 a0 2
    jal ra malloc
    beq a0 zero fail1
    mv s4 a0 #s4 is the pointer to o

    mv a0 s1
    lw a1 12(sp)
    lw a2 16(sp)
    mv a3 s3
    lw a4 4(sp)
    lw a5 24(sp)
    mv a6 s4
    jal ra matmul 

    # Write output matrix o
    lw a0 16(s7)
    mv a1 s4
    lw a2 12(sp)
    lw a3 24(sp)
    jal ra write_matrix

    # Compute and return argmax(o)
    mv a0 s4
    lw t0 12(sp) #row of m1
    lw t1 24(sp) #col of h(also input)
    mul a1 t0 t1
    jal ra argmax
    mv s5 a0 #the maxIndex of o
    
    

    # If enabled, print argmax(o) and newline
    bne s8 zero end
    mv a0 s5
    jal ra print_int
    li a0 '\n'
    jal ra print_char

end:
    mv a0 s0
    jal ra free
    mv a0 s1
    jal ra free
    mv a0 s2
    jal ra free
    mv a0 s3
    jal ra free
    mv a0 s4
    jal ra free
    
    mv a0 s5

    lw ra 0(sp)
    lw s0 28(sp)
    lw s1 32(sp)
    lw s2 36(sp)
    lw s3 40(sp)
    lw s4 44(sp)
    lw s5 48(sp)
    lw s6 52(sp)
    lw s7 56(sp)
    lw s8 60(sp)
    addi sp sp 64

    jr ra

fail1:
    li a0 26
    j exit

fail2:
    li a0 31
    j exit