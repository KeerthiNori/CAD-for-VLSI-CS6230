//Project name: Pipelined 64 bit signed integer multiplier.
//Authors: EE20B078 & EE20B059
//It is a four-stage pipelined version. First, it breaks the multiplier into 8-bit chunks. 
//Then, it calculates partial products by multiplying them with the multiplicand. Finally, it adds up all the partial products.

package multiplier_pipelined;

  import DReg :: *;
  import Vector :: * ;
  `define wid 64

//Test Bench module to pass the address of the vectors in the memory and get back the output to display
  (* synthesize *)
 module mkTest (Empty);
    Ifc_mul a <- mk_mul;
    rule rl_input;    
        a.get_inp(64'd3,64'd7);
    endrule
    rule rl_output;
        match {.sign_fin,.product} = a.get_out();
        $display ("\nResult = %b", product);
        $finish ();      
    endrule
 endmodule
  
 interface Ifc_mul;
		method Action get_inp(Bit#(`wid) inp1, Bit#(`wid) inp2);
		method Tuple2#(Bit#(1),Bit#(TMul#(2, `wid))) get_out;
 endinterface: Ifc_mul

  (*synthesize*)
  module mk_mul(Ifc_mul);
     
    Reg#(Bit#(144)) pp0 <- mkReg(0);
    Reg#(Bit#(144)) pp1 <- mkReg(0);
    Reg#(Bit#(144)) pp2 <- mkReg(0);
    Reg#(Bit#(144)) pp3 <- mkReg(0);
    Reg#(Bit#(144)) pp4 <- mkReg(0);
    Reg#(Bit#(144)) pp5 <- mkReg(0);
    Reg#(Bit#(144)) pp6 <- mkReg(0);
    Reg#(Bit#(144)) pp7 <- mkReg(0);
  
    Reg#(Bit#(130)) pp8<- mkReg(0);
    Reg#(Bit#(130)) pp9 <- mkReg(0);
    Reg#(Bit#(130)) pp10 <- mkReg(0);
    Reg#(Bit#(130)) pp11 <- mkReg(0);
    Reg#(Bit#(130)) result <- mkReg(0);
    
    Reg#(Bit#(`wid)) operand1 <- mkReg(0);
    Reg#(Bit#(`wid)) operand2 <- mkReg(0);
    
    
    Reg#(Bit#(1)) sign <- mkReg(0);
    Reg#(Bit#(1)) sign1 <- mkReg(0);
    Reg#(Bit#(1)) sign2 <- mkReg(0);
    Reg#(Bit#(1)) sign3 <- mkReg(0);
    
    Reg#(Bool) stg1 <- mkReg (False);
    Reg#(Bool) stg2 <- mkReg (False);
    Reg#(Bool) stg3 <- mkReg (False);
    Reg#(Bool) stg4 <- mkReg (False);

  //Function to generate the partial products for multiplication process
 	  function Bit#(144) func_pp_gen(Bit#(64) a,Bit#(8) b);                   

      Bit#(72) c=zeroExtend(a);
      Bit#(72) s1=0;
      Bit#(72) s2=0;
      Bit#(72) s3=0;
      Bit#(72) s4=0;
      Bit#(72) s5=0;
      Bit#(72) s6=0;
      Bit#(72) s7=0;
      Bit#(72) s8=0;
      
      Bit#(72) sum1=0;
      Bit#(72) sum2=0;
      Bit#(144) sum=0;
      
      //shifting the required no.of bits according to the position for 8 bits of the multiplier
      s1 = (b[0]==1'b0)?72'd0:(c);
      s2 = (b[1]==1'b0)?72'd0:(c<<1);
      s3 = (b[2]==1'b0)?72'd0:(c<<2);
      s4 = (b[3]==1'b0)?72'd0:(c<<3);
      s5 = (b[4]==1'b0)?72'd0:(c<<4);
      s6 = (b[5]==1'b0)?72'd0:(c<<5);
      s7 = (b[6]==1'b0)?72'd0:(c<<6);
      s8 = (b[7]==1'b0)?72'd0:(c<<7);
      
      sum1 =  s1+s2+s3+s4;
      sum2 =  s5+s6+s7+s8;
      sum= {sum1,sum2};
      return sum;        
    endfunction
    
    // Stage 1 pipelining - evaluating partial products using the func_pp_gen function.
 	  rule r1_pp_gen_stage1(stg1);
      
      pp0<=func_pp_gen(operand1,operand2[7:0]);
      pp1<= func_pp_gen(operand1,operand2[15:8]);
      pp2<=func_pp_gen(operand1,operand2[23:16]);
      pp3<=func_pp_gen(operand1,operand2[31:24]);
      pp4<=func_pp_gen(operand1,operand2[39:32]);
      pp5<=func_pp_gen(operand1,operand2[47:40]);
      pp6<=func_pp_gen(operand1,operand2[55:48]);
      pp7<=func_pp_gen(operand1,operand2[63:56]);
      
      sign1 <= sign;
      stg2 <= True;

    endrule
    
    // stage 2 pipelining - adding the values produced in the stage 1 to form the intermediate products
    rule rl_pp_gen_stage_2(stg2);
      
      pp8<= {58'd0,(pp0[71:0])}+{58'd0,pp0[143:72]}+{50'd0,(pp1[71:0]),8'd0}+{50'd0,(pp1[143:72]),8'd0};     
      pp9 <= {42'd0,(pp2[71:0]),16'd0}+{42'd0,(pp2[143:72]),16'd0}+{34'd0,(pp3[71:0]),24'd0}+{34'd0,(pp3[143:72]),24'd0};  
      pp10 <= {26'd0,(pp4[71:0]),32'd0}+{26'd0,(pp4[143:72]),32'd0}+{18'd0,(pp5[71:0]),40'd0}+{18'd0,(pp5[143:72]),40'd0};
      pp11 <= {10'd0,(pp6[71:0]),48'd0}+{10'd0,(pp6[143:72]),48'd0}+{2'd0,(pp7[71:0]),56'd0}+{2'd0,(pp7[143:72]),56'd0};

      sign2 <= sign1;
      stg3 <= True;
    endrule
    
    //Stage 3 pipelining - Addition of intermediate products to get the final product
    rule rl_pp_gen_stage3(stg3);            
      Bit#(130) p1 =0;
      Bit#(130) p2 =0;
      Bit#(130) p3 =0;
      Bit#(130) p4 =0;

      p1 = pack(pp8);
      p2 = pack(pp9);
      p3 = pack(pp10);
      p4 = pack(pp11);

      result<= p1+p2+p3+p4;                    
      
      sign3 <= sign2;
      stg4 <= True;
    endrule
    
    //Making the inputs positive if they are negative and sending the positive version of input
    method Action get_inp(Bit#(`wid) inp1, Bit#(`wid) inp2) if (!stg1);
      Bit#(1) signa = inp1[valueOf(`wid) - 1];
      Bit#(1) signb = inp2[valueOf(`wid) - 1];
      
      Bit#(`wid) opp1 =0;
      Bit#(`wid) opp2 =0;
      
      if ((signa)==0) begin opp1 = inp1; end
      else begin opp1 = (~inp1)+ 64'd1; end
      if ((signb)==0) begin opp2 = inp2; end
      else begin opp2 = (~inp2)+ 64'd1; end
      operand1 <= opp1;
      operand2 <= opp2;
      
      //determining the sign of the final product
      sign <= (signb)^(signa);
      stg1 <= True;
    
    endmethod
    
    //Method for receiving the output and making the output correctly signed according to the sign determined in the input stage
    method Tuple2#(Bit#(1),Bit#(TMul#(2, `wid))) get_out if(stg1 && stg4);
    
      Bit#(TMul#(2, `wid)) out=0;
      if (sign3==1)
        out =~(result[127:0])+ 128'd1;
      else
        out = result[127:0];
      
      return tuple2(sign3,out);
    endmethod

  endmodule
endpackage

