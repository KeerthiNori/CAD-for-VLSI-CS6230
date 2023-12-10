# CAD-for-VLSI-CS6230
Bluespec code for pipelined signed 64-bit multiplier

There are several algorithms for implementing Multipliers in hardware (such as Booth's Multiplier, Folded Multiplication by repeated addition, Wallace Multiplier)

We are using the following algorithm:<br />
Lets take operands of width 64-bit.

Input Format: Two 64-bit numbers, negative number should be given in 2s complement form.

Since 64th bit is sign bit for both the operands, We store sign bits of both the operands and accordingly calculate the sign bit of the output.<br />
After storing the signs of operands, we convert the operands in to positive version if there any negative numbers by 2s complement. <br />
So the following algorithm uses both positive operands and give positive result which is then changed to 2s complement form if the final sign bit is negative.


Algorithm:<br />
Now break the multiplier into 6-bit chunks. So we get a total of 11 chunks.<br />
In the first step of pipelining, Each 6 bit chunk is now multiplied with whole multiplicand to get 11 partial products.<br />
In the second step of pipelining, These 11 partial products in the previous stage, are added together to produce 5 intermediate products.<br />
In the Third step of pipelining, The above 5 intermediate products are added to get the final product.<br />

Output Format: 128-bit number, negative result will be shown in 2s complement form.<br />

Commands for Compiling and running the code:<br />
bsc -verilog multiplier_pipelined.bsv<br />
bsc -o sim -e mkTest mkTest.v<br />
./sim<br />

Verification and Synthesis:<br />
We checked the multiplier code with several examples. <br />
Then we used Yosys tool for Synthesis by following command:<br />
yosys -o output.blif -S mk_mul.v<br />
