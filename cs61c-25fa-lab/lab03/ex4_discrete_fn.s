.globl f # this allows other files to find the function f

# f takes in two arguments:
# a0 is the value we want to evaluate f at
# a1 is the address of the "output" array (read the lab spec for more information).
# The return value should be stored in a0
f:
    # Your code here
    addi a2 a0 3
    slli a2 a2 2
    add a2 a2 a1
    lw a0 0(a2)
    # This is how you return from a function. You'll learn more about this later.
    # This should be the last line in your program.
    jr ra
