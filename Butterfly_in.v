// network_bf_in mux2(
//                       .clk(clk),.rst(rst),
//                       .sel_a_0(sel_a_0),.sel_a_1(sel_a_1),.sel_a_2(sel_a_2),
//                       .sel_a_3(sel_a_3),
//                       .q0(q0),.q1(q1),.q2(q2),.q3(q3),

//                       .u0(u0),.v0(v0),.u1(u1),.v1(v1)); 
//将 4 个输入数据 q0~q3 按照 4 个选择信号 sel_a_x 路由到蝶形单元的 4 个端口 u0, v0, u1, v1，以实现不同阶段或数据重排中的输入调度。
module Butterfly_in (  
    input clk,rst,
    input [1:0] sel_a_0,sel_a_1,sel_a_2,sel_a_3,
    input [11:0] q0,q1,q2,q3,
    //input KD_mode, //此处是将从bank取的四个数作为蝶形运算的输入 不需要区分KD
    output reg [11:0] u0,v0,u1,v1
    );
   
   wire [1:0] sel_a_0_tmp,sel_a_1_tmp,sel_a_2_tmp,sel_a_3_tmp;
   //每个 sel_a_x 先经过一个 D 触发器，意味着输入选择是 打一拍再使用，用于对齐流水线
//    shift_2 #(.data_width(2)) shf2_sel_a_0 (.clk(clk),.rst(rst),.data_in(sel_a_0),.data_out(sel_a_0_tmp));   
//    shift_2 #(.data_width(2)) shf2_sel_a_1 (.clk(clk),.rst(rst),.data_in(sel_a_1),.data_out(sel_a_1_tmp)); 
//    shift_2 #(.data_width(2)) shf2_sel_a_2 (.clk(clk),.rst(rst),.data_in(sel_a_2),.data_out(sel_a_2_tmp)); 
//    shift_2 #(.data_width(2)) shf8_sel_a_3 (.clk(clk),.rst(rst),.data_in(sel_a_3),.data_out(sel_a_3_tmp));

   DFF #(.data_width(2)) dff_sel0(.clk(clk),.rst(rst),.data_in(sel_a_0),.data_out(sel_a_0_tmp));
   DFF #(.data_width(2)) dff_sel1(.clk(clk),.rst(rst),.data_in(sel_a_1),.data_out(sel_a_1_tmp));
   DFF #(.data_width(2)) dff_sel2(.clk(clk),.rst(rst),.data_in(sel_a_2),.data_out(sel_a_2_tmp));
   DFF #(.data_width(2)) dff_sel3(.clk(clk),.rst(rst),.data_in(sel_a_3),.data_out(sel_a_3_tmp));
   
   always@(*)
   begin
        u0 = 11'b0;
        v0 = 11'b0;
        u1 = 11'b0;
        v1 = 11'b0;
        case(sel_a_0_tmp)
        2'b00:u0 = q0; 
        2'b01:v0 = q0;
        2'b10:u1 = q0;
        2'b11:v1 = q0;
        default:;
        endcase
        
        case(sel_a_1_tmp)
        2'b00:u0 = q1;
        2'b01:v0 = q1;
        2'b10:u1 = q1;
        2'b11:v1 = q1;
        default:;
        endcase
        
        case(sel_a_2_tmp)
        2'b000:u0 = q2;
        2'b001:v0 = q2;
        2'b010:u1 = q2;
        2'b011:v1 = q2;
        default:;
        endcase   
        
        case(sel_a_3_tmp)
        2'b00:u0 = q3;
        2'b01:v0 = q3;
        2'b10:u1 = q3;
        2'b11:v1 = q3;
        default:;
        endcase 
    end  
endmodule