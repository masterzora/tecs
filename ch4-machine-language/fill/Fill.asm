// This file is part of the materials accompanying the book 
// "The Elements of Computing Systems" by Nisan and Schocken, 
// MIT Press. Book site: www.idc.ac.il/tecs
// File name: projects/04/Fill.asm

// Runs an infinite loop that listens to the keyboard input. 
// When a key is pressed (any key), the program blackens the screen,
// i.e. writes "black" in every pixel. When no key is pressed, 
// the screen should be cleared.
@R0
M=0
(LOOP)
  @KBD
  D=M
  @CLEAR
  D;JEQ
(FILL)
  @R0
  D=M
  @SCREEN
  A=A+D
  M=0
  M=!M
  @ENDIF
  0;JMP
(CLEAR)
  @R0
  D=M
  @SCREEN
  A=A+D
  M=0
(ENDIF)
  @8192
  D=A
  @R0
  M=M+1
  D=M-D
  @CONTINUE
  D;JLT
  @R0
  M=0
(CONTINUE)
  @LOOP
  0;JMP
(END)
