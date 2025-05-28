`timescale 1ns / 1ps
//12bit 模加&模减（左加右减） 24bit模加 （DNTT & DINTT）
module Adder_2(
    input clk,rst,
    input [23:0] Adder2_a,  //K_2_NTT：24'b0          K_4_NTT：(F0,12b´0)            K_4_INTT：(T0,T0)  K_2_INTT：24'b0 
    input [23:0] Adder2_b,  //K_2_NTT：(F1,F3constw)  K_4_NTT：(F2*w2,T3*1821)       K_4_INTT：(T2,T2)  K_2_INTT：(F1-F3,F1-F3)
    input [1:0] Adder_2_mode,
    input [1:0] sel_a,
    output [23:0] Adder2_sum //此处把reg型改掉了
   ); 
    wire c1,c2,c3,b1,b2,b3,sel_K_4,sel_D;
    wire [11:0] s1,s2,s3,d1,AH,AL,BH,BL,add_sum,sub_sum;
    wire [22:0] q;
    wire [23:0] d2,d3,Adder2_sum_reg;
    wire [12:0] sum_high;
    wire [24:0] B;
    parameter Kq = 3329;
    parameter Dq = 8380417;
    
    // assign AH = Adder2_a[23:12];
    wire [11:0] AH_reg,AL_reg,AH_reg_shift_6,AH_reg_shift_1,AL_reg_shift_1;
    assign AH_reg = Adder2_a[23:12];
    assign AL = Adder2_a[11:0];

    shift_6 #(.data_width(12)) shf6_AH_reg (.clk(clk),.rst(rst),.data_in(AH_reg),.data_out(AH_reg_shift_6));//K_4_NTT
    // shift_1 #(.data_width(12)) shf1_AH_reg (.clk(clk),.rst(rst),.data_in(AH_reg),.data_out(AH_reg_shift_1));//K_4_INTT
    // shift_1 #(.data_width(12)) shf1_AL_reg (.clk(clk),.rst(rst),.data_in(AL_reg),.data_out(AL_reg_shift_1));//K_4_INTT
    assign AH_reg_1 = (sel_a  == 2'b1) ? AH_reg_shift_6 : AH_reg;//K_4_NTThe INTT移位 D的时候可能需要改 信号不涉及KD区分！

    wire [11:0] AH_reg_1; 
    DFF #(12) dff_AH_reg_1(.clk(clk),.rst(rst),.data_in(AH_reg_1),.data_out(AH));

    // assign AL = Adder2_a[11:0];
    assign BH = Adder2_b[23:12];
    assign BL = Adder2_b[11:0];
    
    assign {c1,s1} = AL + BL; 
    assign {c2,s2} = AL - BL; //Kyber 减 0-T3*1821
    assign {c3,s3} = AH + BH; //Kyber 加 F0+F2*w2




    // 12-bit 加减(KNTT & KINTT)
    assign {b1,d1} = s3 - Kq;
    assign sel_K_4 = ~((~c3) & b1 );
    assign add_sum = sel_K_4 == 1 ? d1 : s3;    // T0 + T2 （KINTT）   F0+F2·w1(KNTT)
    
    assign q = c2 == 1 ? Kq : 0;            //  T0 - T2 （KINTT）  -T3constw - 12'b0 (KNTT)
    assign sub_sum = s2 + q;
    //Adder2_sum = {add_sum,sub_sum}; //与Adder1不同的是高位相加，低位相减

    // 24-bit 加 (DNTT)
    assign sum_high = {c3,s3} +c1; 
    assign B = {sum_high,s1};
    assign {b2,d2} = B;
    assign {b3,d3} = d2 - Dq;
    assign sel_D = ~((~b2) & b3);
    assign Adder2_sum_reg = (sel_D == 1) ? d3 : d2;

    wire [11:0] add_sum_q1,sub_sum_q1;
    wire [23:0] Adder2_sum_reg_q1;
    DFF #(12) dff_add_sum(.clk(clk),.rst(rst),.data_in(add_sum),.data_out(add_sum_q1));
    DFF #(12) dff_sub_sum(.clk(clk),.rst(rst),.data_in(sub_sum),.data_out(sub_sum_q1));
    DFF #(24) dff_Adder2_sum_reg(.clk(clk),.rst(rst),.data_in(Adder2_sum_reg),.data_out(Adder2_sum_reg_q1));

    assign Adder2_sum = (Adder_2_mode == 2'd0) ? {sub_sum_q1,add_sum_q1} : (Adder_2_mode == 2'd1) ? {add_sum_q1,sub_sum_q1} : Adder2_sum_reg_q1;

    //K_2_NTT:24'b0
    //K_4_NTT:(F0+F2*w2,0-T3*2642)
    //K_4_INTT:(+,-)--(T0+T2,T0-T2) a0 = T0+T2 = Adder2_sum[23:12]
    //K_2_INTT:(-,+)--(F3-F1,F1-F3,)


endmodule

// `timescale 1ns / 1ps
// //12bit 模加&模减（左加右减） 24bit模加 （DNTT & DINTT）
// module Adder_2(
//     input [23:0] Adder2_a,  // 24-bit input a 
//     input [23:0] Adder2_b,  // 24-bit input b
//     input  KD_mode,
//     output reg [23:0] Adder2_sum
//    ); 
//     reg c1,c2,c3,c4,b1,b2,b3,sel;
//     reg [11:0] s1,s2,s3,s4,d1,AH,AL,BH,BL,add_sum,sub_sum;
//     reg [22:0] q;
//     reg [23:0] d2,d3,Adder2_sum_reg;
//     reg [12:0] sub_high,sum_high;
//     reg [24:0] A,B;
//     parameter Kq = 3329;
//     parameter Dq = 8380417;

//     always @(*) begin

//       AH = Adder2_a[23:12];
//       AL = Adder2_a[11:0];
//       BH = Adder2_b[23:12];
//       BL = Adder2_b[11:0];

//       {c1,s1} = AL + BL; //Kyber 减
//       {c2,s2} = AL - BL; 
//       {c3,s3} = AH + BH; //Kyber 加
//       {c4,s4} = AH - BH; 

//      // 12-bit 加减(KNTT & KINTT)
//       {b1,d1} = s3 - Kq;
//       sel = ~((~c3) & b1 );
//       add_sum = sel == 1 ? d1 : s3;    // T0 + T2 （KINTT）   F0+F2·w1(KNTT)
       
//       q = c2 == 1 ? Kq : 0;            //  T0 - T2 （KINTT）  -T3constw - 12'b0 (KNTT)
//       sub_sum = s2 + q;
//     //Adder2_sum = {add_sum,sub_sum}; //与Adder1不同的是高位相加，低位相减

//     // 24-bit 加 (DNTT)
//       sum_high = {c3,s3} +c1; 
//       B = {sum_high,s1};
//       {b2,d2} = B;
//       {b3,d3} = d2 - Dq;
//       sel = ~((~b2) & b3);
//       Adder2_sum_reg = (sel == 1) ? d3 : d2;

//       Adder2_sum = (KD_mode == 1'b0) ? {add_sum,sub_sum} : Adder2_sum_reg;

//     end
// endmodule
