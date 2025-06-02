`timescale 1ns / 1ps
module K_redu (
    input clk,rst, //如果没有DFF，它用不到
    input [23:0] data_in,  
    output [11:0] result  //此处把reg型改掉了
);

  wire [16:0] temp0,temp1,temp2,temp3,temp4,temp5,temp6,temp7,temp9; 
  wire [16:0] sum0,carry0,sum1,carry1,sum2,carry2,sum3,carry3,sum4,carry4,sum5,carry5,sum6,carry6;
  wire [17:0] carry0_shift,carry1_shift,carry2_shift,carry3_shift,carry4_shift,carry5_shift;
  wire signed [16:0] mod_sum;
  wire signed [16:0] mod_result;
  wire [23:0] temp8 = ~data_in;
  parameter Kq = 3329; 
  assign temp0 = {5'b0,data_in[11:0]};
  assign temp1 = {6'b0,data_in[13:12],data_in[12],temp8[19:12]}; 
  assign temp2 = {6'b0,data_in[17],data_in[13],data_in[17],temp8[22:18],temp8[16:14]};    
  assign temp3 = {6'b0,data_in[19],data_in[15],data_in[19],temp8[23:19],temp8[17],temp8[17],temp8[17]};    
  assign temp4 = {6'b0,temp8[18],data_in[19],temp8[23],1'b0,temp8[23:20],temp8[18],temp8[18],temp8[18]};     
  assign temp5 = {6'b0,temp8[16],data_in[18],temp8[18],3'b0,temp8[23:22],temp8[19],temp8[20:19]};    
  assign temp6 = {6'b0,temp8[15],1'b0,temp8[14],4'b0,temp8[23],temp8[21],temp8[21:20]};  
  assign temp7 = {9'b0,temp8[22],2'b0};
  assign temp9 = 17'b11110110101010010;
  
  assign carry0_shift = {carry0_reg,1'b0};
  assign carry1_shift = {carry1_reg,1'b0};
  assign carry2_shift = {carry2_reg,1'b0};
  assign carry3_shift = {carry3_reg,1'b0};
  assign carry4_shift = {carry4_reg,1'b0};
  // assign carry5_shift = {carry5_reg,1'b0};
  assign carry5_shift = {carry5,1'b0};
  
  wire [16:0] sum0_reg,carry0_reg,sum1_reg,carry1_reg,sum2_reg,carry2_reg,sum3_reg,carry3_reg,sum4_reg,sum4_reg_1,carry4_reg,sum5_reg,carry5_reg,sum6_reg,carry6_reg;
  DFF #(17) dff_m0 (.clk(clk),.rst(rst),.data_in(sum0),.data_out(sum0_reg));
  DFF #(17) dff_carry0 (.clk(clk),.rst(rst),.data_in(carry0),.data_out(carry0_reg));
  DFF #(17) dff_m1 (.clk(clk),.rst(rst),.data_in(sum1),.data_out(sum1_reg));
  DFF #(17) dff_carry1 (.clk(clk),.rst(rst),.data_in(carry1),.data_out(carry1_reg));
  DFF #(17) dff_m2 (.clk(clk),.rst(rst),.data_in(sum2),.data_out(sum2_reg));
  DFF #(17) dff_carry2 (.clk(clk),.rst(rst),.data_in(carry2),.data_out(carry2_reg));

  DFF #(17) dff_m3 (.clk(clk),.rst(rst),.data_in(sum3),.data_out(sum3_reg));
  DFF #(17) dff_carry3 (.clk(clk),.rst(rst),.data_in(carry3),.data_out(carry3_reg));
  DFF #(17) dff_m4 (.clk(clk),.rst(rst),.data_in(sum4),.data_out(sum4_reg));
  DFF #(17) dff_carry4 (.clk(clk),.rst(rst),.data_in(carry4),.data_out(carry4_reg));

  // DFF #(17) dff_m4_1 (.clk(clk),.rst(rst),.data_in(sum4_reg),.data_out(sum4_reg_1));
  // DFF #(17) dff_m5 (.clk(clk),.rst(rst),.data_in(sum5),.data_out(sum5_reg)); //改动过 注释掉了
  // DFF #(17) dff_carry5 (.clk(clk),.rst(rst),.data_in(carry5),.data_out(carry5_reg)); //改动过  注释掉了

  DFF #(17) dff_m6 (.clk(clk),.rst(rst),.data_in(sum6),.data_out(sum6_reg));
  DFF #(17) dff_carry6 (.clk(clk),.rst(rst),.data_in(carry6),.data_out(carry6_reg));
 

  K_CSA csa0 (.clk(clk),.rst(rst),.a(temp0), .b(temp1), .c(temp2), .sum(sum0), .carry(carry0));//0
  K_CSA csa1 (.clk(clk),.rst(rst),.a(temp3), .b(temp4), .c(temp5), .sum(sum1), .carry(carry1));
  K_CSA csa2 (.clk(clk),.rst(rst),.a(temp6), .b(temp7), .c(temp9), .sum(sum2), .carry(carry2));

  K_CSA csa3 (.clk(clk),.rst(rst),.a(carry0_shift), .b(sum0_reg), .c(carry1_shift), .sum(sum3), .carry(carry3));//1
  K_CSA csa4 (.clk(clk),.rst(rst),.a(sum1_reg), .b(carry2_shift), .c(sum2_reg), .sum(sum4), .carry(carry4));

  K_CSA csa5 (.clk(clk),.rst(rst),.a(carry3_shift), .b(sum3_reg), .c(carry4_shift), .sum(sum5), .carry(carry5));   //2

  // K_CSA csa6 (.clk(clk),.rst(rst),.a(carry5_shift), .b(sum5_reg), .c(sum4_reg_1), .sum(sum6), .carry(carry6));//3
  K_CSA csa6 (.clk(clk),.rst(rst),.a(carry5_shift), .b(sum5), .c(sum4_reg), .sum(sum6), .carry(carry6));   //2
  
  //改过
  wire signed [16:0] mod_sum_reg;
  assign mod_sum_reg = (carry6_reg << 1) + sum6_reg;
  DFF #(17) dff_mod_sum_reg (.clk(clk),.rst(rst),.data_in(mod_sum_reg),.data_out(mod_sum));


  assign mod_result = (mod_sum >= Kq) ? 
                     ((mod_sum - Kq >= Kq) ? (mod_sum - 2*Kq) : (mod_sum - Kq)) : 
                     ((mod_sum < 0) ? (mod_sum + Kq) : mod_sum);
  assign result = mod_result;   
  //     if (mod_sum < 0) begin
  //             // Case 1: mod_sum is negative, add q
  //             mod_result = mod_sum + Kq;
  //         end else if (mod_sum < Kq ) begin
  //             // Case 2: mod_sum is already in the range [0, q)
  //             mod_result = mod_sum;
  //         end else begin
  //             // Case 3: mod_sum >= q,  边界值测试发现这个有必要留下吗？     
  //             mod_result = mod_sum - Kq; //需要进一步边界值测试，看看是否减一次Kq就够，理论分析一下（测试显示不够，至少需要减2次）
  //             if (mod_result >= Kq) begin
  //                 mod_result = mod_result - Kq;
  //             end
  
  //         end
endmodule
// module K_redu (
//     input [23:0] data_in,  
//     output reg [11:0] result  
// );

// reg [16:0] temp0,temp1,temp2,temp3,temp4,temp5,temp6,temp7,temp9; 
// wire [16:0] sum0,carry0,sum1,carry1,sum2,carry2,sum3,carry3,sum4,carry4,sum5,carry5,sum6,carry6;
// reg [17:0] carry0_shift,carry1_shift,carry2_shift,carry3_shift,carry4_shift,carry5_shift;
// reg signed [16:0] mod_sum;
// reg signed [16:0] mod_sum1; //验证变量
// reg signed [16:0] mod_result;
// wire [23:0] temp8 = ~data_in;
// reg [11:0] result1; //验证变量
// parameter Kq = 3329;
// always @* begin  

//     temp0 = {5'b0,data_in[11:0]};
//     temp1 = {6'b0,data_in[13:12],data_in[12],temp8[19:12]}; 
//     temp2 = {6'b0,data_in[17],data_in[13],data_in[17],temp8[22:18],temp8[16:14]};    
//     temp3 = {6'b0,data_in[19],data_in[15],data_in[19],temp8[23:19],temp8[17],temp8[17],temp8[17]};    
//     temp4 = {6'b0,temp8[18],data_in[19],temp8[23],1'b0,temp8[23:20],temp8[18],temp8[18],temp8[18]};     
//     temp5 = {6'b0,temp8[16],data_in[18],temp8[18],3'b0,temp8[23:22],temp8[19],temp8[20:19]};    
//     temp6 = {6'b0,temp8[15],1'b0,temp8[14],4'b0,temp8[23],temp8[21],temp8[21:20]};  
//     temp7 = {9'b0,temp8[22],2'b0};
//     temp9 = 17'b11110110101010010;

//     carry0_shift = {carry0,1'b0};
//     carry1_shift = {carry1,1'b0};
//     carry2_shift = {carry2,1'b0};
//     carry3_shift = {carry3,1'b0};
//     carry4_shift = {carry4,1'b0};
//     carry5_shift = {carry5,1'b0};

//     mod_sum = (carry6 << 1) + sum6;
//     mod_sum1 = temp0 + temp1 + temp2 + temp3 + temp4 + temp5 + temp6 + temp7 + temp9;  // 验证CSA与直接加结果是否一致，可删
    
//     if (mod_sum < 0) begin
//             // Case 1: mod_sum is negative, add q
//             mod_result = mod_sum + Kq;
//         end else if (mod_sum < Kq ) begin
//             // Case 2: mod_sum is already in the range [0, q)
//             mod_result = mod_sum;
//         end else begin
//             // Case 3: mod_sum >= q,  边界值测试发现这个有必要留下吗？     
//             mod_result = mod_sum - Kq; //需要进一步边界值测试，看看是否减一次Kq就够，理论分析一下（测试显示不够，至少需要减2次）
//             if (mod_result >= Kq) begin
//                 mod_result = mod_result - Kq;
//             end

//         end

//     result1 = data_in % Kq; // 验证约简结果，可删   测试数据在[0,(q-1)^2]范围内，也就是[0,11 075 584]
//     result = mod_result;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           

// end

//     K_CSA csa0 (.a(temp0), .b(temp1), .c(temp2), .sum(sum0), .carry(carry0));
//     K_CSA csa1 (.a(temp3), .b(temp4), .c(temp5), .sum(sum1), .carry(carry1));
//     K_CSA csa2 (.a(temp6), .b(temp7), .c(temp9), .sum(sum2), .carry(carry2));
//     K_CSA csa3 (.a(carry0_shift), .b(sum0), .c(carry1_shift), .sum(sum3), .carry(carry3));
//     K_CSA csa4 (.a(sum1), .b(carry2_shift), .c(sum2), .sum(sum4), .carry(carry4));
//     K_CSA csa5 (.a(carry3_shift), .b(sum3), .c(carry4_shift), .sum(sum5), .carry(carry5));   
//     K_CSA csa6 (.a(carry5_shift), .b(sum5), .c(sum4), .sum(sum6), .carry(carry6));   
    
// endmodule
