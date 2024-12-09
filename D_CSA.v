`timescale 1ns / 1ps
module D_CSA (
    input  [26:0] a,     // 27-bit input
    input  [26:0] b,     // 27-bit input
    input  [26:0] c,     // 27-bit input
    output [26:0] sum,   // Sum result
    output [26:0] carry  // Carry result
);

    assign sum = a ^ b ^ c;        // Sum without carry propagation
    assign carry = (a & b) | (b & c) | (c & a);  // Carry propagation

endmodule
