//Project name: Pipelined 64 bit signed integer multiplier.
//Authors: EE20B078 & EE20B059
//It is a four-stage pipelined version. First, it breaks the multiplier into 6-bit chunks. 
//Then, it calculates partial products by multiplying them with the multiplicand. Finally, it adds up all the partial products.

package multiplier_pipelined;

  import DReg :: *;
  import Vector :: * ;
  `define XLEN 64

//Test Bench module to pass the address of the vectors in the memory and get back the output to display
  (* synthesize *)
 module mkTest (Empty);
    Ifc_mul a <- mk_mul;
    rule rl_input;    
        a.get_inp(64'hFFFFFFFFFFFFFFFF,64'hFFFFFFFFFFFFFFFF);
    endrule
    rule rl_output;
        match {.sign_fin,.product} = a.get_out();
        $display ("\nResult = %b", product);
        $finish ();      
    endrule
 endmodule
  
 interface Ifc_mul;
		method Action get_inp(Bit#(`XLEN) inp1, Bit#(`XLEN) inp2);
		method Tuple2#(Bit#(1),Bit#(TMul#(2, `XLEN))) get_out;
 endinterface: Ifc_mul

  (*synthesize*)
  module mk_mul(Ifc_mul);
    
    Reg#(Bit#(`XLEN)) operand1 <- mkReg(0);
    Reg#(Bit#(`XLEN)) operand2 <- mkReg(0);
    Reg#(Bit#(130)) result <- mkReg(0);
    
    Reg#(Bit#(1)) sign <- mkReg(0);
    Reg#(Bit#(1)) sign_1 <- mkReg(0);
    Reg#(Bit#(1)) sign_2 <- mkReg(0);
    Reg#(Bit#(1)) sign_3 <- mkReg(0);
    
    Reg#(Bool) stg1 <- mkReg (False);
    Reg#(Bool) stg2 <- mkReg (False);
    Reg#(Bool) stg3 <- mkReg (False);
    Reg#(Bool) stg4 <- mkReg (False);
  
    Reg#(Bit#(130)) pp0<- mkReg(0);
    Reg#(Bit#(130)) pp1 <- mkReg(0);
    Reg#(Bit#(130)) pp2 <- mkReg(0);
    Reg#(Bit#(130)) pp3 <- mkReg(0);
    Reg#(Bit#(130)) pp4 <- mkReg(0);
    Reg#(Bit#(140)) pp0_1 <- mkReg(0);
    Reg#(Bit#(140)) pp1_1 <- mkReg(0);
    Reg#(Bit#(140)) pp2_1 <- mkReg(0);
    Reg#(Bit#(140)) pp3_1 <- mkReg(0);
    Reg#(Bit#(140)) pp4_1 <- mkReg(0);
    Reg#(Bit#(140)) pp5_1 <- mkReg(0);
    Reg#(Bit#(140)) pp6_1 <- mkReg(0);
    Reg#(Bit#(140)) pp7_1 <- mkReg(0);
    Reg#(Bit#(140)) pp8_1 <- mkReg(0);
    Reg#(Bit#(140)) pp9_1 <- mkReg(0);
    Reg#(Bit#(140)) pp10_1 <- mkReg(0);
    
  //Function to generate the partial products for multiplication process
    function Bit#(140) func_pp_gen(Bit#(64) a,Bit#(6) b);                   

      Bit#(70) c=zeroExtend(a);
      Bit#(70) s1=0;
      Bit#(70) s2=0;
      Bit#(70) s3=0;
      Bit#(70) s4=0;
      Bit#(70) s5=0;
      Bit#(70) s6=0;
      
      Bit#(70) o1=0;
      Bit#(70) o2=0;
      Bit#(140) o=0;
      
      //shifting the required no.of bits according to the position for 6 bits of the multiplier
      s1 = (b[0]==1'b0)?70'd0:(c);
      s2 = (b[1]==1'b0)?70'd0:(c<<1);
      s3 = (b[2]==1'b0)?70'd0:(c<<2);
      s4 = (b[3]==1'b0)?70'd0:(c<<3);
      s5 = (b[4]==1'b0)?70'd0:(c<<4);
      s6 = (b[5]==1'b0)?70'd0:(c<<5);
      
      o1 =  s1+s2+s3;
      o2 =  s4+s5+s6;
      o= {o1,o2};
      return o;        
    endfunction
    
    // Stage 1 pipelining - evaluating partial products using the func_pp_gen function.
 	  rule r1_pp_gen_stage1(stg1);
      
      pp0_1<=func_pp_gen(operand1,operand2[5:0]);
      pp1_1<= func_pp_gen(operand1,operand2[11:6]);
      pp2_1<=func_pp_gen(operand1,operand2[17:12]);
      pp3_1<=func_pp_gen(operand1,operand2[23:18]);
      pp4_1<=func_pp_gen(operand1,operand2[29:24]);
      pp5_1<=func_pp_gen(operand1,operand2[35:30]);
      pp6_1<=func_pp_gen(operand1,operand2[41:36]);
      pp7_1<=func_pp_gen(operand1,operand2[47:42]);
      pp8_1<=func_pp_gen(operand1,operand2[53:48]);
      pp9_1<=func_pp_gen(operand1,operand2[59:54]);
      pp10_1<=func_pp_gen(operand1,{2'b00,operand2[63:60]});
      
      sign_1 <= sign;
      stg2 <= True;

    endrule
    
    // stage 2 pipelining - adding the values produced in the stage 1 to form the intermediate products
    rule rl_pp_gen_stage_2(stg2);
      
      pp0<= {60'd0,(pp0_1[69:0])}+{60'd0,pp0_1[139:70]}+{54'd0,(pp1_1[69:0]),6'd0}+{54'd0,(pp1_1[139:70]),6'd0};     
      pp1 <= {48'd0,(pp2_1[69:0]),12'd0}+{48'd0,(pp2_1[139:70]),12'd0}+{42'd0,(pp3_1[69:0]),18'd0}+{42'd0,(pp3_1[139:70]),18'd0};  
      pp2 <= {36'd0,(pp4_1[69:0]),24'd0}+{36'd0,(pp4_1[139:70]),24'd0}+{30'd0,(pp5_1[69:0]),30'd0}+{30'd0,(pp5_1[139:70]),30'd0};
      pp3 <= {24'd0,(pp6_1[69:0]),36'd0}+{24'd0,(pp6_1[139:70]),36'd0}+{18'd0,(pp7_1[69:0]),42'd0}+{18'd0,(pp7_1[139:70]),42'd0}+{(pp10_1[139:70]),60'd0};
      pp4 <= {12'd0,(pp8_1[69:0]),48'd0}+{12'd0,(pp8_1[139:70]),48'd0}+{6'd0,(pp9_1[69:0]),54'd0}+{6'd0,(pp9_1[139:70]),54'd0}+{(pp10_1[69:0]),60'd0};

      sign_2 <= sign_1;
      stg3 <= True;
    endrule
    
    //Stage 3 pipelining - Addition of intermediate products to get the final product
    rule rl_pp_gen_stage3(stg3);            
      Bit#(130) p1 =0;
      Bit#(130) p2 =0;
      Bit#(130) p3 =0;
      Bit#(130) p4 =0;
      Bit#(130) p5 =0;

      p1 = pack(pp0);
      p2 = pack(pp1);
      p3 = pack(pp2);
      p4 = pack(pp3);
      p5 = pack(pp4);

      result<= p1+p2+p3+p4+p5;                    
      
      sign_3 <= sign_2;
      stg4 <= True;
    endrule
    
    //Making the inputs positive if they are negative and sending the positive version of input
    method Action get_inp(Bit#(`XLEN) inp1, Bit#(`XLEN) inp2) if (!stg1);
      Bit#(1) sign1 = inp1[valueOf(`XLEN) - 1];
      Bit#(1) sign2 = inp2[valueOf(`XLEN) - 1];
      
      Bit#(`XLEN) opp1 =0;
      Bit#(`XLEN) opp2 =0;
      
      if ((sign1)==0) begin opp1 = inp1; end
      else begin opp1 = (~inp1)+ 64'd1; end
      if ((sign2)==0) begin opp2 = inp2; end
      else begin opp2 = (~inp2)+ 64'd1; end
      operand1 <= opp1;
      operand2 <= opp2;
      
      //determining the sign of the final product
      sign <= (sign2)^(sign1);
      stg1 <= True;
    
    endmethod
    
    //Method for receiving the output and making the output correctly signed according to the sign determined in the input stage
    method Tuple2#(Bit#(1),Bit#(TMul#(2, `XLEN))) get_out if(stg1 && stg4);
    
      Bit#(TMul#(2, `XLEN)) out=0;
      if (sign_3==1)
        out =~(result[127:0])+ 128'd1;
      else
        out = result[127:0];
      
      return tuple2(sign_3,out);
    endmethod

  endmodule
endpackage

