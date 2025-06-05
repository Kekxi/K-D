`timescale 1ns / 1ps
// module mul_Red_1 (
//     input clk,rst,
//     input [23:0] A,         // K_4_INTT: P0 = (F1-F3,T0-T2)
//     input [23:0] w,         // K_4_INTT:(687,w2)
//     input mul_Red_mode,             // K_redu--0  D_redu--1
//     input [1:0] sel_a,
//     input sel_D_2_INTT,
//     input sel_K_4_NTT,                
//     output [23:0] result    //D_2_NTT: F2·ωH·2^24 + F2·ωL·2^12
//  );
//     wire [11:0] A_high_reg = A[23:12]; 
//     wire [11:0] A_low_reg = A[11:0];  
//     wire [11:0] w_high_reg = w[23:12]; 
//     wire [11:0] w_low_reg  = w[11:0];

//     wire [11:0] A_high_reg_shift_7,w_high_reg_shift_7,A_high_reg_shift_1,A_low_reg_shift_1;
//     shift_7 #(.data_width(12)) shf7_A_high_reg (.clk(clk),.rst(rst),.data_in(A_high_reg),.data_out(A_high_reg_shift_7)); 
//     shift_7 #(.data_width(12)) shf7_w_high_reg (.clk(clk),.rst(rst),.data_in(w_high_reg),.data_out(w_high_reg_shift_7));
//     shift_1 #(.data_width(12)) shf_A_high_reg (.clk(clk),.rst(rst),.data_in(A_high_reg),.data_out(A_high_reg_shift_1)); //K_4_INTT shift2
//     shift_1 #(.data_width(12)) shf_A_low_reg (.clk(clk),.rst(rst),.data_in(A_low_reg),.data_out(A_low_reg_shift_1));


//     //sel_a   1--K_4_NTT      2--K_4_INTT/D_2_INTT        0--K_2_NTT/K_2_INTT/D_2_NTT           
//     wire [11:0] A_high = (sel_a == 2'b1) ? A_high_reg_shift_7 : (sel_a == 2'b10) ? A_high_reg_shift_1 : A_high_reg; 
//     wire [11:0] A_low = (sel_D_2_INTT == 1'b1) ? A_low_reg_shift_1 : A_low_reg;
//     wire [11:0] w_high = (sel_K_4_NTT == 1'b1) ? w_high_reg_shift_7 : w_high_reg; //1--K_4_NTT 0--其他
//     wire [11:0] w_low = w_low_reg;
//     // wire [11:0] w_low = (sel_a == 2'b1) ? w_low_reg_shift_4 : w_low_reg ;


//     // 中间结果
//     wire [23:0] product1 = A_high * w_high;
//     wire [23:0] product0 = A_low * w_low;  

//     wire [23:0] product1_q1,product0_q1;  
//     DFF #(24) dff_product1(.clk(clk),.rst(rst),.data_in(product1),.data_out(product1_q1));
//     DFF #(24) dff_product2(.clk(clk),.rst(rst),.data_in(product0),.data_out(product0_q1));

//     wire [47:0] data_in = {product1_q1, product0_q1};

//     // 先把data_in高位左移12bit得到data_in_H(product1),data_in低位data_in_L(product0）也提取出来,然后相加，再约减(PE1)
//     wire [47:0] data_in_H = {product1_q1,24'b0};
//     wire [35:0] data_in_L = {product0_q1,12'b0};
//     wire[47:0] data_in_reg = data_in_H + data_in_L; //此处加完直接去模约简 相当于在乘法模块里做了模加


//     // //测试变量
//     // wire [23:0] data_in_reg_H = data_in_reg[23:12];
//     // wire [23:0] data_in_reg_L = data_in_reg[11:0];

//     wire [22:0] mod_result0;  // 要和D_red中的result保持一致23bit
//     wire [11:0] mod_result1,mod_result2;
//     D_redu d_redu (.clk(clk),.rst(rst),.data_in(data_in_reg),.result(mod_result0));
//     //Kyber  12bit低位 
//     K_redu k_redu0 (.clk(clk),.rst(rst),.data_in(product0_q1),.result(mod_result1));
//     //Kyber  12bit高位    
//     K_redu k_redu1 (.clk(clk),.rst(rst),.data_in(product1_q1),.result(mod_result2));

//     wire [22:0] mod_result0_q1; 
//     wire [11:0] mod_result1_q1,mod_result2_q1;
//     DFF #(23) dff_d_redu(.clk(clk),.rst(rst),.data_in(mod_result0),.data_out(mod_result0_q1)); //mod_result0_q1--23bit
//     DFF #(12) dff_k_redu0(.clk(clk),.rst(rst),.data_in(mod_result1),.data_out(mod_result1_q1));
//     DFF #(12) dff_k_redu1(.clk(clk),.rst(rst),.data_in(mod_result2),.data_out(mod_result2_q1));

//     assign result = (mul_Red_mode == 1'b1) ? {1'b0,mod_result0_q1} : {mod_result2_q1,mod_result1_q1}; 

//     //测试变量
//     wire [11:0] mod_result0_q1_H = result[23:12];
//     wire [11:0] mod_result0_q1_L = result[11:0];
   
// endmodule

// module mul_Red_1 (
//     input clk,rst,
//     input [23:0] A,         // K_4_INTT: P0 = (F1-F3,T0-T2)
//     input [23:0] w,         // K_4_INTT:(687,w2)
//     input mul_Red_mode,             // K_redu--0  D_redu--1
//     input [1:0] sel_a,
//     input sel_D_2_INTT,
//     input sel_K_4_NTT,                
//     output [23:0] result    //D_2_NTT: F2·ωH·2^24 + F2·ωL·2^12
//  );
//     // wire [11:0] A_high = A[23:12]; 
//     // wire [11:0] A_low  = A[11:0];  
//     // wire [11:0] w_high = w[23:12]; 
//     // wire [11:0] w_low  = w[11:0];
//     wire [11:0] A_high_reg = A[23:12]; 
//     wire [11:0] A_low_reg = A[11:0];  
//     wire [11:0] w_high_reg = w[23:12]; 
//     wire [11:0] w_low_reg  = w[11:0];

//     wire [11:0] A_high_reg_shift_7,w_high_reg_shift_7,A_high_reg_shift_1,A_low_reg_shift_1;
//     shift_7 #(.data_width(12)) shf7_A_high_reg (.clk(clk),.rst(rst),.data_in(A_high_reg),.data_out(A_high_reg_shift_7)); 
//     shift_7 #(.data_width(12)) shf7_w_high_reg (.clk(clk),.rst(rst),.data_in(w_high_reg),.data_out(w_high_reg_shift_7));
//     shift_1 #(.data_width(12)) shf_A_high_reg (.clk(clk),.rst(rst),.data_in(A_high_reg),.data_out(A_high_reg_shift_1)); //K_4_INTT shift2
//     shift_1 #(.data_width(12)) shf_A_low_reg (.clk(clk),.rst(rst),.data_in(A_low_reg),.data_out(A_low_reg_shift_1));


//     //sel_a   1--K_4_NTT      2--K_4_INTT/D_2_INTT        0--K_2_NTT/K_2_INTT/D_2_NTT           
//     wire [11:0] A_high = (sel_a == 2'b1) ? A_high_reg_shift_7 : (sel_a == 2'b10) ? A_high_reg_shift_1 : A_high_reg; 
//     wire [11:0] A_low = (sel_D_2_INTT == 1'b1) ? A_low_reg_shift_1 : A_low_reg;
//     wire [11:0] w_high = (sel_K_4_NTT == 1'b1) ? w_high_reg_shift_7 : w_high_reg; //1--K_4_NTT 0--其他
//     wire [11:0] w_low = w_low_reg;
//     // wire [11:0] w_low = (sel_a == 2'b1) ? w_low_reg_shift_4 : w_low_reg ;
    
    

//     // wire [11:0] A_high_reg_shift_4,w_high_reg_shift_7,w_low_reg_shift_6,A_high_reg_shift_2,w_high_reg_shift_2,w_low_reg_shift_2;
//     // shift_4 #(.data_width(12)) shf4_A_high_reg (.clk(clk),.rst(rst),.data_in(A_high_reg),.data_out(A_high_reg_shift_4)); 
//     // shift_7 #(.data_width(12)) shf7_w_high_reg (.clk(clk),.rst(rst),.data_in(w_high_reg),.data_out(w_high_reg_shift_7));
//     // shift_6 #(.data_width(12)) shf6_w_low_reg (.clk(clk),.rst(rst),.data_in(w_low_reg),.data_out(w_low_reg_shift_6));

//     // shift_2 #(.data_width(12)) shf2_A_high_reg (.clk(clk),.rst(rst),.data_in(A_high_reg),.data_out(A_high_reg_shift_2)); //K_4_INTT shift2
//     // shift_2 #(.data_width(12)) shf2_w_high_reg (.clk(clk),.rst(rst),.data_in(w_high_reg),.data_out(w_high_reg_shift_2)); //K_4_INTT shift2
//     // shift_2 #(.data_width(12)) shf2_w_low_reg  (.clk(clk),.rst(rst),.data_in(w_low_reg),.data_out(w_low_reg_shift_2)); //K_4_INTT shift2

//     // //sel_a   0--K_2_NTT           1--K_4_NTT      2--K_4_INTT        3--K_2_INTT
//     // wire [11:0] A_high = (sel_a == 2'b01) ? A_high_reg_shift_4 : (sel_a == 2'b10) ? A_high_reg_shift_2 : A_high_reg; //NTT shift4
//     // wire [11:0] w_high = (sel_a == 2'b01) ? w_high_reg_shift_7 : w_high_reg_shift_2;
//     // wire [11:0] w_low = (sel_a == 2'b01) ? w_low_reg_shift_6 : (sel_a == 2'b10) ? w_low_reg : w_low_reg_shift_2 ;


//     wire [23:0] product1 = A_high * w_high;
//     wire [23:0] product0 = A_low * w_low;  
    
//     wire [23:0] product1_q1,product0_q1;  
//     DFF #(24) dff_product1(.clk(clk),.rst(rst),.data_in(product1),.data_out(product1_q1));
//     DFF #(24) dff_product2(.clk(clk),.rst(rst),.data_in(product0),.data_out(product0_q1));

//     wire [47:0] data_in = {product1_q1, product0_q1};

//     // 先把data_in高位左移12bit得到data_in_H(product1),data_in低位data_in_L(product0）也提取出来,然后相加，再约减(PE1)
//     wire [47:0] data_in_H = {product1_q1,24'b0};
//     wire [35:0] data_in_L = {product0_q1,12'b0};
//     wire[47:0] data_in_reg = data_in_H + data_in_L; //此处加完直接去模约简 相当于在乘法模块里做了模加
//     // wire [47:0] data_in_reg_q1;
//     // DFF #(48) dff_data_in_reg(.clk(clk),.rst(rst),.data_in(data_in_reg),.data_out(data_in_reg_q1));

//     // //测试变量
//     // wire [23:0] data_in_reg_H = data_in_reg[23:12];
//     // wire [23:0] data_in_reg_L = data_in_reg[11:0];

//     wire [22:0] mod_result0;  // 要和D_red中的result保持一致23bit
//     wire [11:0] mod_result1,mod_result2;
//     D_redu d_redu (.clk(clk),.rst(rst),.data_in(data_in_reg),.result(mod_result0));
//     //Kyber  12bit低位 
//     K_redu k_redu0 (.clk(clk),.rst(rst),.data_in(product0_q1),.result(mod_result1));
//     //Kyber  12bit高位    
//     K_redu k_redu1 (.clk(clk),.rst(rst),.data_in(product1_q1),.result(mod_result2));

//     wire [22:0] mod_result0_q1; 
//     wire [11:0] mod_result1_q1,mod_result2_q1;
//     DFF #(24) dff_d_redu(.clk(clk),.rst(rst),.data_in(mod_result0),.data_out(mod_result0_q1)); //mod_result0_q1--23bit
//     DFF #(12) dff_k_redu0(.clk(clk),.rst(rst),.data_in(mod_result1),.data_out(mod_result1_q1));
//     DFF #(12) dff_k_redu1(.clk(clk),.rst(rst),.data_in(mod_result2),.data_out(mod_result2_q1));

//     assign result = (mul_Red_mode == 1'b1) ? {1'b0,mod_result0_q1} : {mod_result2_q1,mod_result1_q1}; 

//     //测试变量
//     wire [11:0] mod_result0_q1_H = result[23:12];
//     wire [11:0] mod_result0_q1_L = result[11:0];
   
// endmodule

