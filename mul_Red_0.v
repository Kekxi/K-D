`timescale 1ns / 1ps

module mul_Red_0 (
    input clk,rst,
    input [23:0] A,         // K_4_INTT:(T1+T3,T1-T3) DINTT时,(F0,F1)-(F2,F3)=  r --- (rH,rL)
    input [23:0] w,         // K_4_INTT:(w1,w3)
    input [1:0] sel_a,
    input sel_D_2_INTT,
    input mul_Red_mode,          // K_redu--0  D_redu--1
    output [23:0] result    // K_4_INTT:{(T1+T3)*w1,(T1-T3)*w3}
);

    // 输入分片
    wire [11:0] A_high_reg = A[23:12]; // K_2_NTT--A_H=F0
    wire [11:0] A_low_reg  = A[11:0];  // K_2_NTT--A_L=F2
    wire [11:0] w_high_reg = w[23:12]; //K_2_NTT--w_H=1
    wire [11:0] w_low_reg  = w[11:0];  //K_2_NTT--w_L=constw=2642
    
    wire [11:0] A_high_reg_shift_1,A_low_reg_shift_1;
    shift_1 #(.data_width(12)) shf1_A_high_reg (.clk(clk),.rst(rst),.data_in(A_high_reg),.data_out(A_high_reg_shift_1)); 
    shift_1 #(.data_width(12)) shf1_A_low_reg (.clk(clk),.rst(rst),.data_in(A_low_reg ),.data_out(A_low_reg_shift_1));

    wire [11:0] A_high = (sel_D_2_INTT == 1'b1) ? A_high_reg_shift_1 : A_high_reg ;
    wire [11:0] A_low = (sel_D_2_INTT == 1'b1) ? A_low_reg_shift_1 : A_low_reg ;



    wire [11:0] w_high_reg_shift_1,w_low_reg_shift_1;
    shift_1 #(.data_width(12)) shf1_w_high_reg (.clk(clk),.rst(rst),.data_in(w_high_reg),.data_out(w_high_reg_shift_1)); 
    shift_1 #(.data_width(12)) shf1_w_low_reg (.clk(clk),.rst(rst),.data_in(w_low_reg ),.data_out(w_low_reg_shift_1));
    
    wire [11:0] w_high = (sel_a == 2'b10) ? w_high_reg_shift_1 : w_high_reg; //  sel_a=2 INTT 
    wire [11:0] w_low = (sel_a == 2'b10) ? w_low_reg_shift_1 : w_low_reg;
   
    // 中间结果
    wire [23:0] product1 = A_high * w_high; // Multiply high 24 bits
    wire [23:0] product0 = A_low * w_low;   // Multiply low 24 bits
    wire [23:0] product1_q1,product0_q1;

    DFF #(24) dff_product1(.clk(clk),.rst(rst),.data_in(product1),.data_out(product1_q1));
    DFF #(24) dff_product2(.clk(clk),.rst(rst),.data_in(product0),.data_out(product0_q1));

    // 乘完的结果拼接
    wire [47:0] data_in = {product1_q1, product0_q1};
    // wire [47:0] data_in_reg_q1;
    // 先把data_in高位左移12bit得到data_in_H(product1),data_in低位data_in_L(product0）也提取出来,然后相加，再约减(PE0)
    wire [35:0] data_in_H = {data_in[47:24],12'b0};
    wire [23:0] data_in_L = data_in[23:0];
    wire[47:0] data_in_reg = data_in_H + data_in_L; //D_2_NTT:F3·ωH·2^12 + F3·ωL (26bit+24bit 存到 48bit 约简成 24bit)
    // DFF #(48) dff_data_in_reg(.clk(clk),.rst(rst),.data_in(data_in_reg),.data_out(data_in_reg_q1));

    //测试变量
    wire [23:0] data_in_reg_H = data_in_reg[23:12];
    wire [23:0] data_in_reg_L = data_in_reg[11:0];


    // 模块实例化 必须在编译时确定，不是运行时;综合器通常能识别这种结构并自动优化未用路径,不会有额外资源浪费
    wire [22:0] mod_result0,mod_result0_q1;  // D_redu 的结果
    wire [11:0] mod_result1, mod_result2,mod_result1_q1,mod_result2_q1; // K_redu 的结果
    D_redu d_redu (.clk(clk),.rst(rst),.data_in(data_in_reg), .result(mod_result0));
    K_redu k_redu0 (.clk(clk),.rst(rst),.data_in(product0_q1), .result(mod_result1));
    K_redu k_redu1 (.clk(clk),.rst(rst),.data_in(product1_q1), .result(mod_result2));

    DFF #(23) dff_d_redu(.clk(clk),.rst(rst),.data_in(mod_result0),.data_out(mod_result0_q1)); //mod_result0_q1--23bit
    DFF #(12) dff_k_redu0(.clk(clk),.rst(rst),.data_in(mod_result1),.data_out(mod_result1_q1));
    DFF #(12) dff_k_redu1(.clk(clk),.rst(rst),.data_in(mod_result2),.data_out(mod_result2_q1));
    // 输出结果
    assign result = (mul_Red_mode == 1'b1) ? {1'b0, mod_result0_q1} : {mod_result2_q1, mod_result1_q1};

    //测试变量
    wire [11:0] mod_result0_q1_H = result[23:12];
    wire [11:0] mod_result0_q1_L = result[11:0];

endmodule

