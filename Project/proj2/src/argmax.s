.globl argmax

.text
# =================================================================
# FUNCTION: Given a int vector, return the index of the largest
#	element. If there are multiple, return the one
#	with the smallest index.
# Arguments:
# 	a0 (int*) is the pointer to the start of the vector
#	a1 (int)  is the # of elements in the vector
# Returns:
#	a0 (int)  is the first index of the largest element
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 77.
# =================================================================
argmax:

  # Prologue

  blt zero, a1, pre_assign
  li a1, 77
  jal exit2

pre_assign:
  mv t0, a0
  lw t1, 0(a0)
  mv t2, a0

  addi a0, a0, 4
  addi a1, a1, -1

loop_start:

  # if a1 decrements to 0 then break out loop
  beq a1, zero, loop_end
  lw t3, 0(a0)
  # if the current loaded element is less or equal than max_element, then do nothing, jump to loop_continue
  bge t1, t3, loop_continue
 # Update the maximum element
  mv t1, t3
 # Update the maximum element index
  mv t2, a0

loop_continue:
  addi a0, a0, 4
  addi a1, a1, -1

  j loop_start

loop_end:
  sub a0, t2, t0
  srli a0, a0, 2
  ret
