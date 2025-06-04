//把系数索引压缩到bank地址范围内 相当于是生成了新的地址和bank索引 此时是有冲突的 还需要进一步将bank处理一下
//对于Kyber 实际有效[6:0]  Dilithium实际有效[8:0]
//问题： 如果D用512算 应该不行吧？ 实际两组蝶形 取到的不是一组D的系数 
// 好像又行 每次运算的四个系数确定了 只是把他们换个位置 再无冲突取到而已
module Bank_address_mapping(
    input clk,rst,
    input KD_mode, //  0--Kyber 1--Dilithium 将Kyber和Dilithium区分开 内存映射就是两套思路
    //对于Kyber 128= 2^7 7bit位宽 
    //对于Dilithium N= 256 24bit位宽 相当于512个12bit的点  512 = 2^9  可能需要改位宽
    input [7:0] old_add_0,
    input [7:0] old_add_1,
    input [7:0] old_add_2,
    input [7:0] old_add_3,
    // input [8:0] old_add_0,  
    // input [8:0] old_add_1,
    // input [8:0] old_add_2,
    // input [8:0] old_add_3,
    // bank address for read 
    //对于Kyber 128（12bit）/4 = 32 = 2^5 5bit位宽 
    //对于Dilithium 256（24bit）/2 = 128 = 2^7 7bit位宽 根据大的设置
    output wire [6:0] new_address_0, 
    output wire [6:0] new_address_1,
    output wire [6:0] new_address_2,
    output wire [6:0] new_address_3,

    //bank index
    output wire [1:0] bank_number_0,
    output wire [1:0] bank_number_1,
    output wire [1:0] bank_number_2,
    output wire [1:0] bank_number_3);
    
    reg [6:0] new_address_0_tmp; //对Kyber有效[4:0]
    reg [6:0] new_address_1_tmp;
    reg [6:0] new_address_2_tmp;
    reg [6:0] new_address_3_tmp;

    reg [1:0] bank_number_0_tmp;
    reg [1:0] bank_number_1_tmp;
    reg [1:0] bank_number_2_tmp;
    reg [1:0] bank_number_3_tmp; 

    always@(*) begin
        if(KD_mode) begin   //Dilithium 
             //BA操作 
             new_address_0_tmp = old_add_0[7:1];  //相当于256个数 两个bank里无冲突映射 剩下256复制即可
             new_address_1_tmp = old_add_1[7:1];  // new_address_1_tmp = new_address_0_tmp 
             new_address_2_tmp = old_add_2[7:1];  //相当于256个数 两个bank里无冲突映射 剩下256复制即可
             new_address_3_tmp = old_add_3[7:1];  // new_address_3_tmp = new_address_3_tmp                                                  
             // BI操作
             bank_number_0_tmp = (old_add_0[7] + old_add_0[6] + old_add_0[5] + old_add_0[4] + old_add_0[3] + old_add_0[2] + old_add_0[1] + old_add_0[0]) % 2;
             bank_number_1_tmp = {1'b1,bank_number_0_tmp[0]};        
             bank_number_2_tmp = (old_add_2[7] + old_add_2[6] + old_add_2[5] + old_add_2[4] + old_add_2[3] + old_add_2[2] + old_add_2[1] + old_add_2[0]) % 2;   
             bank_number_3_tmp = {1'b1,bank_number_2_tmp[0]};   
        end 
        else begin   //Kyber
             //BA操作
             new_address_0_tmp = old_add_0[6:2];    
             new_address_1_tmp = old_add_1[6:2];
             new_address_2_tmp = old_add_2[6:2];
             new_address_3_tmp = old_add_3[6:2];    
             // BI操作
             bank_number_0_tmp = old_add_0[6] + old_add_0[5:4] + old_add_0[3:2] + old_add_0[1:0];
             bank_number_1_tmp = old_add_1[6] + old_add_1[5:4] + old_add_1[3:2] + old_add_1[1:0];        
             bank_number_2_tmp = old_add_2[6] + old_add_2[5:4] + old_add_2[3:2] + old_add_2[1:0];    
             bank_number_3_tmp = old_add_3[6] + old_add_3[5:4] + old_add_3[3:2] + old_add_3[1:0]; 
        end
    end

    DFF #(.data_width(2)) dff_n0(.clk(clk),.rst(rst),.data_in(bank_number_0_tmp),.data_out(bank_number_0)); 
    DFF #(.data_width(2)) dff_n1(.clk(clk),.rst(rst),.data_in(bank_number_1_tmp),.data_out(bank_number_1));
    DFF #(.data_width(2)) dff_n2(.clk(clk),.rst(rst),.data_in(bank_number_2_tmp),.data_out(bank_number_2));
    DFF #(.data_width(2)) dff_n3(.clk(clk),.rst(rst),.data_in(bank_number_3_tmp),.data_out(bank_number_3));                                                                                                                                        
    
    DFF #(.data_width(7)) dff_m0(.clk(clk),.rst(rst),.data_in(new_address_0_tmp),.data_out(new_address_0)); 
    DFF #(.data_width(7)) dff_m1(.clk(clk),.rst(rst),.data_in(new_address_1_tmp),.data_out(new_address_1));
    DFF #(.data_width(7)) dff_m2(.clk(clk),.rst(rst),.data_in(new_address_2_tmp),.data_out(new_address_2));
    DFF #(.data_width(7)) dff_m3(.clk(clk),.rst(rst),.data_in(new_address_3_tmp),.data_out(new_address_3));
endmodule






// module Bank_address_mapping #(
//     parameter N = 128,  // 128 for Kyber, 256 for Dilithium
//     parameter NUM_BANKS = 4
// ) (
//     input wire clk,
//     input wire rst_n,
//     input wire start_ntt,
//     input wire start_intt,
//     output reg [7:0] bank_addr [NUM_BANKS][N]  // 4 Banks each holding up to N addresses
// );

//     integer i, stage;
//     integer log2_N;
//     reg [7:0] ntt_bank_addr [NUM_BANKS][N];  // 临时存储NTT模式的bank地址

//     function automatic [7:0] reverse_bits;
//         input [7:0] num;
//         input integer bit_length;
//         integer j;
//         begin
//             reverse_bits = 0;
//             for (j = 0; j < bit_length; j = j + 1) begin
//                 reverse_bits = (reverse_bits << 1) | (num[j]);
//             end
//         end
//     endfunction

//     always @(posedge clk or negedge rst_n) begin
//         if (!rst_n) begin
//             // 复位所有存储
//             for (i = 0; i < N; i = i + 1) begin
//                 bank_addr[0][i] <= 0;
//                 bank_addr[1][i] <= 0;
//                 bank_addr[2][i] <= 0;
//                 bank_addr[3][i] <= 0;
//             end
//         end 
//         else if (start_ntt) begin
//             // 计算log2_N
//             log2_N = 0;
//             while ((1 << log2_N) < N) log2_N = log2_N + 1;
            
//             // 计算NTT模式地址
//             if (N == 128) begin
//                 // Kyber 模式
//                 for (i = 0; i < N; i = i + 1) begin
//                     bank_addr[i / 32][i] = i;
//                 end
//                 // 基4阶段
//                 for (stage = 0; stage < (log2_N - 1) / 2; stage = stage + 1) begin
//                     integer block_size, half_block, quarter_block;
//                     block_size = 1 << (2 * (stage + 1));
//                     half_block = block_size >> 1;
//                     quarter_block = block_size >> 2;
//                     for (i = 0; i < N; i = i + 1) begin
//                         if ((i % block_size) < quarter_block) bank_addr[0][i] = i;
//                         else if ((i % block_size) < half_block) bank_addr[1][i] = i;
//                         else if ((i % block_size) < (3 * quarter_block)) bank_addr[2][i] = i;
//                         else bank_addr[3][i] = i;
//                     end
//                 end
//             end 
//             else if (N == 256) begin
//                 // Dilithium 模式
//                 for (stage = 0; stage < log2_N; stage = stage + 1) begin
//                     integer stride;
//                     stride = 1 << (stage + 1);
//                     for (i = 0; i < N; i = i + 1) begin
//                         if ((i % stride) < (stride >> 1)) begin
//                             bank_addr[0][i] = i;
//                             bank_addr[1][i] = i;
//                         end else begin
//                             bank_addr[2][i] = i;
//                             bank_addr[3][i] = i;
//                         end
//                     end
//                 end
//             end
//         end 
//         else if (start_intt) begin
//             // 计算 INTT 模式
//             if (N == 128) begin
//                 // 基2阶段
//                 for (i = 0; i < N; i = i + 1) begin
//                     bank_addr[i / 32][i] = reverse_bits(i, log2_N);
//                 end
//                 // 基4阶段
//                 for (stage = 0; stage < (log2_N - 1) / 2; stage = stage + 1) begin
//                     if (stage == 0) begin
//                         for (i = 0; i < N; i = i + 1) bank_addr[0][i] = ntt_bank_addr[2][i];
//                     end else if (stage == 1) begin
//                         for (i = 0; i < N; i = i + 1) bank_addr[1][i] = ntt_bank_addr[1][i];
//                     end else if (stage == 2) begin
//                         for (i = 0; i < N; i = i + 1) bank_addr[2][i] = ntt_bank_addr[0][i];
//                     end
//                 end
//             end 
//             else if (N == 256) begin
//                 for (stage = 0; stage < log2_N; stage = stage + 1) begin
//                     integer stride;
//                     stride = 1 << (stage + 1);
//                     for (i = 0; i < N; i = i + 1) begin
//                         if ((i % stride) < (stride >> 1)) begin
//                             bank_addr[0][i] = reverse_bits(i, log2_N);
//                             bank_addr[1][i] = reverse_bits(i, log2_N);
//                         end else begin
//                             bank_addr[2][i] = reverse_bits(i, log2_N);
//                             bank_addr[3][i] = reverse_bits(i, log2_N);
//                         end
//                     end
//                 end
//             end
//         end
//     end
// endmodule
