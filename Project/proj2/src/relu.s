.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
# 	a0 (int*) is the pointer to the array
#	a1 (int)  is the # of elements in the array
# Returns:
#	None
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 78.
# ==============================================================================
relu:
    # Prologue

  # check whether a1 is less than 1
  # if is exit with code 78
  blt zero, a1, loop_start
  li a1, 78
  jal exit2

loop_start:
  # if a1 decrement to zero, simply jump to loop_end
  beq a1, zero, loop_end
  lw t0, 0(a0)
  # if t0 >= 0, then simply increment a0 by 4, and decrement a1 by 1, jump back to loop_start
  # if t0 < 0, jump to loop_continue for futher processing
  bge t0, zero, loop_continue
  sw zero, 0(a0)

loop_continue:
  addi a0, a0, 4
  addi a1, a1, -1
  j loop_start

loop_end:


    # Epilogue

	ret
