// network_bank_in mux1(
//                  .b0(new_address_0),.b1(new_address_1),
//                  .b2(new_address_2),.b3(new_address_3),
//                  .sel_a_0(sel_a_0),.sel_a_1(sel_a_1),
//                  .sel_a_2(sel_a_2),.sel_a_3(sel_a_3),

//                  .new_address_0(bank_address_0),.new_address_1(bank_address_1),
//                  .new_address_2(bank_address_2),.new_address_3(bank_address_3)
//                  );   
module Bank_in ( //从sel_a_? bank里取 new_address_?地址 ---- bank_address_？
    input clk,rst,
    input [6:0] b0,b1,b2,b3,
    input [1:0] sel_a_0,sel_a_1,sel_a_2,sel_a_3,
    output [6:0] new_address_0,new_address_1,new_address_2,new_address_3
    );
    
    always@(*)
    begin
      case(sel_a_0)
        2'b00:new_address_0_reg = b0;
        2'b01:new_address_0_reg = b1;
        2'b10:new_address_0_reg = b2;
        2'b11:new_address_0_reg = b3;
        default:new_address_0_reg = b0;
      endcase
    end
    
    always@(*)
    begin
      case(sel_a_1)
        2'b00:new_address_1_reg = b0;
        2'b01:new_address_1_reg = b1;
        2'b10:new_address_1_reg = b2;
        2'b11:new_address_1_reg = b3;
        default:new_address_1_reg = b0;
      endcase
    end
    
    always@(*)
    begin
      case(sel_a_2)
        2'b00:new_address_2_reg = b0;
        2'b01:new_address_2_reg = b1;
        2'b10:new_address_2_reg = b2;
        2'b11:new_address_2_reg = b3;
        default:new_address_2_reg = b0;
      endcase
    end
    
    always@(*)
    begin
      case(sel_a_3)
        2'b00:new_address_3_reg = b0;
        2'b01:new_address_3_reg = b1;
        2'b10:new_address_3_reg = b2;
        2'b11:new_address_3_reg = b3;
        default:new_address_3_reg = b0;
      endcase
    end
  reg [6:0] new_address_0_reg,new_address_1_reg,new_address_2_reg,new_address_3_reg;
  wire [6:0] new_address_0_r,new_address_1_r,new_address_2_r,new_address_3_r;
  assign new_address_0_r = new_address_0_reg;
  assign new_address_1_r = new_address_1_reg;
  assign new_address_2_r = new_address_2_reg;
  assign new_address_3_r = new_address_3_reg;

  DFF #(7) dff_new_address_0_r(.clk(clk),.rst(rst),.data_in(new_address_0_r),.data_out(new_address_0));
  DFF #(7) dff_new_address_1_r(.clk(clk),.rst(rst),.data_in(new_address_1_r),.data_out(new_address_1));
  DFF #(7) dff_new_address_2_r(.clk(clk),.rst(rst),.data_in(new_address_2_r),.data_out(new_address_2));
  DFF #(7) dff_new_address_3_r(.clk(clk),.rst(rst),.data_in(new_address_3_r),.data_out(new_address_3));

endmodule