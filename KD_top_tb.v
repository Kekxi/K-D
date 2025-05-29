`timescale 1ns / 1ps
module top_tb;

   reg clk,rst;
   reg [3:0]Run_mode;
   reg KD_mode;
   wire [1:0] done_flag;


   initial
  begin
    clk=1'b0;
    forever #5 clk=~clk;
  end
  
  initial 
  begin
    //kyber
    Run_mode = 0; //IDLE
    KD_mode =0;
    rst = 1;
    # 7 rst = 0;
    # 2 Run_mode = 1;    //K_2_NTT
    # 315 Run_mode = 2;  //Done_K_2_NTT
    # 170 Run_mode = 3;  //K_4_NTT
    # 956 Run_mode = 4;  //Done_K_4_NTT
    // # 250 Run_mode = 9;  //K_4_INTT
    # 170 Run_mode = 9;  //K_4_INTT
    # 956 Run_mode = 10; //Done_K_4_INTT
    # 150 Run_mode = 7;  //K_2_INTT
    # 325 Run_mode = 8;  //Done_K_2_INTT

    // //Dilithium
    // Run_mode = 0; //IDLE
    // KD_mode =1;
    // rst = 1;
    // # 7 rst = 0;
    // # 2 Run_mode = 5;      // D_2_NTT
    // # 10243 Run_mode = 6;  // Done_D_2_NTT  1283*8=10264
    // # 3520 Run_mode = 11;  // D_2_INTT
    // # 10243 Run_mode = 12; // Done_D_2_INTT

  end
  

KD_top tb_top(
    .clk(clk),.rst(rst),
    .Run_mode(Run_mode),
    .KD_mode(KD_mode),
    .done_flag(done_flag));

  initial
  begin 
    // //Kyber--32*4
     $readmemb("D:/ntt/wangdi_code/KaLi_core/bank0.txt",top_tb.tb_top.bank_0.bank);
     $readmemb("D:/ntt/wangdi_code/KaLi_core/bank1.txt",top_tb.tb_top.bank_1.bank);
     $readmemb("D:/ntt/wangdi_code/KaLi_core/bank2.txt",top_tb.tb_top.bank_2.bank);
     $readmemb("D:/ntt/wangdi_code/KaLi_core/bank3.txt",top_tb.tb_top.bank_3.bank);
    // //Dilithium--128*4
    //  $readmemb("D:/KaLi_core/bank4.txt",top_tb.tb_top.bank_0.bank);
    //  $readmemb("D:/KaLi_core/bank5.txt",top_tb.tb_top.bank_1.bank);
    //  $readmemb("D:/KaLi_core/bank6.txt",top_tb.tb_top.bank_2.bank);
    //  $readmemb("D:/KaLi_core/bank7.txt",top_tb.tb_top.bank_3.bank);

  end

endmodule
// `timescale 1ns / 1ps

// module KD_NTT_tb;

//     // 信号声明
//     reg [23:0] KD_NTT_a;   // 数据a
//     reg [23:0] KD_NTT_b;   // 数据b
//     reg [23:0] KD_NTT_w0;  // 常数w0
//     reg [23:0] KD_NTT_w1;  // 常数w1
//     reg KD_NTT_mode0;      // 模式0
//     reg KD_NTT_mode1;      // 模式1

//     wire [23:0] KD_NTT_out_a;
//     wire [23:0] KD_NTT_out_b;

//     // 被测模块实例化 
//     KD_NTT uut (
//         .KD_NTT_a(KD_NTT_a),
//         .KD_NTT_b(KD_NTT_b),
//         .KD_NTT_w0(KD_NTT_w0),
//         .KD_NTT_w1(KD_NTT_w1),
//         .KD_NTT_mode0(KD_NTT_mode0),
//         .KD_NTT_mode1(KD_NTT_mode1),
//         .KD_NTT_out_a(KD_NTT_out_a),
//         .KD_NTT_out_b(KD_NTT_out_b)
//     );

//     // 初始化测试
//     initial begin
//         $display("======== 开始KD_NTT模块测试 ========");
//         $monitor("Time=%0t | mode0=%b mode1=%b | a=%d b=%d w0=%d w1=%d | out=%d",
//                  $time, KD_NTT_mode0, KD_NTT_mode1, KD_NTT_a, KD_NTT_b, KD_NTT_w0, KD_NTT_w1, KD_NTT_out_a,KD_NTT_out_b);
        
//         // 第一组测试: (KD_NTT_mode0, KD_NTT_mode1) = (0, 0)
//         KD_NTT_mode0 = 0;        KD_NTT_mode1 = 0;
//         KD_NTT_a = 24'd0;        KD_NTT_b = 24'd0;         KD_NTT_w0 = 24'd0;               KD_NTT_w1 = 24'd0; #10;    //w在Kq范围内 {wK,wK}
//         KD_NTT_a = 24'd13634816; KD_NTT_b = 24'd13634816;  KD_NTT_w0 = 24'd13634816;         KD_NTT_w1 = 24'd13634816;#10;
//         KD_NTT_a = 24'd13634816; KD_NTT_b = 24'd13634816;  KD_NTT_w0 = 24'd3327;            KD_NTT_w1 = 24'd3327; #10;
//         KD_NTT_a = 24'd1000000;  KD_NTT_b = 24'd5000000;   KD_NTT_w0 = 24'd2048;            KD_NTT_w1 = 24'd1024; #10;
//         KD_NTT_a = 24'd1234567;  KD_NTT_b = 24'd7654321;   KD_NTT_w0 = 24'd1024;            KD_NTT_w1 = 24'd512; #10;
//         KD_NTT_a = 24'd13634815; KD_NTT_b = 24'd1;         KD_NTT_w0 = 24'd3326;            KD_NTT_w1 = 24'd1; #10;

//         // 第二组测试: (KD_NTT_mode0, KD_NTT_mode1) = (0, 1)
//         KD_NTT_mode0 = 0;        KD_NTT_mode1 = 1;
//         KD_NTT_a = 24'd0;        KD_NTT_b = 24'd0;        KD_NTT_w0 = 24'd0;            KD_NTT_w1 = 24'd0; #10;             //w在Kq范围内
//         KD_NTT_a = 24'd13634816; KD_NTT_b = 24'd13634816; KD_NTT_w0 = 24'd13634816;     KD_NTT_w1 = 24'd13634816; #10;
//         KD_NTT_a = 24'd5000000;  KD_NTT_b = 24'd8000000;  KD_NTT_w0 = 24'd2047;         KD_NTT_w1 = 24'd1023; #10;
//         KD_NTT_a = 24'd4000000;  KD_NTT_b = 24'd3000000;  KD_NTT_w0 = 24'd3072;         KD_NTT_w1 = 24'd2048; #10;
//         KD_NTT_a = 24'd1000000;  KD_NTT_b = 24'd13634816; KD_NTT_w0 = 24'd3327;         KD_NTT_w1 = 24'd3327; #10;
//         KD_NTT_a = 24'd5000000;  KD_NTT_b = 24'd5000000;  KD_NTT_w0 = 24'd5000000;      KD_NTT_w1 = 24'd5000000; #10;
//         KD_NTT_a = 24'd5000000;  KD_NTT_b = 24'd8000000;  KD_NTT_w0 = 24'd1000000;      KD_NTT_w1 = 24'd2000000; #10;
//         KD_NTT_a = 24'd4000000;  KD_NTT_b = 24'd3000000;  KD_NTT_w0 = 24'd3000000;      KD_NTT_w1 = 24'd4000000; #10;
//         KD_NTT_a = 24'd1000000;  KD_NTT_b = 24'd13634816; KD_NTT_w0 = 24'd5000000;      KD_NTT_w1 = 24'd3000000; #10;
        

//         // 第三组测试: (KD_NTT_mode0, KD_NTT_mode1) = (1, 0)
//         KD_NTT_mode0 = 1;       KD_NTT_mode1 = 0;
//         KD_NTT_a = 24'd0;       KD_NTT_b = 24'd0;       KD_NTT_w0 = 24'd0;          KD_NTT_w1 = 24'd0; #10;
//         KD_NTT_a = 24'd8380416; KD_NTT_b = 24'd8380416; KD_NTT_w0 = 24'd8380416;    KD_NTT_w1 = 24'd8380416; #10;   //w在Dq范围内
//         KD_NTT_a = 24'd4000000; KD_NTT_b = 24'd2000000; KD_NTT_w0 = 24'd2048;       KD_NTT_w1 = 24'd2048; #10;
//         KD_NTT_a = 24'd4190208; KD_NTT_b = 24'd2095104; KD_NTT_w0 = 24'd3072;       KD_NTT_w1 = 24'd3072; #10;
//         KD_NTT_a = 24'd8380415; KD_NTT_b = 24'd1;       KD_NTT_w0 = 24'd3326;       KD_NTT_w1 = 24'd3326; #10;
//         KD_NTT_a = 24'd8380416; KD_NTT_b = 24'd7380416; KD_NTT_w0 = 24'd7380416;    KD_NTT_w1 = 24'd7380416; #10;   //有问题！已解决 代表性
//         KD_NTT_a = 24'd3000000; KD_NTT_b = 24'd5000000; KD_NTT_w0 = 24'd400000;       KD_NTT_w1 = 24'd400000; #10;
//         KD_NTT_a = 24'd6678932; KD_NTT_b = 24'd5625789; KD_NTT_w0 = 24'd99541;       KD_NTT_w1 = 24'd99541; #10;
//         KD_NTT_a = 24'd8380413; KD_NTT_b = 24'd99;       KD_NTT_w0 = 24'd3567213;       KD_NTT_w1 = 24'd3567213; #10;


//         // 第四组测试: (KD_NTT_mode0, KD_NTT_mode1) = (1, 1)
//         KD_NTT_mode0 = 1;       KD_NTT_mode1 = 1;
//         KD_NTT_a = 24'd0;       KD_NTT_b = 24'd0;       KD_NTT_w0 = 24'd0;          KD_NTT_w1 = 24'd0; #10;
//         KD_NTT_a = 24'd8380416; KD_NTT_b = 24'd8380416; KD_NTT_w0 = 24'd8380416;    KD_NTT_w1 = 24'd8380416; #10;   //w在Dq范围内
//         KD_NTT_a = 24'd4000000; KD_NTT_b = 24'd2000000; KD_NTT_w0 = 24'd2048;       KD_NTT_w1 = 24'd2048; #10;
//         KD_NTT_a = 24'd4190208; KD_NTT_b = 24'd2095104; KD_NTT_w0 = 24'd3072;       KD_NTT_w1 = 24'd3072; #10;
//         KD_NTT_a = 24'd8380415; KD_NTT_b = 24'd1;       KD_NTT_w0 = 24'd3326;       KD_NTT_w1 = 24'd3326; #10;
//         KD_NTT_a = 24'd8380416; KD_NTT_b = 24'd7380416; KD_NTT_w0 = 24'd7380416;    KD_NTT_w1 = 24'd7380416; #10;   //
//         KD_NTT_a = 24'd3000000; KD_NTT_b = 24'd5000000; KD_NTT_w0 = 24'd400000;       KD_NTT_w1 = 24'd400000; #10;
//         KD_NTT_a = 24'd6678932; KD_NTT_b = 24'd5625789; KD_NTT_w0 = 24'd99541;       KD_NTT_w1 = 24'd99541; #10;
//         KD_NTT_a = 24'd8380413; KD_NTT_b = 24'd99;       KD_NTT_w0 = 24'd3567213;       KD_NTT_w1 = 24'd3567213; #10;


//         $display("======== KD_NTT模块测试完成 ========");
//         $finish;
//     end

// endmodule
