module modular_half #(parameter data_width = 24)(  
    input clk,rst,
    input [data_width-1:0] x_half, //D--q范围内的乘积 K--q范围内的乘积拼接 K需要分两部分乘1/2 再拼起来
    input KD_mode,
    output [data_width-1:0] y_half
    );
    
    localparam  M_K_half = 11'd1665;//  M+1/2  parameter M_K = 12'd3329;
    localparam M_D_half = 22'd4190209;//M+1/2  parameter M_D = 23'd8380417;
    
    wire [22:0] M;//按照位宽大的设置
    assign M = (KD_mode == 0) ? M_K_half : M_D_half;

    //Kyber
    wire [11:0] x_half_H,x_half_L;
    assign x_half_H = x_half[23:12]; //1957
    assign x_half_L = x_half[11:0];  //356

    wire [11:0] x_sh_0,s_0,y_half_0,y_half_0_q1;
    wire c_0;
    assign x_sh_0 = x_half_H >> 1;  //乘1/2
    assign {c_0,s_0} = x_sh_0 + M;  //加上模数一半 这是在约简吗？
    assign y_half_0 = (x_half_H[0] == 1) ? s_0 : x_sh_0;
    //改动 不用DFF-------------------------------------------
    // DFF #(12) dff_y_half_0(.clk(clk),.rst(rst),.data_in(y_half_0),.data_out(y_half_0_q1));

    wire [11:0] x_sh_1,s_1,y_half_1,y_half_1_q1;
    wire c_1;
    assign x_sh_1 = x_half_L >> 1;
    assign {c_1,s_1} = x_sh_1 + M;  //加上模数一半 这是在约简吗？
    assign y_half_1 = (x_half_L[0] == 1) ? s_1 : x_sh_1;
    //改动 不用DFF----------------------------------------
    // DFF #(12) dff_y_half_1(.clk(clk),.rst(rst),.data_in(y_half_1),.data_out(y_half_1_q1));
    
    wire [data_width-1:0] y_half_K;
    // assign y_half_K = {y_half_0_q1,y_half_1_q1};
    assign y_half_K = {y_half_0,y_half_1};
    
    // Dilitnium
    wire [data_width-1:0] x_sh,s,y_half_D,y_half_D_q1;
    wire c;
    assign x_sh = x_half >> 1;
    assign {c,s} = x_sh + M;  //加上模数一半 这是在约简吗？
    assign y_half_D = (x_half[0] == 1) ? s : x_sh;
    //改动 不用DFF----------------------------------------
    // DFF #(24) dff_y_half_D(.clk(clk),.rst(rst),.data_in(y_half_D),.data_out(y_half_D_q1));

    assign y_half = (KD_mode == 0) ?  y_half_K :y_half_D;

endmodule
// module modular_half #(parameter data_width = 256)(
//     input [data_width-1:0] x_half,
//     output [data_width-1:0] y_half
//     );
    
//     parameter M = 12'd3329;
//     parameter M_half = 11'd1665;//M+1/2

//     wire [data_width-1:0] x_sh;
//     wire c;
//     wire [data_width-1:0] s;
    
//     assign x_sh = x_half >> 1;
//     assign {c,s} = x_sh + M_half;
//     assign y_half = x_half[0] == 1? s : x_sh;
// endmodule