// This file is part of the materials accompanying the book 
// "The Elements of Computing Systems" by Nisan and Schocken, 
// MIT Press. Book site: www.idc.ac.il/tecs
// File name: projects/02/Add16.tst

load ZeroNeg.hdl,
output-file ZeroNeg.out,
output-list x%B1.16.1 out%B1.16.1;

set x %B0000000000000000,
set zx %B0,
set nx %B0,
eval,
output;

set x %B0000000000000000,
set zx %B1,
set nx %B0,
eval,
output;

set x %B0000000000000000,
set zx %B0,
set nx %B1,
eval,
output;

set x %B0000000000000000,
set zx %B1,
set nx %B1,
eval,
output;
