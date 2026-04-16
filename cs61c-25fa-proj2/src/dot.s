.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the number of elements to use is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:

    # Prologue
    li t1 1
    blt a2 t1 fali1
    blt a3 t1 fali2
    blt a4 t1 fali2

    li t1 0 # sum
    slli t2 a3 2
    slli t3 a4 2
    li t5 0 # num

loop_start:
    beq a2 t5 loop_end
    lw a5 0(a0)
    lw a6 0(a1)
    mul t4 a5 a6
    add t1 t1 t4

    add a0 a0 t2
    add a1 a1 t3

    addi t5 t5 1
    j loop_start


loop_end:
    mv a0 t1

    # Epilogue
    jr ra

fali1:
    li a0 36
    j exit

fali2:
    li a0 37
    j exit
    