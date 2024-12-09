`timescale 1ns / 1ps

module test_D_redu;

    reg [47:0] data_in;
    wire [22:0] result;

    // Instantiate the module under test
    D_redu uut (
        .data_in(data_in),
        .result(result)
    );

    initial begin
        // Test 1: Minimum input
        data_in = 48'd0;
        #10 $display("Test 1: data_in=%d, result=%d", data_in, result);

        // Test 2: Maximum input
        data_in = 48'd70231372333056;
        #10 $display("Test 2: data_in=%d, result=%d", data_in, result);

        // Test 3: Modulus value
        data_in = 48'd8380417;
        #10 $display("Test 3: data_in=%d, result=%d", data_in, result);

        // Test 4: One less than modulus
        data_in = 48'd8380416;
        #10 $display("Test 4: data_in=%d, result=%d", data_in, result);

        // Test 5: Exact multiple of modulus
        data_in = 48'd8380417 * 5;
        #10 $display("Test 5: data_in=%d, result=%d", data_in, result);

        // Test 6: Near maximum input
        data_in = 48'd70231372333050;
        #10 $display("Test 6: data_in=%d, result=%d", data_in, result);

        // Test 7: Mid-range value
        data_in = 48'd35115686166528;
        #10 $display("Test 7: data_in=%d, result=%d", data_in, result);

        // Test 8: Random value 1
        data_in = 48'd12345678901234;
        #10 $display("Test 8: data_in=%d, result=%d", data_in, result);

        // Test 9: Random value 2
        data_in = 48'd56789012345678;
        #10 $display("Test 9: data_in=%d, result=%d", data_in, result);

        // Test 10: Random value 3
        data_in = 48'd45123456789012;
        #10 $display("Test 10: data_in=%d, result=%d", data_in, result);

        // Test 11: Small value
        data_in = 48'd54321;
        #10 $display("Test 11: data_in=%d, result=%d", data_in, result);

        // Test 12: Large value close to modulus
        data_in = 48'd8380417 + 100;
        #10 $display("Test 12: data_in=%d, result=%d", data_in, result);

        // Test 13: Random large value
        data_in = 48'd60372849122345;
        #10 $display("Test 13: data_in=%d, result=%d", data_in, result);

        // Test 14: Alternating bit pattern
        data_in = 48'b101010101010101010101010101010101010101010101010;
        #10 $display("Test 14: data_in=%b, result=%d", data_in, result);

        // Test 15: Alternating bit pattern inverted
        data_in = 48'b010101010101010101010101010101010101010101010101;
        #10 $display("Test 15: data_in=%b, result=%d", data_in, result);

        // Test 16: Low 24 bits set
        data_in = 48'hFFFFFF;
        #10 $display("Test 16: data_in=%h, result=%d", data_in, result);

        // Test 17: High 24 bits set
        data_in = 48'hFFFFFF000000;
        #10 $display("Test 17: data_in=%h, result=%d", data_in, result);

        // Test 18: Large random multiple of modulus
        data_in = 48'd8380417 * 123456;
        #10 $display("Test 18: data_in=%d, result=%d", data_in, result);

        // Test 19: Random bit-heavy value
        data_in = 48'h1234ABCDE123;
        #10 $display("Test 19: data_in=%h, result=%d", data_in, result);

        // Test 20: All bits set
        data_in = 48'hFFFFFFFFFFFF;
        #10 $display("Test 20: data_in=%h, result=%d", data_in, result);

        $stop;
    end

endmodule
