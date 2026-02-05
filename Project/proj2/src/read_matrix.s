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
# - If malloc returns an error,
#   this function terminates the program with error code 88.
# - If you receive an fopen error or eof, 
#   this function terminates the program with error code 90.
# - If you receive an fread error or eof,
#   this function terminates the program with error code 91.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 92.
# ==============================================================================
read_matrix:

    # Prologue
    addi sp, sp, -24
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)

    j entry

error_88:
  li a1 88
  jal exit2

error_90:
  li a1 90
  jal exit2

error_91:
  li a1 91
  jal exit2

error_92:
  li a1 92
  jal exit2

entry:
  mv s1, a1 # use s1 to hold a1: row pointer
  mv s2, a2 # use s2 to hold a2: col pointer

  mv a1, a0 # pass the filename
  li a2 0 # enable read permission
  jal fopen
  li t0 -1
  beq a0, t0, error_90 # if failed to fopen, exit with code 90

  mv s0, a0 # use s0 to store the file descriptor

  mv a1, s0
  mv a2, s1
  li a3 4
  jal fread
  li t0 4
  bne a0, t0, error_91

  mv a1, s0
  mv a2, s2
  li a3 4
  jal fread
  li t0 4
  bne a0, t0, error_91

  lw t0, 0(s1) # read the row number
  lw t1, 0(s2) # read the col number
  mul t0, t0, t1
  slli a0, t0, 2
  mv s4, a0 # use s4 to store the size of all elements in matrix for future fread
  jal malloc # call malloc
  beq zero, a0, error_88
  mv s3, a0 # use s3 to hold the matrix pointer

  # load the matrix
  mv a1, s0
  mv a2, s3
  mv a3, s4
  jal fread
  bne a0, s4, error_91

  # close the file
  mv a1, s0
  jal fclose
  li t0 -1
  beq t0, a0, error_92

    mv a0, s3

    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 24


    ret
