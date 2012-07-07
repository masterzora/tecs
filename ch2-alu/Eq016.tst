// This file is part of the materials accompanying the book 
// "The Elements of Computing Systems" by Nisan and Schocken, 
// MIT Press. Book site: www.idc.ac.il/tecs
// File name: projects/02/Add16.tst

load Eq016.hdl,
output-file Eq016.out,
output-list in%B1.16.1 out%B1.1.1;

set in %B0000000000000000,
eval,
output;

set in %B1111111111111111,
eval,
output;

set in %B0000000000000001,
eval,
output;

set in %B1111111111111110,
eval,
output;
