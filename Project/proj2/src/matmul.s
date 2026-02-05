.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
# 	d = matmul(m0, m1)
# Arguments:
# 	a0 (int*)  is the pointer to the start of m0 
#	a1 (int)   is the # of rows (height) of m0
#	a2 (int)   is the # of columns (width) of m0
#	a3 (int*)  is the pointer to the start of m1
# 	a4 (int)   is the # of rows (height) of m1
#	a5 (int)   is the # of columns (width) of m1
#	a6 (int*)  is the pointer to the the start of d
# Returns:
#	None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 72.
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 73.
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 74.
# =======================================================
matmul:

  # Error checks
  bge zero, a1, error_72
  bge zero, a2, error_72

  bge zero, a4, error_73
  bge zero, a5, error_73

  bne a2, a4, error_74
  j check_done

error_72:
  li a1, 72
  jal exit2

error_73:
  li a1, 73
  jal exit2

error_74:
  li a1, 74
  jal exit2

check_done:

  # Prologue
  addi sp, sp, -48
  sw ra, 0(sp) # return address
  sw s0, 4(sp) # address of m0
  sw s1, 8(sp) # address of m1
  sw s2, 12(sp) # address of d
  sw s3, 16(sp) # row number of m0
  sw s4, 20(sp) # col number of m0 / row number of m1
  sw s5, 24(sp) # col number of m1
  sw s6, 28(sp) # row index of current loop
  sw s7, 32(sp) # col index of current loop
  sw s8, 36(sp)

  mv s0, a0 # copy the address of m0
  mv s1, a3 # copy the address of m1
  mv s2, a6 # copy the address of d
  mv s3, a1 # assign s3 with row number of m0 
  mv s4, a2 # assign s4 with col number of m0 / row number of m1
  mv s5, a5 # assign s3 with col number of m1 
  mv s6, zero # initialize the row index


outer_loop_start:
  beq s6, s3, outer_loop_end # when row index == row number of m0, finish

  mv s7, zero # initialize the col index before going into the inner loop
  mul s8, s6, s4
  slli s8, s8, 2
inner_loop_start:
  beq s7, s5, inner_loop_end # when col index == col number of m1, finish inner loop
  add a0, s8, s0
  mv a1, s1
  mv a2, s4 # the length of the row vector in m0 is s4
  li a3, 1 # the stride of the row vector
  mv a4, s5 # each time we should cross through whole row

  slli t0, s7, 2 # computing the offset of m1
  add a1, a1, t0
  jal dot

  mv t0, s6
  mul t0, t0, s5
  add t0, t0, s7
  slli t0, t0, 2
  add t0, t0, s2
  sw a0, 0(t0)

  addi s7, s7, 1
  j inner_loop_start

inner_loop_end:

  addi s6, s6, 1 # increment the row index to calculate the next line of matrix
  j outer_loop_start

outer_loop_end:


    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    lw s7, 32(sp)
    lw s8, 36(sp)
    addi sp, sp, 48

    ret
