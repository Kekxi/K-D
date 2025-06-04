`timescale 1ns / 1ps
module mul_Red_0 (
    input clk,rst,
    input [23:0] A,         // K_4_INTT:(T1+T3,T1-T3) DINTT时,(F0,F1)-(F2,F3)=  r --- (rH,rL)
    input [23:0] w,         // K_4_INTT:(w1,w3)
    input [1:0] sel_PE0,
    input [1:0] sel_PE1,
    input sel_D_2_INTT,
    input sel_K_4_NTT,
    input mul_Red_mode,          // K_redu--0  D_redu--1
    input PE_sel, //新增信号 区分PE0 PE1实例化次此模块

    output [23:0] result    // K_4_INTT:{(T1+T3)*w1,(T1-T3)*w3}
 );
    // 输入分片
    wire [11:0] A_high_reg = A[23:12]; // K_2_NTT--A_H=F0
    wire [11:0] A_low_reg  = A[11:0];  // K_2_NTT--A_L=F2
    wire [11:0] w_high_reg = w[23:12]; //K_2_NTT--w_H=1
    wire [11:0] w_low_reg  = w[11:0];  //K_2_NTT--w_L=constw=2642
    //移位寄存
    wire [11:0] A_high_reg_shift_1,A_low_reg_shift_1,w_high_reg_shift_1,w_low_reg_shift_1;
    shift_1 #(.data_width(12)) shf1_A_high_reg (.clk(clk),.rst(rst),.data_in(A_high_reg),.data_out(A_high_reg_shift_1)); 
    shift_1 #(.data_width(12)) shf1_A_low_reg (.clk(clk),.rst(rst),.data_in(A_low_reg ),.data_out(A_low_reg_shift_1));
    shift_1 #(.data_width(12)) shf1_w_high_reg (.clk(clk),.rst(rst),.data_in(w_high_reg),.data_out(w_high_reg_shift_1)); 
    shift_1 #(.data_width(12)) shf1_w_low_reg (.clk(clk),.rst(rst),.data_in(w_low_reg ),.data_out(w_low_reg_shift_1));
    wire [11:0] A_high_reg_shift_7,w_high_reg_shift_7;
    shift_7 #(.data_width(12)) shf7_A_high_reg (.clk(clk),.rst(rst),.data_in(A_high_reg),.data_out(A_high_reg_shift_7)); 
    shift_7 #(.data_width(12)) shf7_w_high_reg (.clk(clk),.rst(rst),.data_in(w_high_reg),.data_out(w_high_reg_shift_7));

    wire [11:0] A_high = (PE_sel == 1'b0) ? 
                          ((sel_D_2_INTT == 1'b1) ? A_high_reg_shift_1 : A_high_reg) : 
                          ((sel_PE1 == 2'b1) ? A_high_reg_shift_7 : (sel_PE1 == 2'b10) ? A_high_reg_shift_1 : A_high_reg);

    wire [11:0] A_low = (sel_D_2_INTT == 1'b1) ? A_low_reg_shift_1 : A_low_reg;

    wire [11:0] w_high = (PE_sel == 1'b0) ? 
                          ((sel_PE0 == 2'b10) ? w_high_reg_shift_1 : w_high_reg) : 
                          ((sel_K_4_NTT == 1'b1) ? w_high_reg_shift_7 : w_high_reg);
                          
    wire [11:0] w_low = (PE_sel == 1'b0) ? 
                          ((sel_PE0 == 2'b10) ? w_low_reg_shift_1 : w_low_reg) : 
                          w_low_reg;


    // 中间结果
    wire [23:0] product1 = A_high * w_high; // Multiply high 24 bits
    wire [23:0] product0 = A_low * w_low;   // Multiply low 24 bits

    wire [23:0] product1_q1,product0_q1;
    DFF #(24) dff_product1(.clk(clk),.rst(rst),.data_in(product1),.data_out(product1_q1));
    DFF #(24) dff_product2(.clk(clk),.rst(rst),.data_in(product0),.data_out(product0_q1));

    // 乘完的结果拼接
    wire [47:0] data_in = {product1_q1, product0_q1};


    //-----------------------------------------------------------------------------------------
    //D_2_NTT     PE顺序 PE0-->PE1-->PE2  mul_red_0结果需要移位寄存 等PE1计算时用到
    //D_2_INTT    PE顺序 PE2-->PE1-->PE0
    //-----------------------------------------------------------------------------------------

    //PE_sel 选一下 PE0时,PE_sel=0;
    wire [35:0] data_in_H = (PE_sel == 1'b0) ? {product1_q1,12'b0} : {product1_q1,24'b0};
    wire [23:0] data_in_L = (PE_sel == 1'b0) ? product0_q1 : {product0_q1,12'b0};
    wire[47:0] data_in_reg = data_in_H + data_in_L;
    //约简
    wire [11:0] mod_result1,mod_result2,mod_result1_q1,mod_result2_q1; // K_redu 的结果
    K_redu k_redu0 (.clk(clk),.rst(rst),.data_in(product0_q1), .result(mod_result1));
    K_redu k_redu1 (.clk(clk),.rst(rst),.data_in(product1_q1), .result(mod_result2));
    DFF #(12) dff_k_redu0(.clk(clk),.rst(rst),.data_in(mod_result1),.data_out(mod_result1_q1));
    DFF #(12) dff_k_redu1(.clk(clk),.rst(rst),.data_in(mod_result2),.data_out(mod_result2_q1));

    wire [22:0] mod_result0,mod_result0_q1;  // D_redu 的结果
    D_redu d_redu (.clk(clk),.rst(rst),.data_in(data_in_reg), .result(mod_result0));
    DFF #(23) dff_d_redu(.clk(clk),.rst(rst),.data_in(mod_result0),.data_out(mod_result0_q1));

    assign result = (mul_Red_mode == 1'b1) ? {1'b0, mod_result0_q1} : {mod_result2_q1, mod_result1_q1};

endmodule

// module mul_Red_0 (
//     input clk,rst,
//     input [23:0] A,         // K_4_INTT:(T1+T3,T1-T3) DINTT时,(F0,F1)-(F2,F3)=  r --- (rH,rL)
//     input [23:0] w,         // K_4_INTT:(w1,w3)
//     input [1:0] sel_a,
//     input sel_D_2_INTT,
//     input sel_K_4_NTT,
//     input mul_Red_mode,          // K_redu--0  D_redu--1

//     input PE_sel, //新增信号 区分PE0 PE1实例化次此模块

//     output [23:0] result    // K_4_INTT:{(T1+T3)*w1,(T1-T3)*w3}
//  );
//     // 输入分片
//     wire [11:0] A_high_reg = A[23:12]; // K_2_NTT--A_H=F0
//     wire [11:0] A_low_reg  = A[11:0];  // K_2_NTT--A_L=F2
//     wire [11:0] w_high_reg = w[23:12]; //K_2_NTT--w_H=1
//     wire [11:0] w_low_reg  = w[11:0];  //K_2_NTT--w_L=constw=2642
//     //移位寄存
//     wire [11:0] A_high_reg_shift_1,A_low_reg_shift_1,w_high_reg_shift_1,w_low_reg_shift_1;
//     shift_1 #(.data_width(12)) shf1_A_high_reg (.clk(clk),.rst(rst),.data_in(A_high_reg),.data_out(A_high_reg_shift_1)); 
//     shift_1 #(.data_width(12)) shf1_A_low_reg (.clk(clk),.rst(rst),.data_in(A_low_reg ),.data_out(A_low_reg_shift_1));
//     shift_1 #(.data_width(12)) shf1_w_high_reg (.clk(clk),.rst(rst),.data_in(w_high_reg),.data_out(w_high_reg_shift_1)); 
//     shift_1 #(.data_width(12)) shf1_w_low_reg (.clk(clk),.rst(rst),.data_in(w_low_reg ),.data_out(w_low_reg_shift_1));
//     wire [11:0] A_high_reg_shift_7,w_high_reg_shift_7;
//     shift_7 #(.data_width(12)) shf7_A_high_reg (.clk(clk),.rst(rst),.data_in(A_high_reg),.data_out(A_high_reg_shift_7)); 
//     shift_7 #(.data_width(12)) shf7_w_high_reg (.clk(clk),.rst(rst),.data_in(w_high_reg),.data_out(w_high_reg_shift_7));

//     wire [11:0] A_high = (PE_sel == 1'b0) ? 
//                           ((sel_D_2_INTT == 1'b1) ? A_high_reg_shift_1 : A_high_reg) : 
//                           ((sel_a == 2'b1) ? A_high_reg_shift_7 : (sel_a == 2'b10) ? A_high_reg_shift_1 : A_high_reg);
//     wire [11:0] A_low = (sel_D_2_INTT == 1'b1) ? A_low_reg_shift_1 : A_low_reg;
//     wire [11:0] w_high = (PE_sel == 1'b0) ? 
//                           ((sel_a == 2'b10) ? w_high_reg_shift_1 : w_high_reg) : 
//                           ((sel_K_4_NTT == 1'b1) ? w_high_reg_shift_7 : w_high_reg);
//     wire [11:0] w_low = (PE_sel == 1'b0) ? 
//                           ((sel_a == 2'b10) ? w_low_reg_shift_1 : w_low_reg) : 
//                           w_low_reg;


//     // //mul_red_0
//     // wire [11:0] A_high_reg_shift_1,A_low_reg_shift_1,w_high_reg_shift_1,w_low_reg_shift_1;
//     // shift_1 #(.data_width(12)) shf1_A_high_reg (.clk(clk),.rst(rst),.data_in(A_high_reg),.data_out(A_high_reg_shift_1)); 
//     // shift_1 #(.data_width(12)) shf1_A_low_reg (.clk(clk),.rst(rst),.data_in(A_low_reg ),.data_out(A_low_reg_shift_1));
//     // shift_1 #(.data_width(12)) shf1_w_high_reg (.clk(clk),.rst(rst),.data_in(w_high_reg),.data_out(w_high_reg_shift_1)); 
//     // shift_1 #(.data_width(12)) shf1_w_low_reg (.clk(clk),.rst(rst),.data_in(w_low_reg ),.data_out(w_low_reg_shift_1));
    
//     // wire [11:0] A_high = (sel_D_2_INTT == 1'b1) ? A_high_reg_shift_1 : A_high_reg ;
//     // wire [11:0] A_low = (sel_D_2_INTT == 1'b1) ? A_low_reg_shift_1 : A_low_reg ;
//     // wire [11:0] w_high = (sel_a == 2'b10) ? w_high_reg_shift_1 : w_high_reg; //  sel_a=2 INTT 
//     // wire [11:0] w_low = (sel_a == 2'b10) ? w_low_reg_shift_1 : w_low_reg;

//     // //mul_red_1
//     // wire [11:0] A_high_reg_shift_7,w_high_reg_shift_7,A_high_reg_shift_1,A_low_reg_shift_1;
//     // shift_7 #(.data_width(12)) shf7_A_high_reg (.clk(clk),.rst(rst),.data_in(A_high_reg),.data_out(A_high_reg_shift_7)); 
//     // shift_7 #(.data_width(12)) shf7_w_high_reg (.clk(clk),.rst(rst),.data_in(w_high_reg),.data_out(w_high_reg_shift_7));
//     // shift_1 #(.data_width(12)) shf_A_high_reg (.clk(clk),.rst(rst),.data_in(A_high_reg),.data_out(A_high_reg_shift_1)); //K_4_INTT shift2
//     // shift_1 #(.data_width(12)) shf_A_low_reg (.clk(clk),.rst(rst),.data_in(A_low_reg),.data_out(A_low_reg_shift_1));
//     // //sel_a   1--K_4_NTT      2--K_4_INTT/D_2_INTT        0--K_2_NTT/K_2_INTT/D_2_NTT           
//     // wire [11:0] A_high = (sel_a == 2'b1) ? A_high_reg_shift_7 : (sel_a == 2'b10) ? A_high_reg_shift_1 : A_high_reg; 
//     // wire [11:0] A_low = (sel_D_2_INTT == 1'b1) ? A_low_reg_shift_1 : A_low_reg;
//     // wire [11:0] w_high = (sel_K_4_NTT == 1'b1) ? w_high_reg_shift_7 : w_high_reg; //1--K_4_NTT 0--其他
//     // wire [11:0] w_low = w_low_reg;

//     // 中间结果
//     wire [23:0] product1 = A_high * w_high; // Multiply high 24 bits
//     wire [23:0] product0 = A_low * w_low;   // Multiply low 24 bits

//     wire [23:0] product1_q1,product0_q1;
//     DFF #(24) dff_product1(.clk(clk),.rst(rst),.data_in(product1),.data_out(product1_q1));
//     DFF #(24) dff_product2(.clk(clk),.rst(rst),.data_in(product0),.data_out(product0_q1));

//     // 乘完的结果拼接
//     wire [47:0] data_in = {product1_q1, product0_q1};
//     //-----------------------------------------------------------------------------------------
//     //D_2_NTT     PE顺序 PE0-->PE1-->PE2  mul_red_0结果需要移位寄存 等PE1计算时用到
//     //D_2_INTT    PE顺序 PE2-->PE1-->PE0
//     //-----------------------------------------------------------------------------------------

//     //PE_sel 选一下 PE0时,PE_sel=0;
//     wire [35:0] data_in_H = (PE_sel == 1'b0) ? {product1_q1,12'b0} : {product1_q1,24'b0};
//     wire [23:0] data_in_L = (PE_sel == 1'b0) ? product0_q1 : {product0_q1,12'b0};
//     wire[47:0] data_in_reg = data_in_H + data_in_L;

//     wire [11:0] mod_result1,mod_result2,mod_result1_q1,mod_result2_q1; // K_redu 的结果
//     K_redu k_redu0 (.clk(clk),.rst(rst),.data_in(product0_q1), .result(mod_result1));
//     K_redu k_redu1 (.clk(clk),.rst(rst),.data_in(product1_q1), .result(mod_result2));
//     DFF #(12) dff_k_redu0(.clk(clk),.rst(rst),.data_in(mod_result1),.data_out(mod_result1_q1));
//     DFF #(12) dff_k_redu1(.clk(clk),.rst(rst),.data_in(mod_result2),.data_out(mod_result2_q1));

//     wire [22:0] mod_result0,mod_result0_q1;  // D_redu 的结果
//     D_redu d_redu (.clk(clk),.rst(rst),.data_in(data_in_reg), .result(mod_result0));
//     DFF #(23) dff_d_redu(.clk(clk),.rst(rst),.data_in(mod_result0),.data_out(mod_result0_q1));

//     assign result = (mul_Red_mode == 1'b1) ? {1'b0, mod_result0_q1} : {mod_result2_q1, mod_result1_q1};

     


//     // //Dilithium时，PE0 用
//     // // 先把data_in高位左移12bit得到data_in_H(product1),data_in低位data_in_L(product0）也提取出来,然后相加，再约减(PE0)
//     // wire [35:0] data_in_H = {product1_q1,12'b0};
//     // wire [23:0] data_in_L =  product0_q1;
//     // wire[47:0] data_in_reg = data_in_H + data_in_L; //D_2_NTT:F3·ωH·2^12 + F3·ωL (26bit+24bit 存到 48bit 约简成 24bit)

//     // //Dilithium时，PE1 用
//     // // 先把data_in高位左移12bit得到data_in_H(product1),data_in低位data_in_L(product0）也提取出来,然后相加，再约减(PE1)
//     // wire [47:0] data_in_H = {product1_q1,24'b0};
//     // wire [35:0] data_in_L = {product0_q1,12'b0};
//     // wire[47:0] data_in_reg = data_in_H + data_in_L; //此处加完直接去模约简 相当于在乘法模块里做了模加

//     //PE0-----------------------
//     // 模块实例化 必须在编译时确定，不是运行时;综合器通常能识别这种结构并自动优化未用路径,不会有额外资源浪费
//     // wire [22:0] mod_result0,mod_result0_q1;  // D_redu 的结果
//     // wire [11:0] mod_result1,mod_result2,mod_result1_q1,mod_result2_q1; // K_redu 的结果
//     // D_redu d_redu (.clk(clk),.rst(rst),.data_in(data_in_reg), .result(mod_result0));
//     // K_redu k_redu0 (.clk(clk),.rst(rst),.data_in(product0_q1), .result(mod_result1));
//     // K_redu k_redu1 (.clk(clk),.rst(rst),.data_in(product1_q1), .result(mod_result2));

//     // DFF #(23) dff_d_redu(.clk(clk),.rst(rst),.data_in(mod_result0),.data_out(mod_result0_q1)); //mod_result0_q1--23bit
//     // DFF #(12) dff_k_redu0(.clk(clk),.rst(rst),.data_in(mod_result1),.data_out(mod_result1_q1));
//     // DFF #(12) dff_k_redu1(.clk(clk),.rst(rst),.data_in(mod_result2),.data_out(mod_result2_q1));
//     // // 输出结果
//     // assign result = (mul_Red_mode == 1'b1) ? {1'b0, mod_result0_q1} : {mod_result2_q1, mod_result1_q1};
//     // //PE1-----------------------
//     // wire [22:0] mod_result0;  // 要和D_red中的result保持一致23bit
//     // wire [11:0] mod_result1,mod_result2;
//     // D_redu d_redu (.clk(clk),.rst(rst),.data_in(data_in_reg),.result(mod_result0));
//     // //Kyber  12bit低位 
//     // K_redu k_redu0 (.clk(clk),.rst(rst),.data_in(product0_q1),.result(mod_result1));
//     // //Kyber  12bit高位    
//     // K_redu k_redu1 (.clk(clk),.rst(rst),.data_in(product1_q1),.result(mod_result2));

//     // wire [22:0] mod_result0_q1; 
//     // wire [11:0] mod_result1_q1,mod_result2_q1;
//     // DFF #(23) dff_d_redu(.clk(clk),.rst(rst),.data_in(mod_result0),.data_out(mod_result0_q1)); //mod_result0_q1--23bit
//     // DFF #(12) dff_k_redu0(.clk(clk),.rst(rst),.data_in(mod_result1),.data_out(mod_result1_q1));
//     // DFF #(12) dff_k_redu1(.clk(clk),.rst(rst),.data_in(mod_result2),.data_out(mod_result2_q1));

//     // assign result = (mul_Red_mode == 1'b1) ? {1'b0,mod_result0_q1} : {mod_result2_q1,mod_result1_q1}; 

// endmodule
// module mul_Red_0 (
//     input clk,rst,
//     input [23:0] A,         // K_4_INTT:(T1+T3,T1-T3) DINTT时,(F0,F1)-(F2,F3)=  r --- (rH,rL)
//     input [23:0] w,         // K_4_INTT:(w1,w3)
//     input [1:0] sel_a,
//     input sel_D_2_INTT,
//     input mul_Red_mode,          // K_redu--0  D_redu--1
//     output [23:0] result    // K_4_INTT:{(T1+T3)*w1,(T1-T3)*w3}
//  );

//     // 输入分片
//     wire [11:0] A_high_reg = A[23:12]; // K_2_NTT--A_H=F0
//     wire [11:0] A_low_reg  = A[11:0];  // K_2_NTT--A_L=F2
//     wire [11:0] w_high_reg = w[23:12]; //K_2_NTT--w_H=1
//     wire [11:0] w_low_reg  = w[11:0];  //K_2_NTT--w_L=constw=2642
    
//     wire [11:0] A_high_reg_shift_1,A_low_reg_shift_1;
//     shift_1 #(.data_width(12)) shf1_A_high_reg (.clk(clk),.rst(rst),.data_in(A_high_reg),.data_out(A_high_reg_shift_1)); 
//     shift_1 #(.data_width(12)) shf1_A_low_reg (.clk(clk),.rst(rst),.data_in(A_low_reg ),.data_out(A_low_reg_shift_1));

//     wire [11:0] A_high = (sel_D_2_INTT == 1'b1) ? A_high_reg_shift_1 : A_high_reg ;
//     wire [11:0] A_low = (sel_D_2_INTT == 1'b1) ? A_low_reg_shift_1 : A_low_reg ;



//     wire [11:0] w_high_reg_shift_1,w_low_reg_shift_1;
//     shift_1 #(.data_width(12)) shf1_w_high_reg (.clk(clk),.rst(rst),.data_in(w_high_reg),.data_out(w_high_reg_shift_1)); 
//     shift_1 #(.data_width(12)) shf1_w_low_reg (.clk(clk),.rst(rst),.data_in(w_low_reg ),.data_out(w_low_reg_shift_1));
    
//     wire [11:0] w_high = (sel_a == 2'b10) ? w_high_reg_shift_1 : w_high_reg; //  sel_a=2 INTT 
//     wire [11:0] w_low = (sel_a == 2'b10) ? w_low_reg_shift_1 : w_low_reg;
   
//     // 中间结果
//     wire [23:0] product1 = A_high * w_high; // Multiply high 24 bits
//     wire [23:0] product0 = A_low * w_low;   // Multiply low 24 bits
//     wire [23:0] product1_q1,product0_q1;

//     DFF #(24) dff_product1(.clk(clk),.rst(rst),.data_in(product1),.data_out(product1_q1));
//     DFF #(24) dff_product2(.clk(clk),.rst(rst),.data_in(product0),.data_out(product0_q1));

//     // 乘完的结果拼接
//     wire [47:0] data_in = {product1_q1, product0_q1};
//     // wire [47:0] data_in_reg_q1;
//     // 先把data_in高位左移12bit得到data_in_H(product1),data_in低位data_in_L(product0）也提取出来,然后相加，再约减(PE0)
//     wire [35:0] data_in_H = {data_in[47:24],12'b0};
//     wire [23:0] data_in_L = data_in[23:0];
//     wire[47:0] data_in_reg = data_in_H + data_in_L; //D_2_NTT:F3·ωH·2^12 + F3·ωL (26bit+24bit 存到 48bit 约简成 24bit)
//     // DFF #(48) dff_data_in_reg(.clk(clk),.rst(rst),.data_in(data_in_reg),.data_out(data_in_reg_q1));

//     //测试变量
//     wire [23:0] data_in_reg_H = data_in_reg[23:12];
//     wire [23:0] data_in_reg_L = data_in_reg[11:0];


//     // 模块实例化 必须在编译时确定，不是运行时;综合器通常能识别这种结构并自动优化未用路径,不会有额外资源浪费
//     wire [22:0] mod_result0,mod_result0_q1;  // D_redu 的结果
//     wire [11:0] mod_result1, mod_result2,mod_result1_q1,mod_result2_q1; // K_redu 的结果
//     D_redu d_redu (.clk(clk),.rst(rst),.data_in(data_in_reg), .result(mod_result0));
//     K_redu k_redu0 (.clk(clk),.rst(rst),.data_in(product0_q1), .result(mod_result1));
//     K_redu k_redu1 (.clk(clk),.rst(rst),.data_in(product1_q1), .result(mod_result2));

//     DFF #(23) dff_d_redu(.clk(clk),.rst(rst),.data_in(mod_result0),.data_out(mod_result0_q1)); //mod_result0_q1--23bit
//     DFF #(12) dff_k_redu0(.clk(clk),.rst(rst),.data_in(mod_result1),.data_out(mod_result1_q1));
//     DFF #(12) dff_k_redu1(.clk(clk),.rst(rst),.data_in(mod_result2),.data_out(mod_result2_q1));
//     // 输出结果
//     assign result = (mul_Red_mode == 1'b1) ? {1'b0, mod_result0_q1} : {mod_result2_q1, mod_result1_q1};

//     //测试变量
//     wire [11:0] mod_result0_q1_H = result[23:12];
//     wire [11:0] mod_result0_q1_L = result[11:0];
// endmodule
