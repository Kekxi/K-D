module tf_add_gen(
    input clk,rst,
    input [3:0] Run_mode,
    input [6:0] k,
    input [2:0] p,
    input KD_mode,
    output wire [6:0] tf_address
    );
    //需要区分K和D 选择器
    reg [6:0] tf_address_reg_0,tf_address_reg_1;
    wire [6:0] tf_address_tmp;

    //(Run_mode == 4'b0011) --K_4_NTT (Run_mode == 4'b0100)--Done_K_4_NTT (Run_mode == 4'b0101) --D_2_NTT (Run_mode == 4'b0110)--Done_D_2_NTT
    //NTT时--tf_address_reg_0 INTT时--tf_address_reg_1
    assign tf_address_tmp = ((Run_mode == 4'b0011) || (Run_mode == 4'b0100)|| (Run_mode == 4'b0101)|| (Run_mode == 4'b0110)) ? tf_address_reg_0 : tf_address_reg_1; 
    //assign tf_address = ((Run_mode == 4'b0011) || (Run_mode == 4'b0100)|| (Run_mode == 4'b0101)|| (Run_mode == 4'b0110)) ? tf_address_reg_0 : tf_address_reg_1; 
      
    DFF #(.data_width(7)) dff_tf(.clk(clk),.rst(rst),.data_in(tf_address_tmp),.data_out(tf_address));

    wire [6:0] tf_gap_0 = 1 << p; // 0 64 32 16 8 4 2 1
    wire [7:0] tf_gap_1 = (1 << (7 - p)) - 1; // 127 63 31 15 7 3 1 0
    
    always@(*)
    begin
      if(KD_mode) begin //Dilithium
            tf_address_reg_0 = k * tf_gap_0;
            tf_address_reg_1 = (tf_gap_1 - k) * tf_gap_0;
      end else begin //Kyber
            case(p)
               //3:begin tf_address_reg_0 = ; tf_address_reg_1 = ;end     //基2一个阶段 1个旋转因子 直接输入
               2:begin tf_address_reg_0 = k; tf_address_reg_1 = 2 - k;end  // p = 2 k = 0,1    
               1:begin tf_address_reg_0 = k + 2; tf_address_reg_1 = 10 - k;end // p = 1 k = 0,...,7 
               0:begin tf_address_reg_0 = k + 10; tf_address_reg_1 = 41 - k;end // p = 0 k = 0,...,31 
               default:begin tf_address_reg_0 = 0; tf_address_reg_1 = 0; end
            endcase
      end
      
    end
endmodule