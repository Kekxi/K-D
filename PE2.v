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
    wire [23:0] PE2_a0_q1,PE2_a1_q1,PE2_b0_q1,PE2_b1_q1;
    DFF #(24) dff_PE2_a0(.clk(clk),.rst(rst),.data_in(PE2_a0),.data_out(PE2_a0_q1));
    DFF #(24) dff_PE2_a1(.clk(clk),.rst(rst),.data_in(PE2_a1),.data_out(PE2_a1_q1));
    DFF #(24) dff_PE2_b0(.clk(clk),.rst(rst),.data_in(PE2_b0),.data_out(PE2_b0_q1));
    DFF #(24) dff_PE2_b1(.clk(clk),.rst(rst),.data_in(PE2_b1),.data_out(PE2_b1_q1));

    wire [1:0] sel = {sel_1, sel_0 ^ sel_1};

    Adder_3 adder3_0 (.clk(clk),.rst(rst),.Adder3_a(PE2_a0_q1),.Adder3_b(PE2_b0_q1),.Adder_3_mode(KD_mode),.sel_a(sel),.Adder3_sum(adder3_0_out));  
    Adder_4 adder4_0 (.clk(clk),.rst(rst),.Adder4_a(PE2_a1_q1),.Adder4_b(PE2_b1_q1),.Adder_4_mode(KD_mode),.Adder4_sum(adder4_0_out));  

    wire [23:0] adder3_0_out_reg;
    DFF #(24) dff_adder3_0_out(.clk(clk),.rst(rst),.data_in(adder3_0_out),.data_out(adder3_0_out_reg));
    modular_half #(.data_width(24)) half3 (.clk(clk),.rst(rst),.KD_mode(KD_mode),.x_half(adder3_0_out_reg),.y_half(half_out3)); //INTT时用到 注意位宽！
    modular_half #(.data_width(24)) half4 (.clk(clk),.rst(rst),.KD_mode(KD_mode),.x_half(adder4_0_out),.y_half(half_out4)); //INTT时用到 注意位宽！
    //只有INTT时才需要*(1/2) 结果输出需要选择！
    assign PE2_out3 = (sel_1 == 1'b0) ? adder3_0_out_reg : half_out3;
    //K_4_INTT:half_out3 = {T0,T1} = {(F0+F2)*(1/2),(F0-F2)*(1/2)} 
    //D_2_INTT:(F0,F1)+(F2,F3)*(1/2) 此处是最终结果，需要*(1/2)
    assign PE2_out4 = adder4_0_out; 
    //D_2_INTT:(F0,F1)-(F2,F3) = (rH,rL) 此处不需要*(1/2) 
    // wire [11:0] PE2_out3_H,PE2_out3_L,PE2_out4_H,PE2_out4_L;
    // assign PE2_out3_H = PE2_out3[23:12];
    // assign PE2_out3_L = PE2_out3[11:0];
    // assign PE2_out4_H = PE2_out4[23:12];
    // assign PE2_out4_L = PE2_out4[11:0];
    // wire [11:0] half_out3_H = half_out3[23:12];
    // wire [11:0] half_out3_L = half_out3[11:0];
    // wire [11:0] half_out4_H = half_out4[23:12];
    // wire [11:0] half_out4_L = half_out4[11:0];


endmodule


// module PE2(
//     input [23:0] PE2_a0,PE2_b0,PE2_a1,PE2_b1,
//     input [1:0] PE2_Adder_3_mode,PE2_Adder_4_mode,  // 01 23 02 13
//     output [23:0] PE2_out3,PE2_out4
//    );

//     wire [23:0] adder3_0_out,adder4_0_out;
    
//     Adder_3 adder3_0 (.Adder3_a(PE2_a0),.Adder3_b(PE2_b0),.Adder_3_mode(PE2_Adder_3_mode),.Adder3_sum(adder3_0_out));   //01 23
//     Adder_4 adder4_0 (.Adder4_a(PE2_a1),.Adder4_b(PE2_b1),.Adder_4_mode(PE2_Adder_4_mode),.Adder4_sum(adder4_0_out));  // 02 13

//     assign PE2_out3 = adder3_0_out;
//     assign PE2_out4 = adder4_0_out;
       
    
// endmodule

