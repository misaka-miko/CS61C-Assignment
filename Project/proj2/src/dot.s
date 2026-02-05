.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int vectors
# Arguments:
#   a0 (int*) is the pointer to the start of v0
#   a1 (int*) is the pointer to the start of v1
#   a2 (int)  is the length of the vectors
#   a3 (int)  is the stride of v0
#   a4 (int)  is the stride of v1
# Returns:
#   a0 (int)  is the dot product of v0 and v1
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 75.
# - If the stride of either vector is less than 1,
#   this function terminates the program with error code 76.
# =======================================================
dot:

    # Prologue
length_check:
    blt zero, a2, stride_check_one
    li a1, 75
    jal exit2

stride_check_one:
    blt zero, a3, stride_check_two
    li a1, 76
    jal exit2

stride_check_two:
    blt zero, a4, pre_assign
    li a1, 76
    jal exit2

pre_assign:
    # let t2 to hold the result of the dot production
    mv t2, zero

loop_start:
    # if a2 == 0, jump out the loop
    beq a2, zero, loop_end

    # load the element to be multiplied into t0 and t1
    lw t0, 0(a0) # multiplier of a0
    lw t1, 0(a1) # multiplier of a1

    mul t0, t0, t1 # reuse t0 to hold the result of the multiplication
    add t2, t2, t0 # update the sum

    # update the pointer
    slli t0, a3, 2 # t1 holds the step for a0
    slli t1, a4, 2 # t2 holds the step for a1
    add a0, a0, t0
    add a1, a1, t1

    addi a2, a2, -1
    j loop_start # begin next loop

loop_end:
    mv a0, t2
    ret
