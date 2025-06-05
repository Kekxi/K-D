// `timescale 1ns / 1ps
// //12bit 模加&加减（左加右加）--KNTT 24bit模加--DINTT  24bit 模减--KINTT&DNTT
// module Adder_4(
//     input clk,rst,
//     input [23:0] Adder4_a,  
//     input [23:0] Adder4_b,  
//     input Adder_4_mode,
//     input sel_D_2_NTT,
//     output [23:0] Adder4_sum
//    );
    
//     reg c1,c2,c3,c4,b1,b2,b3,sel;
//     reg [11:0] s1,s2,s3,s4,d1,AH,AL,BH,BL,add_sum0,add_sum1;
//     reg [22:0] q;
//     reg [23:0] d2,d3;
//     reg [12:0] sub_high,sum_high;
//     reg [24:0] A,B;
//     reg [23:0] Adder4_sum_reg;

//     parameter Kq = 3329;
//     parameter Dq = 8380417;

    
//     wire [11:0] AH_reg = Adder4_a[23:12]; 
//     wire [11:0] AL_reg = Adder4_a[11:0];
//     //D_2_NTT
//     wire [11:0] AH_reg_shift_6,AL_reg_shift_6;
//     shift_6 #(.data_width(12)) shf6_AH_reg (.clk(clk),.rst(rst),.data_in(AH_reg),.data_out(AH_reg_shift_6));
//     shift_6 #(.data_width(12)) shf6_AL_reg (.clk(clk),.rst(rst),.data_in(AL_reg),.data_out(AL_reg_shift_6));

//     always @(*) begin

//       AH = (sel_D_2_NTT == 1'b1) ? AH_reg_shift_6 : AH_reg; //0
//       AL = (sel_D_2_NTT == 1'b1) ? AL_reg_shift_6 : AL_reg; //2
//       BH = Adder4_b[23:12];  //1
//       BL = Adder4_b[11:0];  //3

//       {c1,s1} = AL + BL; //Kyber 加  2+3
//       {c2,s2} = AL - BL; 
//       {c3,s3} = AH + BH; //Kyber 加 0+1
//       {c4,s4} = AH - BH; 

//       case (Adder_4_mode)
//       //   2'b00: begin
//         1'b0: begin
//           // 12-bit 加加 (KNTT & KINTT) KINTT时，基2和基4输入的都是0
//            {b1,d1} = s3 - Kq;
//            sel = ~((~c3) & b1 );
//            add_sum1 = sel == 1 ? d1 : s3;
//            // A0 =  {c3,s3}; // 按照有符号数看，可能为负数，直接取模不准确
//            // add_sum_A0 = A0 % Kq; // 验证

//            {b2,d2} = s1 - Kq;
//            sel = ~((~c1) & b2 );
//            add_sum0 = sel == 1 ? d2 : s1;
//            // B0 = {c1,s1}; // 按照有符号数看，可能为负数，直接取模不准确
//            // add_sum0_B0 = B0 % Kq; // 验证
            
//            Adder4_sum_reg = {add_sum1,add_sum0};  //(A1,A3)
//           //  Adder4_sum_reg = {add_sum1_q1,add_sum0_q1};  //(A1,A3)
//            // Adder4_sum_AB = {add_sum_A0,add_sum0_B0}; //验证
//         end 
//       //   2'b01: begin
//         1'b1: begin
//            // 24-bit 减 (DNTT & DINTT)
//             sub_high = {c4,s4} - c2;
//             A = {sub_high,s2};
//             {b2,d2} = A;
//             q = b2 == 1 ? Dq : 0;
//             Adder4_sum_reg = d2 + q;
//             // Adder4_sum_AB = (Adder4_a - Adder4_b) % Dq; //验证 注意：负数模时不准确！单独验证
//          end

//         endcase
//     end

   
//     // wire [23:0] Adder4_sum_reg_q1;
//     // DFF #(24) dff_Adder4_sum_reg(.clk(clk),.rst(rst),.data_in(Adder4_sum_reg),.data_out(Adder4_sum_reg_q1));

//     // assign Adder4_sum = Adder4_sum_reg_q1;
//     assign Adder4_sum_q1 = Adder4_sum_reg;
// endmodule
