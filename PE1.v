`timescale 1ns / 1ps
//PE1 先乘后同步加减2次（KNTT -- 0,0,00,00 ；DNTT&DINTT -- 0,1,10,10 & 0,1,01,01），先加减再加减后乘（KINTT -- 1,0,00,00） 
module PE1(
    input clk,rst,
    input sel_0,sel_1,KD_mode, //sel_0用于求Adder的mode
    input [23:0] PE1_a,PE1_b,w1, 
    //K_2_NTT:(F1,F3) 24'b0 (12'b1,constω = 2642)
    //K_4_NTT:(F2,T3) (F0,12b´0) (w2,1821)   w(4,1) = 1821
    //K_4_INTT:(F1,F3) (T0,T0) (317,w2)      w(4,-1) = 317
    //K_2_INTT:(F1,F3) 24'b0 (12'b1,constω^(-1) = 687)
    //D_2_NTT:(F2,F2) P0 (wH,wL)
    //D_2_INTT:(rH,rL) P0 (wH,wH)

    output [23:0] PE1_out1,PE1_out2
    //K_2_NTT:PE1_a=(F1*1+F3*2642,F1*1-F3*2642)--存到(b1,b3) PE1_b=0
    //K_4_NTT:PE1_out1=(T3*2642+0,F0-F2*w2) PE1_out2=(F0+F2*w2,0-T3*2642)
    //K_4_INTT:PE1_out1=(T3,a2)*(1/2)={(F1-F3)*687,(T0-T2)*w2}*(1/2)       PE1_out2=(a0,T2)*(1/2)=(T0+T2,F1+F3)*(1/2)
    //K_2_INTT:PE1_out1 = {(F1+F3)*1*(1/2),(F1-F3)*constω^(-1)*(1/2)}
    //D_2_NTT:PE1_out1 = P0 + F2·ωH·2^24 + F2·ωL·2^12 = Q0 
    //D_2_INTT:PE1_out1 = P0 + rH·ωH·2^24 + rL·ωH·2^12 = Q0 
   );
    wire [23:0] PE1_a,PE1_b_q1,w1_q,w1_q1,w1_q2,PE1_a_0,PE1_a_1,P,P1,P0,mul_red1_out;
    wire [23:0] mul_red1_in,adder1_a_in,adder1_b_in,adder2_a_in,adder2_b_in,w1_in,adder0_in,adder1_out,adder2_out,PE1_out1_reg;

    wire PE1_sel;
    assign PE1_sel = ~KD_mode & sel_1; //0---K_2_NTT/K_4_NTT/DNTT/DINTT  1---K_2_INTT/K_4_INTT
    //---------------------------------------------------------------------------------------------------------------------------------------------------
    //改动 PE0输出时已经DFF一次了 下一步是送入PE1计算 PE1没有必要在输入时再DFF一次吧，多余了？ 此处将所有PE1_a_q1替换PE1_a PE1_b_q1 替换PE1_b w1_q1替换w1
    //而且PE1进来数据后再传到Adder或者mul_red中计算前，在Adder或者mul_red中也DFF了
    // DFF #(24) dff_PE1_a(.clk(clk),.rst(rst),.data_in(PE1_a),.data_out(PE1_a_q1));
    // DFF #(24) dff_PE1_b(.clk(clk),.rst(rst),.data_in(PE1_b),.data_out(PE1_b_q1));
    // DFF #(24) dff_w1(.clk(clk),.rst(rst),.data_in(w1),.data_out(w1_q1));


    // shift_1 #(.data_width(24)) shf_w1 (.clk(clk),.rst(rst),.data_in(w1_q),.data_out(w1_q1)); //NTT时需要移位
    // shift_7 #(.data_width(24)) shf_w7 (.clk(clk),.rst(rst),.data_in(w1_q1),.data_out(w1_q7)); //INTT时需要移位
    shift_2 #(.data_width(24)) shf_w2 (.clk(clk),.rst(rst),.data_in(w1),.data_out(w1_q2)); //INTT时需要移位

    // PE1_sel = 1 时的拼接操作  需要DFF吗？？
    assign PE1_a_0 = {PE1_a[11:0],PE1_a[11:0]}; //(F3,F3)
    assign PE1_a_1 = {PE1_a[23:12],PE1_a[23:12]};//(F1,F1)
    
    // wire [11:0] PE1_a_0_H = PE1_a_0[23:12];
    // wire [11:0] PE1_a_0_L = PE1_a_0[11:0];
    // wire [11:0] PE1_a_1_H = PE1_a_1[23:12];
    // wire [11:0] PE1_a_1_L = PE1_a_1[11:0];

    assign P = {adder1_out_q1[11:0],adder1_out_q1[11:0]}; //Adder1输出的的低12位！ K_4_INTT:{T2,T2} T2 = F1 + F3  K_2_INTT:{F1-F3,F1-F3}
    assign P0 = {adder1_out_q1[23:12],adder2_out_q1[11:0]}; //K_4_INTT:{(F1 - F3)，(T0 - T2)} 送到乘法器计算 K_2_INTT:{F1+F3,F1-F3}

    //-----------------------------------------------------------------------------

    assign P1 = (sel == 2'b10)  ? {P1_H,P1_L_shift_1} : {P1_H,P1_L}; //K_4_INTT:{(T0 + T2),(F1 + F3)} 作为PE1的1个输出--{a0,T2}
    
    // ------------------------------------------------------------------------------
    wire [11:0] P_H = P[23:12];
    wire [11:0] P_L = P[11:0];
    wire [11:0] P1_H = adder2_out_q1[23:12];
    wire [11:0] P1_L = adder1_out_q1[11:0];

    wire [11:0] P1_L_shift_1,half_out2_H_shift_8,half_out1_L_shift_6;
    shift_1 #(.data_width(12)) shf1_P1_L (.clk(clk),.rst(rst),.data_in(P1_L),.data_out(P1_L_shift_1)); //K_4_INTT时需要移位

    // wire [11:0] half_out2_H = half_out2[23:12];
    // wire [11:0] half_out1_L = half_out1[11:0];

    // wire [11:0] half_out2_L = half_out2[11:0];//tb
    // wire [11:0] half_out1_H = half_out1[23:12];//tb
     
    // shift_8 #(.data_width(12)) shf8_half_out2_H (.clk(clk),.rst(rst),.data_in(half_out2_H),.data_out(half_out2_H_shift_8)); //K_4_INTT时需要移位
    // shift_6 #(.data_width(12)) shf6_half_out1_L (.clk(clk),.rst(rst),.data_in(half_out1_L),.data_out(half_out1_L_shift_6)); //K_4_INTT时需要移位
    // assign half_out2_reg = (sel == 2'b10)  ? {half_out2_H_shift_8,half_out2[11:0]} : half_out2;
    // assign half_out1_reg = (sel == 2'b10)  ? {half_out1[23:12],half_out1_L_shift_6} : half_out1;
    //-----------------------------------------------------------------------------------

    assign mul_red1_in = (PE1_sel == 1'b0) ? PE1_a : P0;
    assign adder1_a_in = (PE1_sel == 1'b0) ? mul_red1_out : PE1_a_0;
    assign adder1_b_in = (PE1_sel == 1'b0) ? PE1_b : PE1_a_1;
    assign adder2_a_in = (PE1_sel == 1'b0) ? PE1_b : PE1_b; //一样的？！
    assign adder2_b_in = (PE1_sel == 1'b0) ? mul_red1_out : P;
    assign w1_in = (sel_1 == 1'b0) ? w1 : w1_q2; //0---NTT 1---INTT 

    wire [1:0] Adder1_2_mode;
    assign Adder1_2_mode = KD_mode ? 2 : sel_0;

    wire [1:0] sel = {sel_1, sel_0 ^ sel_1};

    mul_Red_1 mul_red1 (.clk(clk),.rst(rst),.A(mul_red1_in),.w(w1_in),.mul_Red_mode(KD_mode),.sel_a(sel),.result(mul_red1_out)); //mul_red1_out需要DFF吗？
    modular_half #(.data_width(24)) half1 (.clk(clk),.rst(rst),.KD_mode(KD_mode),.x_half(mul_red1_out),.y_half(half_out1)); //INTT时能用到 注意位宽！
    modular_half #(.data_width(24)) half2 (.clk(clk),.rst(rst),.KD_mode(KD_mode),.x_half(P1),.y_half(half_out2)); //K_4_INTT时能用到 注意位宽！
    Adder_1 adder1 (.clk(clk),.rst(rst),.Adder1_a(adder1_a_in),.Adder1_b(adder1_b_in),.sel_1(sel_1),.Adder_1_mode(Adder1_2_mode),.Adder1_sum(adder1_out)); 
    modular_half #(.data_width(24)) half_DINTT (.clk(clk),.rst(rst),.KD_mode(KD_mode),.x_half(adder1_out),.y_half(half_out_DINTT)); //DINTT 特殊处理
    Adder_2 adder2 (.clk(clk),.rst(rst),.Adder2_a(adder2_a_in),.Adder2_b(adder2_b_in),.Adder_2_mode(Adder1_2_mode),.sel_a(sel),.Adder2_sum(adder2_out));

    wire [23:0] adder1_out_q1,adder2_out_q1,half_out1,half_out1_q1,half_out2,half_out2_q14,half_out_DINTT,half_out_DINTT_q1;
    DFF #(24) dff_adder1_out(.clk(clk),.rst(rst),.data_in(adder1_out),.data_out(adder1_out_q1));
    DFF #(24) dff_adder2_out(.clk(clk),.rst(rst),.data_in(adder2_out),.data_out(adder2_out_q1));
    DFF #(24) dff_half_out1(.clk(clk),.rst(rst),.data_in(half_out1),.data_out(half_out1_q1));
    shift_14 #(24) shift14_half_out2(.clk(clk),.rst(rst),.data_in(half_out2),.data_out(half_out2_q14));
    DFF #(24) dff_half_out_DINTT(.clk(clk),.rst(rst),.data_in(half_out_DINTT),.data_out(half_out_DINTT_q1));
   
  
   wire [11:0] half_out1_q1_H = half_out1_q1[23:12];
   wire [11:0] half_out1_q1_L = half_out1_q1[11:0];
   wire [11:0] half_out1_q1_L_q7;
   shift_7 #(24) shift7_half_out1_q1_L(.clk(clk),.rst(rst),.data_in(half_out1_q1_L),.data_out(half_out1_q1_L_q7));
   wire [23:0] half_out1_q1_reg = {half_out1_q1_H,half_out1_q1_L_q7};
   
   //K_2 时，只有adder1_out_q1算出来的是有效值，送回bank的值 adder2_out_q1算的结果无效
    assign PE1_out1_reg = (PE1_sel == 1'b0) ? adder1_out_q1 : half_out1_q1_reg;
    assign PE1_out1 = (KD_mode & sel_1) ? half_out_DINTT_q1 : PE1_out1_reg;
    assign PE1_out2 = (PE1_sel == 1'b0) ? adder2_out_q1 : half_out2_q14;

    wire [11:0] PE1_out1_H,PE1_out1_L,PE1_out2_H,PE1_out2_L;
    assign PE1_out1_H = PE1_out1[23:12];
    assign PE1_out1_L = PE1_out1[11:0];
    assign PE1_out2_H = PE1_out2[23:12];
    assign PE1_out2_L = PE1_out2[11:0];

endmodule
