.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================
read_matrix:

    # Prologue
    addi sp sp -32
    sw ra 0(sp)
    sw s0 4(sp)
    sw s1 8(sp)
    sw s2 12(sp)
    sw s3 16(sp)
    sw s4 20(sp)
    sw s5 24(sp)

    mv s4 a1 #save a1,a2 to fread
    mv s5 a2
    
    li a1 0
    jal ra fopen
    li t0 -1
    beq a0 t0 fail2
    mv s0 a0 #flie

    mv a0 s0
    mv a1 s4
    li a2 4
    jal ra fread 
    li t0 4
    bne a0 t0 fail4

    mv a0 s0
    mv a1 s5
    li a2 4
    jal ra fread
    li t0 4
    bne a0 t0 fail4

    lw s1 0(s4)
    lw s2 0(s5) 
    mul t2 s1 s2
    slli t2 t2 2
    sw t2 28(sp) 
    
    mv a0 t2
    jal ra malloc
    beq a0 zero fail1
    mv s3 a0 

    mv a1 a0
    mv a0 s0
    lw a2 28(sp)
    jal ra fread
    lw t1 28(sp)
    bne a0 t1 fail4

    mv a0 s0
    jal ra fclose
    li t0 -1
    beq a0 t0 fail3


    # Epilogue
    
    mv a0 s3
    lw ra 0(sp)
    lw s0 4(sp)
    lw s1 8(sp)
    lw s2 12(sp)
    lw s3 16(sp)
    lw s4 20(sp)
    lw s5 24(sp)
    addi sp sp 32

    jr ra

fail1:
    li a0 26
    j exit

fail2:
    li a0 27
    j exit
 
fail3:
    li a0 28
    j exit

fail4:
    li a0 29
    j exit