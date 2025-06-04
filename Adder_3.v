`timescale 1ns / 1ps
//12bit 12bit 模加&模减（左加右减） 24bit模减  24bit模加  改完多了两个二选一选择器
module Adder_2(
   input clk,rst,
    input [23:0] Adder2_a,  // 24-bit input a 
    input [23:0] Adder2_b,  // 24-bit input b
    input  KD_mode,    
    input sel_K_4_NTT,     //sel_a = 1---K_4_NTT
    input sel_D_2_NTT,
    input sel,              //sel = 1---Adder3_out
    output [23:0] Adder2_sum
   );
    reg c1,c2,c3,c4,b1,b2,b3,sel;
    reg [11:0] s1,s2,s3,s4,d1,AH,AL,BH,BL,add_sum,sub_sum0;
    reg [22:0] q,q0,q1;
    reg [23:0] d2,d3;
    reg [12:0] sub_high,sum_high;
    reg [24:0] A,B;
    reg [23:0] Adder3_sum_reg;

    parameter Kq = 3329;
    parameter Dq = 8380417;

    //tb
    wire [11:0] Adder3_a_H = Adder3_a[23:12];
    wire [11:0] Adder3_a_L = Adder3_a[11:0];

    wire [11:0] BH_reg_shift_7,BL_reg_shift_7,AH_reg_shift_6,AL_reg_shift_6;
    wire [11:0] BH_reg = Adder3_b[23:12]; 
    wire [11:0] BL_reg = Adder3_b[11:0];
    wire [11:0] AH_reg = Adder3_a[23:12]; 
    wire [11:0] AL_reg = Adder3_a[11:0];

    // K_4_NTT 
    shift_7 #(.data_width(12)) shf7_BH_reg (.clk(clk),.rst(rst),.data_in(BH_reg),.data_out(BH_reg_shift_7));
    shift_7 #(.data_width(12)) shf7_BL_reg (.clk(clk),.rst(rst),.data_in(BL_reg),.data_out(BL_reg_shift_7));
    //D_2_NTT
    shift_6 #(.data_width(12)) shf6_AH_reg (.clk(clk),.rst(rst),.data_in(AH_reg),.data_out(AH_reg_shift_6));
    shift_6 #(.data_width(12)) shf6_AL_reg (.clk(clk),.rst(rst),.data_in(AL_reg),.data_out(AL_reg_shift_6));



    always @(*) begin

      AH = (sel_D_2_NTT == 1'b1) ? AH_reg_shift_6 : AH_reg; //D时 F0
      AL = (sel_D_2_NTT == 1'b1) ? AL_reg_shift_6 : AL_reg;  //D时 F1
      BH = (sel_K_4_NTT == 1'b1) ? BH_reg_shift_7 : BH_reg;
      BL = (sel_K_4_NTT == 1'b1) ? BL_reg_shift_7 : BL_reg;

      {c1,s1} = AL + BL; //
      {c2,s2} = AL - BL; //Kyber 减  DINTT时F1-F3
      {c3,s3} = AH + BH; //Kyber 加  
      {c4,s4} = AH - BH;  //DINTT时F0-F2

      case (KD_mode) 
        1'b0: begin // K_4_NTT(+-/++)/K_4_INTT (+-/0)

           //AH + BH
           {b1,d1} = s3 - Kq;
           sel = ~((~c3) & b1 );
           add_sum = sel == 1 ? d1 : s3;
           //AH - BH
           q0 = c4 == 1 ? Kq : 0;
           sub_sum0 = s4 + q0;
           //AL + BL
           {b2,d2} = s1 - Kq; 
           sel = ~((~c1) & b2 );
           add_sum0 = sel == 1 ? d2 : s1;
      
           //sel=0---Adder3_out sel=1---Adder4_out 
           Adder2_sum_reg = (sel == 1'b0) ? {add_sum,sub_sum0} : {add_sum,add_sum0};

         end

        1'b1: begin // D_2_NTT(+)/D_2_INTT (-)
          // 24-bit 加（DNTT）
           sum_high = {c3,s3} +c1; 
           B = {sum_high,s1};
           {b2,d2} = B;
           {b3,d3} = d2 - Dq;
           sel = ~((~b2) & b3);
           Adder2_sum_reg_0 = sel == 1 ? d3 : d2;

           //24-bit 减 (DNTT & DINTT)
           sub_high = {c4,s4} - c2;
           A = {sub_high,s2};
           {b2,d2} = A;
           q = b2 == 1 ? Dq : 0;
           Adder2_sum_reg_1 = d2 + q;

           Adder2_sum_reg = (sel_D_2_NTT == 1'b1) ? Adder2_sum_reg_0 : Adder2_sum_reg_1;
 
        end
        endcase
    end
   
   // wire [23:0] Adder3_sum_reg_q1;
   // DFF #(24) dff_Adder3_sum_reg(.clk(clk),.rst(rst),.data_in(Adder3_sum_reg),.data_out(Adder3_sum_reg_q1));
   // assign Adder3_sum = Adder3_sum_reg_q1;
   assign Adder2_sum = Adder2_sum_reg;

endmodule
