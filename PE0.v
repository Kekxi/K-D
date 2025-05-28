`timescale 1ns / 1ps
//PE0 先乘后加减/直出（KNTT -- 000  DNTT&DINTT -- 011），先加减后乘（KINTT -- 100） 
module PE0 #(parameter data_width = 24)(
    input clk,rst,
    input sel_0,sel_1,KD_mode,
    input [data_width-1:0] PE0_a,w0,  
    //K_2_NTT:(F0,F2) (1,2642)
    //K_4_NTT:(F1,F3) (w1,w3)
    //K_4_INTT:(T1,T3) (w1,w3)
    //K_2_INTT:(F0,F2) (1,688)
    //D_2_NTT:(F3,F3) (wH,wL)
    //D_2_INTT:(rH,rL) (wL,wL)= (w2,w3)
    output [data_width-1:0] PE0_out
    //K_2_NTT:(F0*1+F2*2642,F0*1-F2*2642)--存到(b0,b2)
    //K_4_NTT:(F1*w1+F3*w3,F1*w1-F3*w3)--(T2,T3)
    //K_4_INTT:PE0_out = {(T1+T3)*w1,(T1-T3)*w3}*(1/2) = (a1,a3)
    //K_2_INTT:PE0_out = {(F0+F2)*1,(F0-F2)*constw^(-1)}*(1/2)--存到(b0,b2)
    //D_2_NTT:PE0_out = F3·ωH·2^12 + F3·ωL = P0
    //D_2_INTT:PE0_out = rH·ωL·2^12 + rL·ωL = P0 
   );

    wire [data_width-1:0] PE0_out_reg;
    wire PE0_sel;
    assign PE0_sel = ~KD_mode & sel_1; //0---K_2_NTT/K_4_NTT/DNTT/DINTT  1---K_2_INTT/K_4_INTT
    wire [data_width-1:0] mul_red0_in,mul_red0_out,adder0_in,adder0_out,w0_in,PE0_a_q1,adder0_out_q1,w0_q1,w0_q8,w0_q6,w0_q4,half_out;

    DFF #(24) dff_PE0_a(.clk(clk),.rst(rst),.data_in(PE0_a),.data_out(PE0_a_q1));
    DFF #(24) dff_w0(.clk(clk),.rst(rst),.data_in(w0),.data_out(w0_q1));
    DFF #(24) dff_adder0_out(.clk(clk),.rst(rst),.data_in(adder0_out),.data_out(adder0_out_q1));
    shift_8 #(.data_width(24)) shf8_w (.clk(clk),.rst(rst),.data_in(w0_q1),.data_out(w0_q8)); //INTT时需要移位
    // shift_6 #(.data_width(24)) shf_w (.clk(clk),.rst(rst),.data_in(w0_q1),.data_out(w0_q6)); //INTT时需要移位
    // shift_4 #(.data_width(24)) shf_w (.clk(clk),.rst(rst),.data_in(w0_q1),.data_out(w0_q4)); //INTT时需要移位


    assign mul_red0_in = (PE0_sel == 1'b0) ? PE0_a_q1 : adder0_out_q1;
    assign w0_in = (sel_1 == 1'b0) ? w0_q1 : w0_q8; //0---NTT 1---INTT
    assign adder0_in = (PE0_sel == 1'b0) ? mul_red0_out : PE0_a_q1;

    wire [1:0] sel = {sel_1, sel_0 ^ sel_1};
    
    mul_Red_0 mul_red0 (.clk(clk),.rst(rst),.A(mul_red0_in),.w(w0_in),.sel_a(sel),.mul_Red_mode(KD_mode),.result(mul_red0_out));
    Adder_0 adder0 (.clk(clk),.rst(rst),.Adder0_a(adder0_in),.sel_a(sel),.Adder_0_mode(KD_mode),.Adder0_sum(adder0_out));
    modular_half #(.data_width(24)) half0 (.clk(clk),.rst(rst),.KD_mode(KD_mode),.x_half(mul_red0_out),.y_half(half_out)); //INTT时能用到 注意位宽！

    assign PE0_out = (PE0_sel == 1'b0) ? adder0_out_q1 : half_out;     
    // DFF #(24) dff_PE0_out_reg(.clk(clk),.rst(rst),.data_in(PE0_out_reg),.data_out(PE0_out));

    wire [11:0] PE0_out_H,PE0_out_L;
    assign PE0_out_H = PE0_out[23:12];
    assign PE0_out_L = PE0_out[11:0];
    wire [11:0] half_out_H = half_out[23:12];
    wire [11:0] half_out_L = half_out[11:0];





endmodule
// `timescale 1ns / 1ps
// //PE0 先乘后加减/直出（KNTT -- 000  DNTT&DINTT -- 011），先加减后乘（KINTT -- 100） 
// module PE0(
//     input [23:0] PE0_a,w0,  
//     input PE0_sel,PE0_mul_Red_mode,PE0_Adder_0_mode,
//     output [23:0] PE0_out
//    );

//     wire [23:0] PE0_product,PE0_sum,PE0_out0,PE0_out1;
//     // 先乘后加减/直出（KNTT -- 000  DNTT&DINTT -- 011）
//     mul_Red_0 mul_red_0_0 (.A(PE0_a),.w(w0),.mul_Red_mode(PE0_mul_Red_mode),.result(PE0_product));
//     Adder_0 adder0_0 (.Adder0_a(PE0_product),.Adder_0_mode(PE0_Adder_0_mode),.Adder0_sum(PE0_out0));
//     // 先加减后乘（KINTT -- 100）
//     Adder_0 adder0_1 (.Adder0_a(PE0_a),.Adder_0_mode(PE0_Adder_0_mode),.Adder0_sum(PE0_sum));
//     mul_Red_0 mul_red_0_1 (.A(PE0_sum),.w(w0),.mul_Red_mode(PE0_mul_Red_mode),.result(PE0_out1));

//     wire [11:0] PE0_out1_H = PE0_out1[23:12]; //a2
//     wire [11:0] PE0_out1_L = PE0_out1[11:0];  //a3
    
//     assign PE0_out = (PE0_sel == 1'b0) ? PE0_out0 : PE0_out1;
       
    
// endmodule