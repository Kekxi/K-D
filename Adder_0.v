`timescale 1ns / 1ps
//12bitKyber 高加低减  Dilithium直接输出 每次输出前用DFF对齐
module Adder_0(
    inout clk,rst,
    input [23:0] Adder0_a,  // K_4_INTT:(T1,T3)     D_2_NTT:(F3·ωH·2^12 + F3·ωL) -- 约简后的24bit
    // input [23:0] Adder0_b, //这个输入存在的意义是满足硬件设计 加法器2个24bit输入
    input [1:0] sel_a,
    input Adder_0_mode, //Kyber时，Adder_0_mode = 0，执行加减法；Dilithium时，直接输出乘法约简后的结果
    output [23:0] Adder0_sum // K_4_INTT:(T1+T3,T1-T3)
   );
    
    wire [11:0] d0,d1,s1,q,add_sum,sub_sum,Adder0_a_q1,add_sum_q1,sub_sum_q1;
    wire b0,c1,b1,sel;
    wire [12:0] sub_right,sum_left;
    
    wire [11:0] AH_reg = Adder0_a[23:12]; //K_4_INTT:T1
    // wire [11:0] AL_reg = Adder0_a[11:0];  //K_4_INTT:T3
    wire [11:0] AL = Adder0_a[11:0];

    wire [11:0] AH_reg_shift_6,AL_reg_shift_6;
    shift_6 #(.data_width(12)) shf6_AH_reg (.clk(clk),.rst(rst),.data_in(AH_reg),.data_out(AH_reg_shift_6)); 
    // shift_6 #(.data_width(12)) shf6_AL_reg (.clk(clk),.rst(rst),.data_in(AL_reg),.data_out(AL_reg_shift_6));
    wire [11:0] AH = (sel_a == 2'b10) ? AH_reg_shift_6 : AH_reg; //INTT shift6
    // wire [11:0] AL = (sel_a == 2'b10) ? AL_reg_shift_6 : AL_reg;

    parameter Kq = 3329;

    //KNTT & KINTT 加法
    assign sum_left = AH + AL;
    assign {c1,s1} = sum_left;
    assign {b1,d1} = s1 - Kq;
    assign sel = ~((~c1) & b1 );
    assign add_sum = sel == 1 ? d1 : s1;
    //KNTT & KINTT 减法
    assign sub_right = AH - AL;
    assign {b0,d0} = sub_right; 
    assign q = b0 == 1 ? Kq : 0;
    assign sub_sum = d0 + q;

    // DFF #(24) dff_Adder0_a(.clk(clk),.rst(rst),.data_in(Adder0_a),.data_out(Adder0_a_q1));
    // DFF #(12) dff_add_sum(.clk(clk),.rst(rst),.data_in(add_sum),.data_out(add_sum_q1));
    // DFF #(12) dff_sub_sum(.clk(clk),.rst(rst),.data_in(sub_sum),.data_out(sub_sum_q1));

    // assign Adder0_sum = (Adder_0_mode == 1'b0) ? {add_sum_q1,sub_sum_q1} : Adder0_a_q1 ;  //高位是相加结果，低位是相减结果
    assign Adder0_sum = (Adder_0_mode == 1'b0) ? {add_sum,sub_sum} : Adder0_a;  //高位是相加结果，低位是相减结果
    // 测试数据范围 Dilithium [0,8380416] 24bit ； Kyber { [0,3328] , [0,3328] } 24bit
    
endmodule
// `timescale 1ns / 1ps
// //12bitKyber 左加右减  Dilithium直接输出
// module Adder_0(
//     input [23:0] Adder0_a,  // 24-bit input a 
//     input KD_mode, //Kyber时，Adder_0_mode = 0，执行加减法；Dilithium时，直接输出乘法约简后的结果
//     output [23:0] Adder0_sum
//    );
    
//     wire [11:0] d0,d1,s1,q,add_sum,sub_sum;
//     wire b0,c1,b1,sel;
//     wire [12:0] sub_right,sum_left;
    
//     wire [11:0] AH = Adder0_a[23:12];
//     wire [11:0] AL = Adder0_a[11:0];
    

//     parameter Kq = 3329;
//     //KNTT & KINTT 减法
//     assign sub_right = AH - AL;
//     assign {b0,d0} = sub_right; 
//     assign q = b0 == 1 ? Kq : 0;
//     assign sub_sum = d0 + q;
 
//     //KNTT & KINTT 加法
//     assign sum_left = AH + AL;
//     assign {c1,s1} = sum_left;
//     assign {b1,d1} = s1 - Kq;
//     assign sel = ~((~c1) & b1 );
//     assign add_sum = sel == 1 ? d1 : s1;

//     assign Adder0_sum = (KD_mode == 1'b0) ? {add_sum,sub_sum} : Adder0_a ;  //高位是相加结果，低位是相减结果
//     // 测试数据范围 Dilithium [0,8380416] 24bit ； Kyber { [0,3328] , [0,3328] } 24bit
    
// endmodule

//优化版本代码 逻辑是否正确有待查验！

// `timescale 1ns / 1ps

// module Adder_0(
//     input [23:0] Adder0_a,  // 24-bit input a 
//     input Adder_0_mode,      // Kyber时，Adder_0_mode = 0，执行加减法；Dilithium时，直接输出乘法约简后的结果
//     output [23:0] Adder0_sum // 24-bit output sum
// );

//     // 输入分片
//     wire [11:0] AH = Adder0_a[23:12]; // 高12位
//     wire [11:0] AL = Adder0_a[11:0];  // 低12位

//     // 常量定义
//     parameter Kq = 3329; // Kyber 的模数

//     // 加减法逻辑
//     wire [12:0] sub_right = AH - AL; // 减法结果
//     wire [11:0] sub_sum = (sub_right[12]) ? (sub_right[11:0] + Kq) : sub_right[11:0]; // 处理减法溢出

//     wire [12:0] sum_left = AH + AL; // 加法结果
//     wire [11:0] add_sum = (sum_left >= Kq) ? (sum_left - Kq) : sum_left[11:0]; // 处理加法溢出

//     // 输出结果
//     assign Adder0_sum = (Adder_0_mode == 1'b0) ? {add_sum, sub_sum} : Adder0_a; // Kyber 模式输出加减结果，Dilithium 模式直接输出

// endmodule