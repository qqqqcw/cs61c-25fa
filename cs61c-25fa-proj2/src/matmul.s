.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:

    # Error checks
    li t0 1
    blt a1 t0 fail
    blt a2 t0 fail
    blt a4 t0 fail
    blt a5 t0 fail
    bne a2 a4 fail

    # Prologue
    mv t0 a6
    li t1 0 # i = 0
    
#for(int i = 0; i < m0.rows; i++) {
#    for(int j = 0; j < m1.cols; j++) {
#        t[i][j] = dot();
#    }
#}

outer_loop_start:
    li t2 0 # j = 0
    mv t3 a3

inner_loop_start:
    addi sp sp -44
    sw ra 0(sp)
    sw a0 4(sp)
    sw a1 8(sp)
    sw a2 12(sp)
    sw a3 16(sp)
    sw a4 20(sp)
    sw a5 24(sp)
    sw t0 28(sp)
    sw t1 32(sp)
    sw t2 36(sp)
    sw t3 40(sp)

    lw a0 4(sp)
    lw a1 40(sp)
    lw a2 12(sp)
    li a3 1 # step_m0 = 1
    lw a4 24(sp) # step_m1 = m1.col

    jal ra dot
    
    lw t0 28(sp)
    lw t1 32(sp)
    lw t2 36(sp)
    lw t3 40(sp)
    
    sw a0 0(t0)

inner_loop_end:
    addi t0 t0 4
    addi t2 t2 1 # j++
    addi t3 t3 4

    lw ra 0(sp)
    lw a0 4(sp)
    lw a1 8(sp)
    lw a2 12(sp)
    lw a3 16(sp)
    lw a4 20(sp)
    lw a5 24(sp)

    addi sp sp 44

    bne t2 a5 inner_loop_start

outer_loop_end:
    addi t1 t1 1 # i++
    slli t4 a2 2
    add a0 a0 t4
    blt t1 a1 outer_loop_start

    # Epilogue

    jr ra

fail:
    li a0 38
    j exit
