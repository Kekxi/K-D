`timescale 1ns / 1ps
 //一定要考虑好每个位置对应的w值，可能会有所不同
 //状态机设置，避免执行各个模块的额外消耗
module KD_top(
    // input [23:0] KD_NTT_a,KD_NTT_b,KD_NTT_w0,KD_NTT_w1,  
    // input KD_NTT_mode0, KD_NTT_mode1, //输入信号 KD_NTT_mode0 -- 0为Kyber & 1为Dilithium, KD_NTT_mode1 -- 0为NTT & 1为INTT
    //// 可能需要input 状态机需要的输入 conf
    input clk,rst,
    input [3:0] Run_mode,
    input KD_mode, // 0--Kyber 1--Dilithium
    output [1:0] done_flag
    

    );
    wire [4:0] i;
    wire [6:0] k,j;
    wire [2:0] p;
    wire sel_0,sel_1,wen,ren,en;
    wire [7:0] old_add_0,old_add_1,old_add_2,old_add_3;
    wire [6:0] new_address_0,new_address_1,new_address_2,new_address_3;
    wire [1:0] bank_number_0,bank_number_1,bank_number_2,bank_number_3;
    wire [1:0] sel_a_0,sel_a_1,sel_a_2,sel_a_3;
    wire [6:0] bank_address_0_dy_reg_s,bank_address_1_dy_reg_s,bank_address_2_dy_reg_s,bank_address_3_dy_reg_s;
    wire [6:0] bank_address_0_dy_reg_i,bank_address_1_dy_reg_i,bank_address_2_dy_reg_i,bank_address_3_dy_reg_i;
    wire [6:0] bank_address_0_dy,bank_address_1_dy,bank_address_2_dy,bank_address_3_dy;
    wire [6:0] bank_address_0,bank_address_1,bank_address_2,bank_address_3;
    wire [11:0] d0,d1,d2,d3;
    wire [11:0] q0,q1,q2,q3;
    wire [11:0] u0,v0,u1,v1;
    wire [6:0] tf_address;
    wire [35:0] w;  
    wire [11:0] win1,win2,win3;
    wire [11:0] bf_0_upper, bf_0_lower, bf_1_upper, bf_1_lower;


   (*DONT_TOUCH = "true"*) 
    FSM m1(
        .clk(clk),
        .rst(rst),
        .Run_mode(Run_mode),
        .KD_mode(KD_mode),

        .sel_0(sel_0),
        .sel_1(sel_1),
        .i(i),
        .k(k),
        .j(j),
        .p(p),
        .done_flag(done_flag),
        .wen(wen),
        .ren(ren),
        .en(en)
    );
    

  (*DONT_TOUCH = "true"*) 
    Add_gen m2(
               .KD_mode(KD_mode),
               .i(i),
               .j(j),
               .k(k),
               .stage(p),    

               .old_add_0(old_add_0),.old_add_1(old_add_1),
               .old_add_2(old_add_2),.old_add_3(old_add_3));

  (*DONT_TOUCH = "true"*) 
   Bank_address_mapping map(
              .clk(clk),
              .rst(rst),
              .KD_mode(KD_mode),
              .old_add_0(old_add_0),.old_add_1(old_add_1),
              .old_add_2(old_add_2),.old_add_3(old_add_3),

              .new_address_0(new_address_0),
              .new_address_1(new_address_1),
              .new_address_2(new_address_2),
              .new_address_3(new_address_3),
              .bank_number_0(bank_number_0),
              .bank_number_1(bank_number_1),
              .bank_number_2(bank_number_2),
              .bank_number_3(bank_number_3));    

  (*DONT_TOUCH = "true"*) 
  Arbiter m3(
             .a0(bank_number_0),.a1(bank_number_1),
             .a2(bank_number_2),.a3(bank_number_3),
             .sel_a_0(sel_a_0),.sel_a_1(sel_a_1),
             .sel_a_2(sel_a_2),.sel_a_3(sel_a_3)); 


  (*DONT_TOUCH = "true"*) 
  Bank_in mux1(
             .clk(clk),.rst(rst),
             .b0(new_address_0),.b1(new_address_1),
             .b2(new_address_2),.b3(new_address_3),
             .sel_a_0(sel_a_0),.sel_a_1(sel_a_1),
             .sel_a_2(sel_a_2),.sel_a_3(sel_a_3),
             .new_address_0(bank_address_0),.new_address_1(bank_address_1),
             .new_address_2(bank_address_2),.new_address_3(bank_address_3)
             );   


  shift_8 #(.data_width(7)) shf1 (.clk(clk),.rst(rst),.data_in(bank_address_0),.data_out(bank_address_0_dy_reg_s));   
  shift_8 #(.data_width(7)) shf2 (.clk(clk),.rst(rst),.data_in(bank_address_1),.data_out(bank_address_1_dy_reg_s)); 
  shift_8 #(.data_width(7)) shf3 (.clk(clk),.rst(rst),.data_in(bank_address_2),.data_out(bank_address_2_dy_reg_s)); 
  shift_8 #(.data_width(7)) shf4 (.clk(clk),.rst(rst),.data_in(bank_address_3),.data_out(bank_address_3_dy_reg_s));     

  shift_16 #(.data_width(7)) shf5 (.clk(clk),.rst(rst),.data_in(bank_address_0),.data_out(bank_address_0_dy_reg_i));   
  shift_16 #(.data_width(7)) shf6 (.clk(clk),.rst(rst),.data_in(bank_address_1),.data_out(bank_address_1_dy_reg_i)); 
  shift_16 #(.data_width(7)) shf7 (.clk(clk),.rst(rst),.data_in(bank_address_2),.data_out(bank_address_2_dy_reg_i)); 
  shift_16 #(.data_width(7)) shf8 (.clk(clk),.rst(rst),.data_in(bank_address_3),.data_out(bank_address_3_dy_reg_i));     

  assign bank_address_0_dy = sel_0 == 0 ?  bank_address_0_dy_reg_s :bank_address_0_dy_reg_i;  //根据基2或基4确定延迟多久
  assign bank_address_1_dy = sel_0 == 0 ?  bank_address_1_dy_reg_s :bank_address_1_dy_reg_i;
  assign bank_address_2_dy = sel_0 == 0 ?  bank_address_2_dy_reg_s :bank_address_2_dy_reg_i;
  assign bank_address_3_dy = sel_0 == 0 ?  bank_address_3_dy_reg_s :bank_address_3_dy_reg_i;
    
  (*DONT_TOUCH = "true"*) 
  //DONT_TOUCH = "true"---强制综合工具 保留该模块的完整逻辑结构，禁止对其进行任何优化或重构
  //过度使用会导致资源浪费 综合后检查是否真的需要该约束
  Bank bank_0(
                   .clk(clk),
                   .A1(bank_address_0_dy), //写
                   .A2(bank_address_0),    //读
                   .D(d0),
                   .IWEN(wen),
                   .IREN(ren),
                   .IEN(en),

                   .Q(q0));

  (*DONT_TOUCH = "true"*)          
  Bank bank_1(
                   .clk(clk),
                   .A1(bank_address_1_dy),
                   .A2(bank_address_1),
                   .D(d1),
                   .IWEN(wen),
                   .IREN(ren),
                   .IEN(en),

                   .Q(q1));

  (*DONT_TOUCH = "true"*)              
 Bank bank_2(
                   .clk(clk),
                   .A1(bank_address_2_dy),
                   .A2(bank_address_2),
                   .D(d2),
                   .IWEN(wen),
                   .IREN(ren),
                   .IEN(en),

                   .Q(q2));  

  (*DONT_TOUCH = "true"*)         
  Bank bank_3(
                   .clk(clk),
                   .A1(bank_address_3_dy),
                   .A2(bank_address_3),
                   .D(d3),
                   .IWEN(wen),
                   .IREN(ren),
                   .IEN(en),

                   .Q(q3));

  (*DONT_TOUCH = "true"*) 
   Butterfly_in mux2(
                      .clk(clk),.rst(rst),
                      .sel_a_0(sel_a_0),.sel_a_1(sel_a_1),.sel_a_2(sel_a_2),
                      .sel_a_3(sel_a_3),
                      .q0(q0),.q1(q1),.q2(q2),.q3(q3),

                      .u0(u0),.v0(v0),.u1(u1),.v1(v1)); 
   //没有这个 (*DONT_TOUCH = "true"*)
   tf_add_gen m_tf(
               .clk(clk),.rst(rst),
               .Run_mode(Run_mode),
               .k(k),
               .p(p),
               .KD_mode(KD_mode),

               .tf_address(tf_address)); 
  (*DONT_TOUCH = "true"*) 
   tf_ROM rom0(          //旋转因子提前算好了 已经直接存在ROM中了
               .clk(clk),
               .A(tf_address),
               .IREN(ren),
               .KD_mode(KD_mode),

               .Q(w));

  assign win1 = w[35:24]; //Dilithium 全为0 只有24位有效
  assign win2 = w[23:12];
  assign win3 = w[11:0];
                                 
  (*DONT_TOUCH = "true"*)  
   compact_bf bf(         //需要改动
           .clk(clk),
           .rst(rst),
           .u0(u0),.v0(v0),.u1(u1),.v1(v1),   //注意区别！
          //  .u0(u0),.v0(u1),.u1(v0),.v1(v1),   //注意区别！
           .wa1(win1),.wa2(win2),.wa3(win3),  //.win1(win1),.win2(win2),.win3(win3),  不行吗？这样设计有什么考虑吗？
           .sel_0(sel_0),
           .sel_1(sel_1), 
           .KD_mode(KD_mode),

           .bf_0_upper(bf_0_upper),.bf_0_lower(bf_0_lower),
           .bf_1_upper(bf_1_upper),.bf_1_lower(bf_1_lower)); 

  (*DONT_TOUCH = "true"*) 
  Butterfly_out mux4(
                       .clk(clk),.rst(rst),
                       .sel_0(sel_0),
                       .bf_0_upper(bf_0_upper),.bf_0_lower(bf_0_lower),
                       .bf_1_upper(bf_1_upper),.bf_1_lower(bf_1_lower),
                       .sel_a_0(sel_a_0),.sel_a_1(sel_a_1),
                       .sel_a_2(sel_a_2),
                       .sel_a_3(sel_a_3),

                       .d0(d0),.d1(d1),.d2(d2),.d3(d3));  

endmodule
