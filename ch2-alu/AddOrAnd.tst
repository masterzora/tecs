// This file is part of the materials accompanying the book 
// "The Elements of Computing Systems" by Nisan and Schocken, 
// MIT Press. Book site: www.idc.ac.il/tecs
// File name: projects/02/Add16.tst

load AddOrAnd.hdl,
output-file AddOrAnd.out,
output-list x%B1.16.1 y%B1.16.1 out%B1.16.1;

set x %B0000000000000000,
set y %B1111111111111111,
set f %B0,
eval,
output;

set x %B1111111111111111,
set y %B1111111111111111,
set f %B0,
eval,
output;

set x %B0000000000000000,
set y %B1111111111111111,
set f %B1,
eval,
output;

set x %B1111111111111111,
set y %B1111111111111111,
set f %B1,
eval,
output;
