module Butterfly_out #(parameter data_width = 12)(
    input clk,rst,
    input sel_0, //基2--0，基4--1 不需要区分K和D吗？
    input [data_width-1:0] bf_0_upper,bf_0_lower,bf_1_upper,bf_1_lower,
    input [1:0] sel_a_0,sel_a_1,sel_a_2,sel_a_3,
    output reg [data_width-1:0] d0,d1,d2,d3
    );  
    
    wire [1:0] sel_a_0_out,sel_a_1_out,sel_a_2_out,sel_a_3_out;
    wire [1:0] sel_a_0_out_reg_s,sel_a_1_out_reg_s,sel_a_2_out_reg_s,sel_a_3_out_reg_s;
    wire [1:0] sel_a_0_out_reg_i,sel_a_1_out_reg_i,sel_a_2_out_reg_i,sel_a_3_out_reg_i;
    // K_2_NTT 算了7个周期 加上 最开始 bf_in DFF的1个周期 所以bf_out 回写 移动8个周期！
    shift_8 #(.data_width(2)) shif1 (.clk(clk),.rst(rst),.data_in(sel_a_0),.data_out(sel_a_0_out_reg_s));
    shift_8 #(.data_width(2)) shif2 (.clk(clk),.rst(rst),.data_in(sel_a_1),.data_out(sel_a_1_out_reg_s));
    shift_8 #(.data_width(2)) shif3 (.clk(clk),.rst(rst),.data_in(sel_a_2),.data_out(sel_a_2_out_reg_s));
    shift_8 #(.data_width(2)) shif4 (.clk(clk),.rst(rst),.data_in(sel_a_3),.data_out(sel_a_3_out_reg_s));

    shift_16 #(.data_width(2)) shif5 (.clk(clk),.rst(rst),.data_in(sel_a_0),.data_out(sel_a_0_out_reg_i));
    shift_16 #(.data_width(2)) shif6 (.clk(clk),.rst(rst),.data_in(sel_a_1),.data_out(sel_a_1_out_reg_i));
    shift_16 #(.data_width(2)) shif7 (.clk(clk),.rst(rst),.data_in(sel_a_2),.data_out(sel_a_2_out_reg_i));
    shift_16 #(.data_width(2)) shif8 (.clk(clk),.rst(rst),.data_in(sel_a_3),.data_out(sel_a_3_out_reg_i));
 
    assign sel_a_0_out = sel_0 == 0 ? sel_a_0_out_reg_s :sel_a_0_out_reg_i;
    assign sel_a_1_out = sel_0 == 0 ? sel_a_1_out_reg_s :sel_a_1_out_reg_i;
    assign sel_a_2_out = sel_0 == 0 ? sel_a_2_out_reg_s :sel_a_2_out_reg_i;
    assign sel_a_3_out = sel_0 == 0 ? sel_a_3_out_reg_s :sel_a_3_out_reg_i;

    always@(*)
    begin
      case(sel_a_0_out)
      2'b00:d0 = bf_0_lower;
      2'b01:d0 = bf_0_upper;
      2'b10:d0 = bf_1_lower;
      2'b11:d0 = bf_1_upper;
      default:;
      endcase
    end
    
    always@(*)
    begin
      case(sel_a_1_out)
      2'b00:d1 = bf_0_lower;
      2'b01:d1 = bf_0_upper;
      2'b10:d1 = bf_1_lower;
      2'b11:d1 = bf_1_upper;
      default:;
      endcase
    end    
    
    always@(*)
    begin
      case(sel_a_2_out)
      2'b00:d2 = bf_0_lower;
      2'b01:d2 = bf_0_upper;
      2'b10:d2 = bf_1_lower;
      2'b11:d2 = bf_1_upper;
      default:;
      endcase
    end                       

    always@(*)
    begin
      case(sel_a_3_out)
      2'b00:d3 = bf_0_lower;
      2'b01:d3 = bf_0_upper;
      2'b10:d3 = bf_1_lower;
      2'b11:d3 = bf_1_upper;
      default:;
      endcase
    end
    
endmodule