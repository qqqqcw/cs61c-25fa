.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
    # Prologue
    li t0 1
    bge a1 t0 loop_start
    li a0 36
    j exit

loop_start:
    lw t0 0(a0)
    li t2 0 # 最大值下标
    li t3 0 # 当前下标
    j loop_end

loop_continue:
    lw t1 0(a0)
    bge t0 t1 loop_end
    mv t0 t1 
    mv t2 t3



loop_end:
    addi t3 t3 1
    addi a0 a0 4
    addi a1 a1 -1
    bne a1 zero loop_continue
    # Epilogue
    mv a0 t2

    jr ra
