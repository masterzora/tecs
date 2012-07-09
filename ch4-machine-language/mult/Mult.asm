// This file is part of the materials accompanying the book 
// "The Elements of Computing Systems" by Nisan and Schocken, 
// MIT Press. Book site: www.idc.ac.il/tecs
// File name: projects/04/Mult.asm

// Multiplies R0 and R1 and stores the result in R2.
// (R0, R1, R2 refer to RAM[0], RAM[1], and RAM[2], respectively.)

  @R2
  M=0
(LOOP)
  @R1
  D=M
  @END
  D;JLE
  @R0
  D=M
  @R2
  M=M+D
  @R1
  M=M-1
  @LOOP
  0;JMP
(END)
  @END
  0;JMP
