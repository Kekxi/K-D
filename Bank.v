// data_bank bank_0(
//                    .clk(clk),
//                    .A1(bank_address_0_dy),
//                    .A2(bank_address_0),
//                    .D(d0),
//                    .IWEN(wen),
//                    .IREN(ren),
//                    .IEN(en),
//                    .Q(q0));
module Bank 
    (
    input clk,
    input [6:0] A1, //bank_address_0_dy 基2或基4延迟后的地址 写
    input [6:0] A2, //bank_address_0  读
    input [11:0] D, //d0
    input IWEN,
    input IREN,
    input IEN,
    output reg [11:0] Q // 从bank中读出的一个系数 下一步送到bf中计算 这样的系数有4个 实例化了4个bank
    );
    (*ram_style = "block"*)reg [11:0] bank [127:0];
    //ram_style = "block" --表示强制使用FPGA的 块RAM（Block RAM） 资源实现该存储器
    //reg [11:0] bank [31:0]--声明一个名为 bank 的存储器
    //数据宽度：每个存储单元12位（[11:0]）
    //深度：128个存储单元（[127:0]，即地址0~127）
    //等效于一个 128×12位 的RAM

    always@(posedge clk)
    begin
      if (IEN == 1)  // IEN = en，它比en_reg变化慢，通过shift延迟周期，保证所有的数都写完？ en_reg = 0时，执行Run_mode_reg中带Done的模式
        begin         
          if(IWEN == 1'b1) //wen--写使能
             bank[A1] <= D;
          else
             bank[A1] <= bank [A1]; //不写
        end
    end
    
    always@(posedge clk)
    begin
      if(IEN == 1)
        begin
          if(IREN == 1'b1)
            Q <= bank[A2];    //A2是 bank_address_0
          else
            Q <= Q;
        end
    end
endmodule




// module Bank (
//     input wire clk,                // 时钟信号
//     input wire rst,                // 复位信号
//     input wire [7:0] addr,         // 8位地址（0~255）
//     input wire [23:0] data_in [0:3], // 4 个 24bit 输入数据
//     input wire wr_en,              // 写使能信号
//     input wire rd_en,              // 读使能信号
//     output reg [23:0] data_out [0:3] // 4 个 24bit 输出数据
// );

//     // 定义 4 个 bank，每个 bank 存储 64 个 24bit 数据
//     reg [23:0] bank_0 [0:63];     // Bank 0
//     reg [23:0] bank_1 [0:63];     // Bank 1
//     reg [23:0] bank_2 [0:63];     // Bank 2
//     reg [23:0] bank_3 [0:63];     // Bank 3

//     // 地址映射逻辑
//     wire [5:0] bank_addr;         // Bank 内地址（0~63）
//     assign bank_addr = addr[7:2]; // 高 6 位决定 bank 内地址

//     // 写操作
//     always @(posedge clk) begin
//         if (rst) begin
//             // 复位时清空所有 bank
//             integer i;
//             for (i = 0; i < 64; i = i + 1) begin
//                 bank_0[i] <= 24'b0;
//                 bank_1[i] <= 24'b0;
//                 bank_2[i] <= 24'b0;
//                 bank_3[i] <= 24'b0;
//             end
//         end else if (wr_en) begin
//             // 同时写入 4 个 bank
//             bank_0[bank_addr] <= data_in[0];
//             bank_1[bank_addr] <= data_in[1];
//             bank_2[bank_addr] <= data_in[2];
//             bank_3[bank_addr] <= data_in[3];
//         end
//     end

//     // 读操作
//     always @(posedge clk) begin
//         if (rd_en) begin
//             // 同时读取 4 个 bank
//             data_out[0] <= bank_0[bank_addr];
//             data_out[1] <= bank_1[bank_addr];
//             data_out[2] <= bank_2[bank_addr];
//             data_out[3] <= bank_3[bank_addr];
//         end else begin
//             // 默认输出 0
//             data_out[0] <= 24'b0;
//             data_out[1] <= 24'b0;
//             data_out[2] <= 24'b0;
//             data_out[3] <= 24'b0;
//         end
//     end

// endmodule