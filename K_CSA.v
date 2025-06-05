module K_CSA (
    input clk,rst,
    input  [16:0] a,     // 27-bit input
    input  [16:0] b,     // 27-bit input
    input  [16:0] c,     // 27-bit input
    output [16:0] sum,   // Sum result
    output [16:0] carry  // Carry result
);

    assign sum = a ^ b ^ c;        // Sum without carry propagation
    assign carry = (a & b) | (b & c) | (c & a);  // Carry propagation

endmodule