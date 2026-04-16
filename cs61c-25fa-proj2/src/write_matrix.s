.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================
write_matrix:
    addi sp sp -32
    sw ra 0(sp)
    sw s0 12(sp)
    sw s1 16(sp)
    sw s2 20(sp)
    sw s3 24(sp)

    # Prologue
    mv s0 a2 #row
    sw a2 4(sp)
    mv s1 a3 #col
    sw a3 8(sp)
    mv s2 a1 # pointer to the start of matrix

    li a1 1
    jal ra fopen
    li t0 -1
    beq t0 a0 fail1
    mv s3 a0 #file

    mv a0 s3
    addi a1 sp 4
    li a2 2
    li a3 4
    jal ra fwrite
    li t0 2
    blt a0 t0 fail2

    mv a0 s3
    mv a1 s2
    mul a2 s0 s1
    sw a2 28(sp)
    li a3 4
    jal ra fwrite
    lw t0 28(sp)
    blt a0 t0 fail2

    mv a0 s3
    jal ra fclose
    bne a0 zero fail3

    # Epilogue
    lw ra 0(sp)
    lw s0 12(sp)
    lw s1 16(sp)
    lw s2 20(sp)
    lw s3 24(sp)
    addi sp sp 32

    jr ra

fail1:
    li a0 27
    j exit

fail2:
    li a0 30
    j exit

fail3:
    li a0 28
    j exit