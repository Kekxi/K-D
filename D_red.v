`timescale 1ns / 1ps
module D_redu (
    input [47:0] data_in,  
    output reg [22:0] result  
);

reg [26:0] temp0,temp1,temp2,temp3,temp4,temp5;
reg [22:0] temp7,temp8,temp9;  
wire [26:0] sum0,sum1,sum2,sum3;
wire [26:0] carry0,carry1,carry2,carry3;
reg [26:0] carry0_shift,carry1_shift,carry2_shift;
reg signed [26:0] mod_sum,mod_sum1,mod_result;
reg [25:0] mod_sum2;
wire[47:0] temp6 = ~data_in;
reg [11:0] result1;
parameter Dq = 8380417;
always @* begin

    temp0 = data_in[22:0];
    temp1 = temp6[45:23]; 
    temp2 = {data_in[32:23],temp6[45:33]};
    temp3 = {data_in[42:33],10'b0,temp6[45:43]};
    temp4 = data_in[45:43]<<13;
    temp5 = 27'b111011111111101111111111011;

    carry0_shift = {carry0,1'b0};
    carry1_shift = {carry1,1'b0};
    carry2_shift = {carry2,1'b0};

    mod_sum = (carry3 << 1) + sum3;
    mod_sum1 = temp0 + temp1 + temp2 + temp3 + temp4 + temp5;  //验证结果正确与否

    temp7 = data_in[32:23] << 13;
    temp8 = data_in[42:33] << 13;
    temp9 = data_in[45:43] << 13;
    mod_sum2 = temp0 - temp1 + temp7 - data_in[45:33] + temp8 - data_in[45:43] + temp9;
   
    if (mod_sum < 0) begin
            // Case 1: mod_sum is negative, add q
            mod_result = mod_sum + Dq;
        end else if (mod_sum < Dq && mod_sum > 0) begin
            // Case 2: mod_sum is already in the range [0, q), output directly
            mod_result = mod_sum;
        end else begin
            // Case 3: mod_sum >= q, keep subtracting q until result is in the range [0, q)
            mod_result = mod_sum;
            while (mod_result >= Dq) begin
                mod_result = mod_result - Dq;
            end
        end
    result = mod_result;
    result1 = data_in % Dq; // 验证结果正确与否
end
    
    D_CSA csa0 (.a(temp0), .b(temp1), .c(temp2), .sum(sum0), .carry(carry0));
    D_CSA csa1 (.a(temp3), .b(temp4), .c(temp5), .sum(sum1), .carry(carry1)); 
    D_CSA csa2 (.a(sum0), .b(carry0_shift), .c(sum1), .sum(sum2), .carry(carry2));
    D_CSA csa3 (.a(sum2), .b(carry2_shift), .c(carry1_shift), .sum(sum3), .carry(carry3));

endmodule

