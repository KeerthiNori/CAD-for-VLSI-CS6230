# CAD-for-VLSI-CS6230
Bluespec code for pipelined signed 64-bit multiplier

There are several algorithms for implementing Multipliers in hardware (such as Booth's Multiplier, Folded Multiplication by repeated addition, Wallace Multiplier)

We are using the following algorithm:

Lets take operands of width 64-bit.

Input Format: Two 64-bit numbers, negative number should be given in 2s complement form.

Since 64th bit is sign bit for both the operands, We store sign bits of both the operands and accordingly calculate the sign bit of the output.
After storing the signs of operands, we convert the operands in to positive version if there any negative numbers by 2s complement. So the following algorithm uses both positive operands and give positive result which is then changed to 2s complement form if the final sign bit is negative.


Algorithm:

Now break the multiplier into 6-bit chunks. So we get a total of 11 chunks.

In the first step of pipelining, Each 6 bit chunk is now multiplied with whole multiplicand to get 11 partial products.

In the second step of pipelining, These 11 partial products in the previous stage, are added together to produce 5 intermediate products

In the Third step of pipelining, The above 5 intermediate products are added to get the final product

Commands for Compiling and running the code:

bsc -verilog multiplier_pipelined.bsv

bsc -o sim -e mkTest mkTest.v

./sim


Verification and Synthesis:

We checked the multiplier code with several examples. 

Then we used Yosys tool for Synthesis by following command:

yosys -o output.blif -S mk_mul.v
