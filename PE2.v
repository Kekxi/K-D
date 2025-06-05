`timescale 1ns / 1ps
//PE2 12bit加减+12bit加加（KNTT） 12bit加减+24bit减（KINTT） 24bit加+24bit减（DNTT）24bit减+24bit加（DINTT）
module PE2(
    input clk,rst,
    input sel_0,sel_1,KD_mode,
    input [23:0] PE2_a0,PE2_b0,PE2_a1,PE2_b1,
    output [23:0] PE2_out3,PE2_out4
   );
    //Adder3 12bit加减（KNTT） 12bit加减（KINTT）24bit加（DNTT） 24bit减（DINTT）
    //Adder4 12bit加加（KNTT） 24bit减（KINTT） 24bit减（DNTT） 24bit加（DINTT）

    //生成新的信号Adder3_mode,Adder4_mode  可以改善，信号也许只跟KD有关！！！  改后Adder3_mode = Adder4_mode = KD_mode
    // wire [1:0] Adder3_mode,Adder4_mode;
    //assign Adder3_mode = (KD_mode == 0) ? 0 : (sel_1 + 1); 这种可以跟门级比较 看看综合之后 工具自动优化占用资源多少
    //assign Adder4_mode = (KD_mode == 0) ? sel_1 : (sel_1 + 1);
    // assign Adder3_mode = {KD_mode & sel_1, KD_mode & (~sel_1)};//门级
    // assign Adder4_mode = {sel_1 & KD_mode, sel_1 ^ KD_mode};
    
    wire [23:0] adder3_0_out,adder4_0_out,half_out3,half_out4;


   
    //------------------------------------------------------------------------------------
    //改动 
    // wire [23:0] PE2_a0_q1,PE2_a1_q1,PE2_b0_q1,PE2_b1_q1;
    // DFF #(24) dff_PE2_a0(.clk(clk),.rst(rst),.data_in(PE2_a0),.data_out(PE2_a0_q1));
    // DFF #(24) dff_PE2_a1(.clk(clk),.rst(rst),.data_in(PE2_a1),.data_out(PE2_a1_q1));
    // DFF #(24) dff_PE2_b0(.clk(clk),.rst(rst),.data_in(PE2_b0),.data_out(PE2_b0_q1));
    // DFF #(24) dff_PE2_b1(.clk(clk),.rst(rst),.data_in(PE2_b1),.data_out(PE2_b1_q1));

    // wire [1:0] sel = {sel_1, sel_0 ^ sel_1};
    wire sel_K_4_NTT = sel_0 & ~KD_mode & ~sel_1; //1--K_4_NTT 0--其他 
    wire sel_D_2_NTT = ~sel_0 & KD_mode & ~sel_1; //1--D_2_NTT 0--其他
    wire sel_D_2_INTT = ~sel_0 & KD_mode & sel_1; //1--D_2_INTT 0--其他


    Adder_2 adder3_0 (.clk(clk),.rst(rst),.Adder2_a(PE2_a0),.Adder2_b(PE2_b0),.KD_mode(KD_mode),.sel_K_4_NTT(sel_K_4_NTT),.sel_D_2_NTT(sel_D_2_NTT),.PE2_sel(1),.Adder2_sum(adder3_0_out));  
    Adder_2 adder4_0 (.clk(clk),.rst(rst),.Adder2_a(PE2_a1),.Adder2_b(PE2_b1),.KD_mode(KD_mode),.sel_K_4_NTT(sel_K_4_NTT),.sel_D_2_NTT(sel_D_2_NTT),.PE2_sel(0),.Adder2_sum(adder4_0_out));  

    wire [23:0] adder3_0_out_reg,adder4_0_out_reg;
    DFF #(24) dff_adder3_0_out(.clk(clk),.rst(rst),.data_in(adder3_0_out),.data_out(adder3_0_out_reg));
    DFF #(24) dff_adder4_0_out(.clk(clk),.rst(rst),.data_in(adder4_0_out),.data_out(adder4_0_out_reg));

    //后面可能需要给half_out4和adder4_0_out进行DFF！注意！

    modular_half #(.data_width(24)) half3 (.clk(clk),.rst(rst),.KD_mode(KD_mode),.x_half(adder3_0_out_reg),.y_half(half_out3)); //INTT时用到 注意位宽！
    // modular_half #(.data_width(24)) half4 (.clk(clk),.rst(rst),.KD_mode(KD_mode),.x_half(adder4_0_out_reg),.y_half(half_out4)); //INTT时用到 但全为0输入 没有用
    //只有INTT时才需要*(1/2) 结果输出需要选择！

    wire [23:0] half_out3_shift_6;
    shift_6 #(.data_width(24)) shf6_half_out3 (.clk(clk),.rst(rst),.data_in(half_out3),.data_out(half_out3_shift_6)); 
    wire [23:0] half_out3_reg = (sel_D_2_INTT == 1'b1) ? half_out3_shift_6 : half_out3;

    assign PE2_out3 = (sel_1 == 1'b0) ? adder3_0_out_reg : half_out3_reg;
    //K_4_INTT:half_out3 = {T0,T1} = {(F0+F2)*(1/2),(F0-F2)*(1/2)} 
    //D_2_INTT:(F0,F1)+(F2,F3)*(1/2) 此处是最终结果，需要*(1/2)
    assign PE2_out4 = adder4_0_out_reg; 
    //D_2_INTT:(F0,F1)-(F2,F3) = (rH,rL) 此处不需要*(1/2) 

    wire [11:0] PE2_out3_H,PE2_out3_L,PE2_out4_H,PE2_out4_L;
    assign PE2_out3_H = PE2_out3[23:12];
    assign PE2_out3_L = PE2_out3[11:0];
    assign PE2_out4_H = PE2_out4[23:12];
    assign PE2_out4_L = PE2_out4[11:0];
    wire [11:0] half_out3_H = half_out3_reg[23:12];
    wire [11:0] half_out3_L = half_out3_reg[11:0];
    // wire [11:0] half_out4_H = half_out4[23:12];
    // wire [11:0] half_out4_L = half_out4[11:0];


endmodule

