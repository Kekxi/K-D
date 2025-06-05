`timescale 1ns / 1ps
//12bit 12bit 模加&模减（左加右减） 24bit模减  24bit模加  
module Adder_3(
   input clk,rst,
    input [23:0] Adder3_a,  // 24-bit input a 
    input [23:0] Adder3_b,  // 24-bit input b
   //  input [1:0] Adder_3_mode,
    input  Adder_3_mode,
    input sel_a,
    input sel_D_2_NTT,
    output [23:0] Adder3_sum
   );
    reg c1,c2,c3,c4,b1,b2,b3,sel;
    reg [11:0] s1,s2,s3,s4,d1,AH,AL,BH,BL,add_sum,sub_sum0;
    reg [22:0] q,q0,q1;
    reg [23:0] d2,d3;
    reg [12:0] sub_high,sum_high;
    reg [24:0] A,B;
    reg [23:0] Adder3_sum_reg;
    //reg signed [24:0] Adder3_sum_reg;  // 中间结果为有符号数

    parameter Kq = 3329;
    parameter Dq = 8380417;
   //  wire [11:0] add_sum_q1,sub_sum0_q1;
   //  wire [23:0] Adder3_sum_q1;
    //触发器类型都是wire 传递参数保持一致！
   //  DFF #(12) dff_add_sum(.clk(clk),.rst(rst),.data_in(add_sum),.data_out(add_sum_q1));
   //  DFF #(12) dff_sub_sum0(.clk(clk),.rst(rst),.data_in(sub_sum0),.data_out(sub_sum0_q1));
   //  DFF #(24) dff_Adder3_sum_q1(.clk(clk),.rst(rst),.data_in(Adder3_sum_q1),.data_out(Adder3_sum));

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
      BH = (sel_a == 1'b1) ? BH_reg_shift_7 : BH_reg;
      BL = (sel_a == 1'b1) ? BL_reg_shift_7 : BL_reg;

      {c1,s1} = AL + BL; //
      {c2,s2} = AL - BL; //Kyber 减  DINTT时F1-F3
      {c3,s3} = AH + BH; //Kyber 加  
      {c4,s4} = AH - BH;  //DINTT时F0-F2

      case (Adder_3_mode) 
        //2'b00 begin
        1'b0: begin
           // 12-bit 加&减（KNTT & KINTT）
           {b1,d1} = s3 - Kq;
           sel = ~((~c3) & b1 );
           add_sum = sel == 1 ? d1 : s3;
           //A0 = {c3,s3}; // 按照有符号数看，可能为负数，直接取模不准确
           //add_sum_A0 = A0 % Kq; // 验证

           q0 = c4 == 1 ? Kq : 0;
           sub_sum0 = s4 + q0;
           //B0 = {c2,s2}; // 按照有符号数看，可能为负数，直接取模不准确
           //sub_sum0_B0 = B0 % Kq; // 验证
           //Adder3_sum_reg = {add_sum_q1,sub_sum0_q1};
           Adder3_sum_reg = {add_sum,sub_sum0};
           //Adder3_sum_AB = {add_sum_A0,sub_sum0_B0}; //验证
         end
      //    2'b01: begin
      //      // 24-bit 减 （DINTT）
      //      // sub_high = {c4,s4} - c2;
      //      // A = {sub_high,s2};
      //      // {b2,d2} = A;
      //      // q = b2 == 1 ? Dq : 0;
      //      // Adder3_sum = d2 + q;
      //      Adder3_sum_reg = Adder3_a - Adder3_b;
      //      Adder3_sum_q1 =  (Adder3_sum_reg < 0) ? Adder3_sum_reg + Dq : Adder3_sum_reg; //注意Adder3_sum_reg应该是有符号数 能表述正负
      //      // Adder3_sum_AB = (Adder3_a - Adder3_b) % Dq; //验证 注意：负数模时不准确！单独验证
      //   end
         // 2'b10: begin
         1'b1: begin
           // 24-bit 加（DNTT）
            sum_high = {c3,s3} +c1; 
            B = {sum_high,s1};
            {b2,d2} = B;
            {b3,d3} = d2 - Dq;
            sel = ~((~b2) & b3);
            Adder3_sum_reg = sel == 1 ? d3 : d2;
            // Adder3_sum_AB = (Adder3_a + Adder3_b) % Dq; //验证
         end
        endcase
    end
   
   // wire [23:0] Adder3_sum_reg_q1;
   // DFF #(24) dff_Adder3_sum_reg(.clk(clk),.rst(rst),.data_in(Adder3_sum_reg),.data_out(Adder3_sum_reg_q1));
   // assign Adder3_sum = Adder3_sum_reg_q1;
   assign Adder3_sum = Adder3_sum_reg;

endmodule
