`timescale 1ns / 1ps 
//这个模块 gpt给出关键路径过长的问题 建议优化时序 可参考
//12bit 模加&模减（高减低加，KINTT输出处理下） 24bit模加（DNTT & DINTT）
module Adder_1(
    input clk,rst,
    input [23:0] Adder1_a,  // K_2_NTT：(F2,F3*constw) K_4_NTT：(F2*w2,T3*2642)  K_4_INTT：(F3,F3)   K_2_INTT：(F1,F3)  D_2_NTT:rH·ωH·2^24+rL·ωH·2^12 
    input [23:0] Adder1_b,  //K_2_NTT：24'b0           K_4_NTT：(F0,12b´0)       K_4_INTT：(F1,F1)   K_2_INTT：24'b0    D_2_NTT:P0
    input sel_1,//暂时传这个信号，不确定D是否需要根据NTT和INTT区分 来移位
    input [1:0] Adder_1_mode, 
    output [23:0] Adder1_sum //此处把reg型改掉了
   );
    
    wire c1_1,c4_1,c1,c2,c3,c4,b1_1,b1,b2,b3,sel_K_2,sel_K_4,sel_D;
    wire [11:0] s1_1,s4_1,s1,s2,s3,s4,d1_1,d1,AH,AL,BH,BL,add_sum_1,sub_sum_1,add_sum,sub_sum;
    wire [22:0] q,q_1;
    wire [23:0] d2,d3,Adder1_sum_reg;
    wire [12:0] sub_high,sum_high;
    wire [24:0] A,B;
    parameter Kq = 3329;
    parameter Dq = 8380417;

    assign AH = Adder1_a[23:12]; //K_2_NTT--F2  K_4_INTT--F3
    assign AL = Adder1_a[11:0];  //K_2_NTT--F3*constw
    assign BH_reg = Adder1_b[23:12]; //K_4_INTT--F1  K_4_NTT--F0（u0）shift_6
    assign BL = Adder1_b[11:0];

    wire [11:0] BH_reg,BH_reg_shift_13;
    shift_13 #(.data_width(12)) shf13_BH_reg (.clk(clk),.rst(rst),.data_in(BH_reg),.data_out(BH_reg_shift_13)); 
    assign BH = (sel_1 == 1'b0 ) ? BH_reg_shift_13 : BH_reg; //INTT不移位

    assign {c1_1,s1_1} = AH + AL;
    assign {c4_1,s4_1} = AH - AL;
    assign {c1,s1} = AL + BL;   //Kyber_4 加 低位相加                    K_4_NTT:T3*2642+0    K_4_INTT:F3+F1
    assign {c2,s2} = BL - AL;   //调整过 跟Adder2区分
    assign {c3,s3} = AH + BH;  
    assign {c4,s4} = BH - AH; //Kyber_4 减 高位相减 调整过跟 Adder2区分 K_4_NTT:F0-F2*w2      K_4_INTT:F1-F3
    //assign {c4,s4} = BH - AH;   //Kyber_4 减 高位相减 调整过跟 Adder2区分 K_4_NTT:F0-F2*w2      K_4_INTT:F1-F3 

    // 12-bit 加&减 (K_2_NTT & K_2_INTT)   
    assign {b1_1,d1_1} = s1_1 - Kq;
    assign sel_K_2 = ~((~c1_1) & b1_1 );
    assign add_sum_1 = (sel_K_2 == 1) ? d1_1 : s1_1;  
    
    assign q_1 = (c4_1 == 1) ? Kq : 0;
    assign sub_sum_1 = s4_1 + q_1;         

    // 12-bit 加&减 (K_4_NTT & K_4_INTT)   此处可以考虑优化 和Adder2合并 参数传递调整下 易出错
    assign {b1,d1} = s1 - Kq;
    assign sel_K_4 = ~((~c1) & b1 );
    assign add_sum = (sel_K_4 == 1) ? d1 : s1;  //  12'b0+T3constw(KNTT)  F0+F2·w1(KNTT)   T2=F1+F3(KINTT)
    
    assign q = c4 == 1 ? Kq : 0;          //  F0-F2·w1(KNTT)     -T3constw - 12'b0 (KNTT)   F1-F3(KINTT)
    assign sub_sum = s4 + q;
       
    // Adder1_sum = {sub_sum,add_sum}; //与Adder2不同的是 高位相减，低位相加

    // 24-bit 加 (DNTT/DINTT)
    assign sum_high = {c3,s3} +c1; 
    assign B = {sum_high,s1};
    assign {b2,d2} = B;
    assign {b3,d3} = d2 - Dq;
    assign sel_D = ~((~b2) & b3);
    assign Adder1_sum_reg = (sel_D == 1) ? d3 : d2;

    wire [11:0] add_sum_q1,sub_sum_q1,add_sum_1_q1,sub_sum_1_q1;
    wire [23:0] Adder1_sum_reg_q1;
    // DFF #(12) dff_add_sum_1(.clk(clk),.rst(rst),.data_in(add_sum_1),.data_out(add_sum_1_q1));
    // DFF #(12) dff_sub_sum_1(.clk(clk),.rst(rst),.data_in(sub_sum_1),.data_out(sub_sum_1_q1));
    // DFF #(12) dff_add_sum(.clk(clk),.rst(rst),.data_in(add_sum),.data_out(add_sum_q1));
    // DFF #(12) dff_sub_sum(.clk(clk),.rst(rst),.data_in(sub_sum),.data_out(sub_sum_q1));
    // DFF #(24) dff_Adder1_sum_reg(.clk(clk),.rst(rst),.data_in(Adder1_sum_reg),.data_out(Adder1_sum_reg_q1));

    // assign Adder1_sum = (Adder_1_mode == 2'd0) ? {add_sum_1_q1,sub_sum_1_q1} : (Adder_1_mode == 2'd1) ? {sub_sum_q1, add_sum_q1} : Adder1_sum_reg_q1;
    assign Adder1_sum = (Adder_1_mode == 2'd0) ? {add_sum_1,sub_sum_1} : (Adder_1_mode == 2'd1) ? {sub_sum, add_sum} : Adder1_sum_reg;
    //K_2_NTT:(F1+F3*constw,F1-F3*constw)
    //K_4_NTT:(F0-F2*w2,T3*2642+0)
    //K_4_INTT:(F1-F3,F3+F1)     T2 = F3+F1 = Adder1_sum[11:0]    
    //K_2_INTT:(F1+F3,F1-F3)     
    //D_2_NTT:P0 + rH·ωH·2^24+rL·ωH·2^12   

  
endmodule
