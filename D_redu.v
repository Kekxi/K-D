`timescale 1ns / 1ps
//输出DFF对齐
module D_redu (
    input clk,rst,
    input [47:0] data_in,  
    output [22:0] result  //此处把reg型改掉了
);

  wire [26:0] temp0, temp1, temp2, temp3, temp4, temp5,temp0_q1, temp1_q1, temp2_q1, temp3_q1, temp4_q1, temp5_q1;
  wire [26:0] sum0, sum1, sum2, sum3,sum0_q1, sum1_q1, sum2_q1, sum3_q1;
  wire [26:0] carry0, carry1, carry2, carry3,carry0_q1, carry1_q1, carry2_q1, carry3_q1;
  wire [26:0] carry0_shift, carry1_shift, carry2_shift,carry0_shift_q1, carry1_shift_q1, carry2_shift_q1;
  wire signed [26:0] mod_sum, mod_result;
  wire [47:0] temp6 = ~data_in;
  parameter Dq = 8380417;
  
  assign temp0 = data_in[22:0];
  assign temp1 = temp6[45:23]; 
  assign temp2 = {data_in[32:23],temp6[45:33]};
  assign temp3 = {data_in[42:33],10'b0,temp6[45:43]};
  assign temp4 = data_in[45:43]<<13;
  assign temp5 = 27'b111011111111101111111111011;
  
  assign carry0_shift = {carry0_q1,1'b0};
  assign carry1_shift = {carry1_q1,1'b0};
  assign carry2_shift = {carry2,1'b0};

  DFF #(27) dff_sum0(.clk(clk),.rst(rst),.data_in(sum0),.data_out(sum0_q1));
  DFF #(27) dff_sum1(.clk(clk),.rst(rst),.data_in(sum1),.data_out(sum1_q1));
  DFF #(27) dff_carry0(.clk(clk),.rst(rst),.data_in(carry0),.data_out(carry0_q1));
  DFF #(27) dff_carry1(.clk(clk),.rst(rst),.data_in(carry1),.data_out(carry1_q1));

  // DFF #(27) dff_sum2(.clk(clk),.rst(rst),.data_in(sum2),.data_out(sum2_q1));
  // DFF #(27) dff_carry2(.clk(clk),.rst(rst),.data_in(carry2),.data_out(carry2_q1));

  DFF #(27) dff_sum3(.clk(clk),.rst(rst),.data_in(sum3),.data_out(sum3_q1));
  DFF #(27) dff_carry3(.clk(clk),.rst(rst),.data_in(carry3),.data_out(carry3_q1));

  
  
  D_CSA csa0 (.a(temp0), .b(temp1), .c(temp2), .sum(sum0), .carry(carry0)); //0
  D_CSA csa1 (.a(temp3), .b(temp4), .c(temp5), .sum(sum1), .carry(carry1)); 

  D_CSA csa2 (.a(sum0_q1), .b(carry0_shift), .c(sum1_q1), .sum(sum2), .carry(carry2)); //1
  D_CSA csa3 (.a(sum2), .b(carry2_shift), .c(carry1_shift), .sum(sum3), .carry(carry3));

  
  wire signed [26:0] mod_sum_reg = (carry3_q1 << 1) + sum3_q1;
  DFF #(27) dff_mod_sum_reg (.clk(clk),.rst(rst),.data_in(mod_sum_reg),.data_out(mod_sum));

  // assign mod_sum = (carry3_q1 << 1) + sum3_q1;
  assign mod_result = (mod_sum >= Dq) ? 
                     ((mod_sum - Dq >= Dq) ? (mod_sum - 2*Dq) : (mod_sum - Dq)) : 
                     ((mod_sum < 0) ? (mod_sum + Dq) : mod_sum);
  assign result = mod_result;
  // always @* begin
  
  //     if (mod_sum < 0) begin
  //             // Case 1: mod_sum is negative, add q
  //             mod_result = mod_sum + Dq;
  //         end else if (mod_sum < Dq) begin
  //             // Case 2: mod_sum is already in the range [0, q), output directly
  //             mod_result = mod_sum;
  //         end else begin
  //             // Case 3: mod_sum >= q, keep subtracting q until result is in the range [0, q)
  //             mod_result = mod_sum - Dq; //需要进一步边界值测试，看看是否减一次Dq就够，理论分析一下
  //             if (mod_result >= Dq) begin
  //                 mod_result = mod_result - Dq;
  //             end
  //         end
  //     result = mod_result_q1;
     
  // end
endmodule

// `timescale 1ns / 1ps
// module D_redu (
//     input [47:0] data_in,  
//     output reg [22:0] result  
// );

// reg [26:0] temp0,temp1,temp2,temp3,temp4,temp5;
// wire [26:0] sum0,sum1,sum2,sum3;
// wire [26:0] carry0,carry1,carry2,carry3;
// reg [26:0] carry0_shift,carry1_shift,carry2_shift;
// reg signed [26:0] mod_sum,mod_sum1,mod_result;
// wire[47:0] temp6 = ~data_in;
// parameter Dq = 8380417;

// always @* begin


//     temp0 = data_in[22:0];
//     temp1 = temp6[45:23]; 
//     temp2 = {data_in[32:23],temp6[45:33]};
//     temp3 = {data_in[42:33],10'b0,temp6[45:43]};
//     temp4 = data_in[45:43]<<13;
//     temp5 = 27'b111011111111101111111111011;

//     carry0_shift = {carry0,1'b0};
//     carry1_shift = {carry1,1'b0};
//     carry2_shift = {carry2,1'b0};

//     mod_sum = (carry3 << 1) + sum3;
//     //mod_sum1 = temp0 + temp1 + temp2 + temp3 + temp4 + temp5;  //验证结果正确与否
   
//     if (mod_sum < 0) begin
//             // Case 1: mod_sum is negative, add q
//             mod_result = mod_sum + Dq;
//         end else if (mod_sum < Dq) begin
//             // Case 2: mod_sum is already in the range [0, q), output directly
//             mod_result = mod_sum;
//         end else begin
//             // Case 3: mod_sum >= q, keep subtracting q until result is in the range [0, q)
//             mod_result = mod_sum - Dq; //需要进一步边界值测试，看看是否减一次Dq就够，理论分析一下
//             if (mod_result >= Dq) begin
//                 mod_result = mod_result - Dq;
//             end
//         end
//     result = mod_result;
   
// end
    
//     D_CSA csa0 (.a(temp0), .b(temp1), .c(temp2), .sum(sum0), .carry(carry0));
//     D_CSA csa1 (.a(temp3), .b(temp4), .c(temp5), .sum(sum1), .carry(carry1)); 
//     D_CSA csa2 (.a(sum0), .b(carry0_shift), .c(sum1), .sum(sum2), .carry(carry2));
//     D_CSA csa3 (.a(sum2), .b(carry2_shift), .c(carry1_shift), .sum(sum3), .carry(carry3));

// endmodule

