.globl classify

.text
classify:
    # =====================================
    # COMMAND LINE ARGUMENTS
    # =====================================
    # Args:
    #   a0 (int)    argc
    #   a1 (char**) argv
    #   a2 (int)    print_classification, if this is zero, 
    #               you should print the classification. Otherwise,
    #               this function should not print ANYTHING.
    # Returns:
    #   a0 (int)    Classification
    # Exceptions:
    # - If there are an incorrect number of command line args,
    #   this function terminates the program with exit code 89.
    # - If malloc fails, this function terminats the program with exit code 88.
    #
    # Usage:
    #   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>

    # Prologue
    addi sp, sp, -80
    sw ra, 0(sp)
    sw s0, 4(sp) # m0 path / matrix pointer
    sw s1, 8(sp) # m1 path / matrix pointer
    sw s2, 12(sp) # input path / matrix pointer
    sw s3, 16(sp) # output path
    sw s4, 20(sp) # print classification option
    sw s5, 24(sp) # m0_rows
    sw s6, 28(sp) # m0_cols
    sw s7, 32(sp) # m1_rows
    sw s8, 36(sp) # m2_cols
    sw s9, 40(sp) # input rows
    sw s10, 44(sp) # input cols
    sw s11, 48(sp) # score matrix / temporary matrix

  # Check argument number
  li t0, 5
  bne a0, t0, error_89

	# =====================================
    # LOAD MATRICES
    # =====================================
    lw s0, 4(a1) # load m0 path
    lw s1, 8(a1) # load m1 path
    lw s2, 12(a1) # load input path
    lw s3, 16(a1) # load output path

    mv s4, a2 # store print classification option

    # Load pretrained m0
    mv a0, s0
    addi a1, sp, 52
    addi a2, sp, 56
    jal read_matrix
    # After read matrix, we no longer needs the path, reuse s0 to hold the matrix
    mv s0, a0
    lw s5, 52(sp)
    lw s6, 56(sp) # HACK: the implementation of read_matrix won't use t registers (except t0 and t1)

    # Load pretrained m1
    mv a0, s1
    addi a1, sp, 60
    addi a2, sp, 64
    jal read_matrix
    mv s1, a0
    lw s7, 60(sp)
    lw s8, 64(sp) # Similar steps

    # Load input matrix
    mv a0, s2
    addi a1, sp, 68
    addi a2, sp, 72
    jal read_matrix
    mv s2, a0
    lw s9, 68(sp)
    lw s10, 72(sp) # Similar steps

    # Now s0 holds m0, s1 holds m1, s2, holds input matrix

    # =====================================
    # RUN LAYERS
    # =====================================
    # 1. LINEAR LAYER:    m0 * input
    # 2. NONLINEAR LAYER: ReLU(m0 * input)
    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input)
    mul, a0, s5, s10# allocate memory for m0 * input
    slli a0, a0, 2
    jal malloc
    beq a0, zero, error_88
    mv s11, a0

    mv a0, s0
    mv a1, s5
    mv a2, s6
    mv a3, s2
    mv a4, s9
    mv a5, s10
    mv a6, s11 # use s7 to hold m0 * input
    jal matmul

    mv a0, s11
    mul a1, s5, s10
    jal relu

    sw s11, 76(sp) # save the temporary matrix on stack
    mul, a0, s7, s10
    slli a0, a0, 2
    jal malloc
    beq zero, a0, error_88
    mv s11, a0

    mv a0, s1 # m1
    mv a1, s7
    mv a2, s8
    lw a3, 76(sp)
    mv a4, s5
    mv a5, s10
    mv a6, s11
    jal matmul

    # =====================================
    # WRITE OUTPUT
    # =====================================
    # Write output matrix
    mv a0, s3
    mv a1, s11
    mv a2, s7
    mv a3, s10
    jal write_matrix


    # =====================================
    # CALCULATE CLASSIFICATION/LABEL
    # =====================================
    # Call argmax
    mv a0, s11
    mul a1, s7, s10
    jal argmax
    mv s3, a0 # the output path is no longer needed

    # free m0 m1 input_matrix, score matrix, temporary matrix
    mv a0, s0
    jal free
    mv a0, s1
    jal free
    mv a0, s2
    jal free
    mv a0, s11
    jal free
    lw a0, 76(sp)
    jal free

    # Print classification
    bne zero, s4, print_done
    mv a1, s3
    jal print_int

    # Print newline afterwards for clarity
    li a1, '\n'
    jal print_char

print_done:
    mv a0, s3

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
    lw s9, 40(sp)
    lw s10, 44(sp)
    lw s11, 48(sp)
    addi sp, sp, 80
    ret

error_89:
  li a1, 89
  jal exit2

error_88:
  li a1, 88
  jal exit2

