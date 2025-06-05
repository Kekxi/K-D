module FSM(
  input clk,rst,
  input [3:0] Run_mode,  //实际在运行的模式，提前用parameter 定义好了 ，在测试文件中输入
  input KD_mode,        // 0--Kyber 1--Dilithium 在mode.v中生成的KD_NTT_mode0信号是一样的

  output wire sel_0,  // 0--基2  1--基4
  output wire sel_1,  // 0--NTT  1--INTT  在mode.v中生成的KD_NTT_mode1信号是一样的
  output wire [4:0] i, 
  output wire [6:0] k, 
  output wire [6:0] j, 
  output wire [2:0] p, 
  output wire [2:0] done_flag,
  output wire wen,
  output wire ren,
  output wire en); //确定所有位宽！ 写完后检查一下

  reg [4:0] i_reg;
  reg [7:0] k_reg,j_reg;
  reg [2:0] p_reg;
  reg [3:0] done_reg;
  assign i = i_reg;
  assign j = j_reg;
  assign k = k_reg;
  assign p = p_reg;
  assign done_flag = done_reg;

  //此处不用mode.v生成，直接定义更加简洁
  parameter IDLE = 4'b0000;
  parameter K_NTT_Radix2 = 4'b0001; 
  parameter DONE_K_NTT_Radix2 = 4'b0010;
  parameter K_NTT_Radix4 = 4'b0011;
  parameter DONE_K_NTT_Radix4 = 4'b0100;
  parameter D_NTT_Radix2 = 4'b0101;
  parameter DONE_D_NTT_Radix2 = 4'b0110;
  parameter K_INTT_Radix2 = 4'b0111;
  parameter DONE_K_INTT_Radix2 = 4'b1000;
  parameter K_INTT_Radix4 = 4'b1001;
  parameter DONE_K_INTT_Radix4 = 4'b1010;
  parameter D_INTT_Radix2 = 4'b1011;
  parameter DONE_D_INTT_Radix2 = 4'b1100;

  reg en_reg,wen_reg,ren_reg;
  wire en_reg_dout_tmp;
  //DFF触发器，clk上升沿时，将data_in信号赋值给data_out
  DFF #(.data_width(1)) dff_en(.clk(clk),.rst(rst),.data_in(en_reg),.data_out(en_reg_dout_tmp)); // en_reg
  DFF #(.data_width(1)) dff_ren(.clk(clk),.rst(rst),.data_in(ren_reg),.data_out(ren));

//时钟分频       sel_0 = 0, clk_en = 1;clk_c = 0;

  wire wen_K2,en_reg_K2,wen_K4,en_reg_K4;
  shift_9 #(.data_width(1)) shift_9_wen_K2(.clk(clk),.rst(rst),.data_in(wen_reg),.data_out(wen_K2)); //radix-2 ntt 写使能
  shift_10 #(.data_width(1)) shift_10_en_K2(.clk(clk),.rst(rst),.data_in(en_reg_dout_tmp),.data_out(en_reg_K2));//控制radix-2开始
  shift_17 #(.data_width(1)) shift_17_wen_K4(.clk(clk),.rst(rst),.data_in(wen_reg),.data_out(wen_K4)); //radix-4 ntt 写使能 
  shift_12 #(.data_width(1)) shift_12_en_K4(.clk(clk),.rst(rst),.data_in(en_reg_dout_tmp),.data_out(en_reg_K4)); //控制radix-4开始

  assign wen = (sel_0 == 0) ? wen_K2 : wen_K4; //NTT INTT 写使能
  assign en_reg_dout = (sel_0 == 0) ? en_reg_K2 : en_reg_K4;
  assign en = ((Run_mode == DONE_K_NTT_Radix2) ||
               (Run_mode == DONE_K_NTT_Radix4) ||
               (Run_mode == DONE_K_INTT_Radix2) ||
               (Run_mode == DONE_K_INTT_Radix4) ||
               (Run_mode == DONE_D_NTT_Radix2) ||
               (Run_mode == DONE_D_INTT_Radix2)) ? en_reg_dout : en_reg_dout_tmp; //改动过 加了D进去 不确定对否

  reg sel_0_reg; //基2 基4
  reg sel_1_reg; // NTT INTT
  DFF #(.data_width(1)) dff_sel_0(.clk(clk),.rst(rst),.data_in(sel_0_reg),.data_out(sel_0)); 
  DFF #(.data_width(1)) dff_sel_1(.clk(clk),.rst(rst),.data_in(sel_1_reg),.data_out(sel_1)); 

  reg [3:0] Run_mode_reg;
  always@(posedge clk or posedge rst)  //跟DFF没什么不同吧？ 在clk上升沿时 将Run_mode存到Run_mode_reg
    begin
      if(rst) //前7#
        Run_mode_reg <= IDLE;
      else 
        Run_mode_reg <= Run_mode;  
        // #15  Run_mode=1  #334 Run_mode=2  #335（上升沿） Run_mode_reg才变2 #444 Run_mode=3 #445 Run_mode_reg=3
    end

  always@(*)
  begin
    //初始化
    sel_0_reg = 0;  // 0--NTT 1--INTT 
    sel_1_reg = 0;  //0--基2 1--基4  
    en_reg = 0; 
    wen_reg = 0;
    ren_reg = 0; 
    done_reg = 3'b0;
    
    case(Run_mode_reg) // #15
    IDLE:begin 
        sel_0_reg = 0; // 0--NTT 1--INTT  
        sel_1_reg = 0; //0--基2 1--基4  
        en_reg  = 0; 
        wen_reg = 0;
        ren_reg = 0; 
        done_reg = 3'b0;
        end
    K_NTT_Radix2:begin   //基2 1个阶段
        sel_0_reg = 0;   // 0--基2 1--基4   
        sel_1_reg = 0;   // 0--NTT 1--INTT
        en_reg = 1; 
        wen_reg = 1;
        ren_reg = 1;
        if(i_reg == 5'd31)
           done_reg = 3'b001;
        else
           done_reg = 3'b0;
        end
    DONE_K_NTT_Radix2:begin 
         sel_0_reg = 0;   //radix-2
         sel_1_reg = 0;   //NTT
         en_reg = 0;
         wen_reg = 0;
         ren_reg = 0; 
        end
    K_NTT_Radix4:begin  // 基4 3个阶段
        sel_0_reg = 1;   //radix-4
        sel_1_reg = 0;   //NTT
        en_reg = 1; 
        wen_reg = 1;
        ren_reg = 1;
        if((p_reg == 0)&&(k_reg == 31)&&(j_reg == 0))begin  //说明执行完毕
           done_reg = 3'b010; 
        end
        else begin
           done_reg = 3'b0; 
        end
        end
    DONE_K_NTT_Radix4:begin 
         sel_0_reg = 1;   //radix-4
         sel_1_reg = 0;   //NTT
         en_reg = 0;
         wen_reg = 0;
         ren_reg = 0; 
        end
    K_INTT_Radix4:begin // 基4 3个阶段
        sel_0_reg = 1;   //radix-4
        sel_1_reg = 1;   //INTT
        en_reg = 1; 
        wen_reg = 1;
        ren_reg = 1;
        if((p_reg == 2)&&(k_reg == 0)&&(j_reg == 31))begin
          done_reg = 3'b011; 
        end
        else begin
          done_reg = 3'b0; 
        end
        end
    DONE_K_INTT_Radix4:begin 
         sel_0_reg = 1;    //radix-4
         sel_1_reg = 1;    //INTT
         en_reg = 0;
         wen_reg = 0;
         ren_reg = 0; 
        end
    K_INTT_Radix2:begin //基2 1个阶段 
        sel_0_reg = 0;   //radix-2
        sel_1_reg = 1;   //INTT
        en_reg = 1; 
        wen_reg = 1;
        ren_reg = 1;
        //
         if(i_reg == 5'd31)
           done_reg = 3'b100;
         else
           done_reg = 3'b0;
        end
    DONE_K_INTT_Radix2:begin 
         sel_0_reg = 0; //radix-2
         sel_1_reg = 1; //INTT
         en_reg = 0;
         wen_reg = 0;
         ren_reg = 0; 
        end
    // Dilithium     
    D_NTT_Radix2:begin //基2 8个阶段
         sel_0_reg = 0;   //radix-2
         sel_1_reg = 0;   //NTT
         en_reg = 1; 
         wen_reg = 1;
         ren_reg = 1;
         //改
         if((p_reg == 2)&&(k_reg == 0)&&(j_reg == 31))begin
           done_reg = 3'b011; end
         else begin
           done_reg = 3'b0; end
         end
    DONE_D_NTT_Radix2:begin 
         sel_0_reg = 0;   //radix-2
         sel_1_reg = 0;   //NTT
         en_reg = 0;
         wen_reg = 0;
         ren_reg = 0; 
        end
    D_INTT_Radix2:begin  //基2 8个阶段
         sel_0_reg = 0;   //radix-2
         sel_1_reg = 1;   //INTT
         en_reg = 1; 
         wen_reg = 1;
         ren_reg = 1;
         //改
         if((p_reg == 0)&&(k_reg == 31)&&(j_reg == 0))begin
           done_reg = 3'b010; end
         else begin
           done_reg = 3'b0; end
         end
    DONE_D_INTT_Radix2:begin 
         sel_0_reg = 0; //radix-2
         sel_1_reg = 1; //INTT
         en_reg = 0;
         wen_reg = 0;
         ren_reg = 0; 
        end

    default:begin 
         sel_0_reg = 0; 
         sel_1_reg = 0;
         done_reg = 2'b0;
         en_reg = 0;
         wen_reg = 0;
         ren_reg = 0; 
         end
     endcase
  end
  
 reg [2:0] end_stage,begin_stage;
 reg [3:0] p_shift;
 //p_reg[2:0] 位宽3bit
 always@(posedge clk)
 begin 
  if(KD_mode)begin  //KD_mode = 1 -- Dilithium
    begin_stage = (Run_mode == D_NTT_Radix2) ? 7 : 0;  //只要不是D_NTT_Radix2 其他模式 begin_stage = 0
    end_stage = (Run_mode == D_NTT_Radix2) ? 0 : 7;
    p_shift = p_reg; // 111 = 7
  end else begin //KD_mode = 0 -- Kyber
    begin_stage = (Run_mode == K_NTT_Radix4) ? 2 : 0; // 2--010
    end_stage = (Run_mode == K_NTT_Radix4) ? 0 : 2;
    p_shift = p_reg << 1; // 100 = 4     10 = 2   00 = 0
  end
 end 
 
  always@(posedge clk or posedge rst)begin 
       if(rst) begin //7#
           p_reg <= begin_stage;
           j_reg <= 0;
           k_reg <= 0;
           i_reg <= 0;
       end 
       else if((Run_mode_reg == K_NTT_Radix2) || (Run_mode_reg == K_INTT_Radix2)) begin
           i_reg <= i_reg + 1;
       end
       else if((Run_mode == K_NTT_Radix2) || (Run_mode == K_INTT_Radix2)) begin// 基2_K 先走一次这个判断语句 Run_mode比Run_mode_reg先赋值
           p_reg <= 3'b011; //#7后的第一个上升沿#15开始 p_reg变为3  为什么不是在#9就开始变呢？ Run_mode在#9就变K_NTT_Radix2 p_reg不应该跟着立刻变化吗？
       end
       else if((Run_mode_reg == K_NTT_Radix4) || (Run_mode_reg == K_INTT_Radix4)) begin
          if(j_reg == (1 << (p_shift)) - 1) begin 
            // 1 << 4 -1 = 10000 - 1 = 15  reg [7:0] k_reg,j_reg; 8bit位宽 
            //  1 << 2 -1 = 3
            // 1 << 0 -1 = 0
             j_reg <= 0;
             if(k_reg == (32 >> p_shift) - 1) begin 
                //100000 >> 4 -1  = 10 - 1 = 1
                //100000 >> 2 -1  = 7
                //100000 >> 0 -1  = 31
                k_reg <= 0;
                if(p_reg == end_stage) // end_stage只要在 K_NTT_Radix4 就是0
                     p_reg <= begin_stage; 
                else begin
                    if(Run_mode_reg == K_INTT_Radix4)
                       p_reg <= p_reg + 1;
                    else
                       p_reg <= p_reg - 1;
                end
             end
             else
                k_reg <= k_reg + 1;
           end
           else
              j_reg <= j_reg + 1;
       end
           
       // Dilithium 基2 8个阶段
       else if((Run_mode_reg == D_NTT_Radix2) || (Run_mode_reg == D_INTT_Radix2)) begin
           // 当前阶段p_reg的范围是7到0（共8个阶段）
           // p_shift = p_reg << 1（即p_shift = 2*p_reg）
      
            // j计数器逻辑：每个k值下j从0计数到(1<<p_shift)-1
           if(j_reg == (1 << p_shift) - 1) begin  
               // 当j达到当前阶段最大值时 1<<7-1 = 127
               j_reg <= 0; // j归零
             
               // k计数器逻辑：每个p阶段k从0计数到(128>>p_shift)-1
               if(k_reg == (128 >> p_shift) - 1) begin
                   // 当k达到当前阶段最大值时
                   k_reg <= 0; // k归零
                   // p阶段切换逻辑
                   if(p_reg == end_stage) begin
                       // 如果完成所有阶段（p=0）
                       p_reg <= begin_stage; // 回到初始阶段（p=7）
                   end
                   else begin
                       // 否则进入下一阶段
                       if(Run_mode_reg == D_INTT_Radix2)
                           p_reg <= p_reg + 1; // INTT模式：p递增（0→1→...→7）
                       else
                           p_reg <= p_reg - 1; // NTT模式：p递减（7→6→...→0）
                   end
               end
             else begin
                 // k未达到最大值时递增
                 k_reg <= k_reg + 1;
             end
           end
           else begin
                // j未达到最大值时递增
                j_reg <= j_reg + 1;
           end
       end
    //    else if((Run_mode == D_NTT_Radix2) || (Run_mode == D_INTT_Radix2)) begin// 基2_D 先走一次这个判断语句 Run_mode比Run_mode_reg先赋值
    //           p_reg <= 3'b111;
    //    end              
       else begin
         p_reg <= begin_stage;
         j_reg <= 0;
         k_reg <= 0;
         i_reg <= 0;
       end
  end
endmodule
// module FSM(
//   input clk,rst,
//   input [1:0] Run_mode,  //实际在运行的模式，提前用parameter 定义好了 ，在测试文件中输入
//   // input KD_NTT_mode0,   // 0--Kyber 1--Dilithium
//   // input KD_NTT_mode1,   // 0--NTT   1--INTT  可能用不到,不需要放在这输入,因为只有下面一个DFF用到了这个信号,可以放到别的模块中？
//   output wire sel_0,  // 0--基2  1--基4
//   output wire sel_1,  // 0--NTT  1--INTT  在mode.v中生成的KD_NTT_mode1信号是一样的
//   output wire [4:0] i, 
//   output wire [4:0] k, 
//   output wire [4:0] j, 
//   output wire [2:0] p, 
//   output wire [2:0] done_flag,
//   output wire wen,
//   output wire ren,
//   output wire en); //确定所有位宽！ 写完后检查一下

//   reg [4:0] i_reg;
//   reg [7:0] k_reg,j_reg;
//   reg [2:0] p_reg;
//   reg [3:0] done_reg;
//   assign i = i_reg;
//   assign j = j_reg;
//   assign k = k_reg;
//   assign p = p_reg;
//   assign done_flag = done_reg;

//   //此处不用mode.v生成，直接定义更加简洁
//   parameter IDLE = 4'b0000;
//   parameter K_NTT_Radix2 = 4'b0001; 
//   parameter DONE_K_NTT_Radix2 = 4'b0010;
//   parameter K_NTT_Radix4 = 4'b0011;
//   parameter DONE_K_NTT_Radix4 = 4'b0100;
//   parameter D_NTT_Radix2 = 4'b0101;
//   parameter DONE_D_NTT_Radix2 = 4'b0110;
//   parameter K_INTT_Radix2 = 4'b0111;
//   parameter DONE_K_INTT_Radix2 = 4'b1000;
//   parameter K_INTT_Radix4 = 4'b1001;
//   parameter DONE_K_INTT_Radix4 = 4'b1010;
//   parameter D_INTT_Radix2 = 4'b1011;
//   parameter DONE_D_INTT_Radix2 = 4'b1100;

//   reg en_reg,wen_reg,ren_reg;
//   wire en_reg_dout_tmp;
//   //DFF触发器，clk上升沿时，将data_in信号赋值给data_out
//   DFF #(.data_width(1)) dff_en(.clk(clk),.rst(rst),.data_in(en_reg),.data_out(en_reg_dout_tmp));
//   DFF #(.data_width(1)) dff_ren(.clk(clk),.rst(rst),.data_in(ren_reg),.data_out(ren));

// //时钟分频       sel_0 = 0, clk_en = 1;clk_c = 0;
//   wire clk_en,clk_c;
//   assign clk_en = clk & (~sel_0);
//   assign clk_c = clk & (sel_0); 
//   wire wen_K2,en_reg_K2,wen_K4,en_reg_K4;
//   shift_8 #(.data_width(1)) shift_8_wen_K2(.clk(clk_en),.rst(rst),.data_in(wen_reg),.data_out(wen_K2)); //radix-2 ntt 写使能
//   shift_7 #(.data_width(1)) shift_7_en_K2(.clk(clk_en),.rst(rst),.data_in(en_reg_dout_tmp),.data_out(en_reg_K2));//控制radix-2开始
//   shift_14 #(.data_width(1)) shift_14_wen_K4(.clk(clk_c),.rst(rst),.data_in(wen_reg),.data_out(wen_K4)); //radix-4 ntt 写使能 
//   shift_13 #(.data_width(1)) shift_13_en_K4(.clk(clk_c),.rst(rst),.data_in(en_reg_dout_tmp),.data_out(en_reg_K4)); //控制radix-4开始

//   assign wen = (sel_0 == 0) ? wen_K2 : wen_K4; //NTT INTT 写使能
//   assign en_reg_dout = (sel_0 == 0) ? en_reg_K2 : en_reg_K4;
//   assign en = ((Run_mode == DONE_K_NTT_Radix2) ||
//                (Run_mode == DONE_K_NTT_Radix4) ||
//                (Run_mode == DONE_K_INTT_Radix2) ||
//                (Run_mode == DONE_K_INTT_Radix4)) ? en_reg_dout : en_reg_dout_tmp;

//   reg sel_0_reg; //基2 基4
//   reg sel_1_reg; // NTT INTT
//   DFF #(.data_width(1)) dff_sel_0(.clk(clk),.rst(rst),.data_in(sel_0_reg),.data_out(sel_0)); 
//   DFF #(.data_width(1)) dff_sel_1(.clk(clk),.rst(rst),.data_in(sel_1_reg),.data_out(sel_1)); 
//   //此处KD_NTT_mode1_dout蝶形运算时用到的 没在此模块输出 语句位置应该不在这
//   // DFF #(.data_width(1)) dff_sel_1(.clk(clk),.rst(rst),.data_in(sel_1_reg),.data_out(sel_1));


//   always@(posedge clk or posedge rst)

//   reg [1:0] Run_mode_reg;
//   always@(posedge clk or posedge rst)  //跟DFF没什么不同吧？ 在clk上升沿时 将Run_mode寄存到Run_mode_reg
//     begin
//       if(rst)
//         Run_mode_reg <= IDLE;
//       else
//         Run_mode_reg <= Run_mode;  // #6之后 Run_mode_reg才赋值Run_mode 如果调用DFF是每个周期Run_mode_reg <= Run_mode吗？
//     end

//   always@(*)
//   begin
//     //初始化
//     sel_0_reg = 0;  // 0--NTT 1--INTT 
//     sel_1_reg = 0;  //0--基2 1--基4  
//     en_reg = 0; 
//     wen_reg = 0;
//     ren_reg = 0; 
//     done_reg = 3'b0;
    
//     case(Run_mode_reg)
//     IDLE:begin 
//         sel_0_reg = 0; // 0--NTT 1--INTT  
//         sel_1_reg = 0; //0--基2 1--基4  
//         en_reg  = 0; 
//         wen_reg = 0;
//         ren_reg = 0; 
//         done_reg = 3'b0;
//         end
//     K_NTT_Radix2:begin   //基2 1个阶段
//         sel_0_reg = 0;   // 0--NTT 1--INTT  
//         sel_1_reg = 0;   //0--基2 1--基4  
//         en_reg = 1; 
//         wen_reg = 1;
//         ren_reg = 1;
//         if(i_reg == 5'd31)
//            done_reg = 3'b001;
//         else
//            done_reg = 3'b0;
//         end
//     DONE_K_NTT_Radix2:begin 
//          sel_0_reg = 0;   //radix-2
//          sel_1_reg = 0;   //NTT
//          en_reg = 0;
//          wen_reg = 0;
//          ren_reg = 0; 
//          p_reg <= 3'b0;
//         end
//     K_NTT_Radix4:begin  // 基4 3个阶段
//         sel_0_reg = 1;   //radix-4
//         sel_1_reg = 0;   //NTT
//         en_reg = 1; 
//         wen_reg = 1;
//         ren_reg = 1;
//         if((p_reg == 0)&&(k_reg == 31)&&(j_reg == 0))begin  //说明执行完毕
//            done_reg = 3'b010; 
//         end
//         else begin
//            done_reg = 3'b0; 
//         end
//         end
//     DONE_K_NTT_Radix4:begin 
//          sel_0_reg = 1;   //radix-4
//          sel_1_reg = 0;   //NTT
//          en_reg = 0;
//          wen_reg = 0;
//          ren_reg = 0; 
//          p_reg <= 3'b0;
//         end
//     K_INTT_Radix4:begin // 基4 3个阶段
//         sel_0_reg = 1;   //radix-4
//         sel_1_reg = 1;   //INTT
//         en_reg = 1; 
//         wen_reg = 1;
//         ren_reg = 1;
//         if((p_reg == 2)&&(k_reg == 0)&&(j_reg == 31))begin
//           done_reg = 3'b011; 
//         end
//         else begin
//           done_reg = 3'b0; 
//         end
//         end
//     DONE_K_INTT_Radix4:begin 
//          sel_0_reg = 1;    //radix-4
//          sel_1_reg = 1;    //INTT
//          en_reg = 0;
//          wen_reg = 0;
//          ren_reg = 0; 
//          p_reg <= 3'b0;
//         end
//     K_INTT_Radix2:begin //基2 1个阶段 
//         sel_0_reg = 0;   //radix-2
//         sel_1_reg = 1;   //INTT
//         en_reg = 1; 
//         wen_reg = 1;
//         ren_reg = 1;
//         //
//          if(i_reg == 5'd31)
//            done_reg = 3'b100;
//          else
//            done_reg = 3'b0;
//         end
//     DONE_K_INTT_Radix2:begin 
//          sel_0_reg = 0; //radix-2
//          sel_1_reg = 1; //INTT
//          en_reg = 0;
//          wen_reg = 0;
//          ren_reg = 0; 
//          p_reg <= 3'b0;
//         end
//     // Dilithium     
//     D_NTT_Radix2:begin //基2 8个阶段
//          sel_0_reg = 0;   //radix-2
//          sel_1_reg = 0;   //NTT
//          en_reg = 1; 
//          wen_reg = 1;
//          ren_reg = 1;
//          //改
//          if((p_reg == 2)&&(k_reg == 0)&&(j_reg == 31))begin
//            done_reg = 3'b011; end
//          else begin
//            done_reg = 3'b0; end
//          end
//     DONE_D_NTT_Radix2:begin 
//          sel_0_reg = 0;   //radix-2
//          sel_1_reg = 0;   //NTT
//          en_reg = 0;
//          wen_reg = 0;
//          ren_reg = 0; 
//          p_reg <= 3'b0;
//         end
//     D_INTT_Radix2:begin  //基2 8个阶段
//          sel_0_reg = 0;   //radix-2
//          sel_1_reg = 1;   //INTT
//          en_reg = 1; 
//          wen_reg = 1;
//          ren_reg = 1;
//          //改
//          if((p_reg == 0)&&(k_reg == 31)&&(j_reg == 0))begin
//            done_reg = 3'b010; end
//          else begin
//            done_reg = 3'b0; end
//          end
//     DONE_D_INTT_Radix2:begin 
//          sel_0_reg = 0; //radix-2
//          sel_1_reg = 1; //INTT
//          en_reg = 0;
//          wen_reg = 0;
//          ren_reg = 0; 
//          p_reg <= 3'b0;
//         end

//     default:begin 
//          sel_0_reg = 0; 
//          sel_1_reg = 0;
//          done_reg = 2'b0;
//          en_reg = 0;
//          wen_reg = 0;
//          ren_reg = 0; 
//          end
//      endcase
//   end
  
//  reg [2:0] end_stage,begin_stage;
//  reg [3:0] p_shift;
//  //p_reg[2:0] 位宽3bit
//  initial begin 
//   if(sel_1_reg)begin  //sel_1_reg = 1 -- Dilithium
//     begin_stage = (Run_mode == D_NTT_Radix2) ? 7 : 0;  //只要不是D_NTT_Radix2 其他模式 begin_stage = 0
//     end_stage = (Run_mode == D_NTT_Radix2) ? 0 : 7;
//     p_shift = p_reg << 1; // 110 = 6
//   end else begin //sel_1_reg = 0 -- Kyber
//     begin_stage = (Run_mode == K_NTT_Radix4) ? 2 : 0; // 2--010
//     end_stage = (Run_mode == K_NTT_Radix4) ? 0 : 2;
//     p_shift = p_reg << 1; // 100 = 4
//   end
//  end 
 
//   always@(posedge clk or posedge rst)begin 
//      if(rst) begin //只有复位时才执行！
//          p_reg <= begin_stage;
//          j_reg <= 0;
//          k_reg <= 0;
//          i_reg <= 0;
//      end 
//      else if((Run_mode_reg == K_NTT_Radix2) || (Run_mode_reg == K_INTT_Radix2)) begin
//          i_reg <= i_reg + 1;
//      end
//      else if((Run_mode == K_NTT_Radix2) || (Run_mode == K_INTT_Radix2)) begin// 基2_K 先走一次这个判断语句 Run_mode比Run_mode_reg先赋值
//          p_reg <= 3'b011;
//      end
//      else if((Run_mode_reg == K_NTT_Radix4) || (Run_mode_reg == K_INTT_Radix4)) begin
//         if(j_reg == (1 << (p_shift)) - 1) begin // 00000001 << 4 -1 = 00010000 - 1 = 15  reg [7:0] k_reg,j_reg; 8bit位宽
//            j_reg <= 0;
//            if(k_reg == (32 >> p_shift) - 1) begin //00100000 >> 4 -1  = 00000010 - 1 = 1
//               k_reg <= 0;
//               if(p_reg == end_stage)
//                    p_reg <= begin_stage;
//               else begin
//                   if(Run_mode_reg == K_INTT_Radix4)
//                      p_reg <= p_reg + 1;
//                   else
//                      p_reg <= p_reg - 1;
//               end
//            end
//            else
//               k_reg <= k_reg + 1;
//          end
//          else
//             j_reg <= j_reg + 1;
//      end
//     //这个不确定有没有必要 跑波形的时候看一下
//     //  else if((Run_mode == D_NTT_Radix2) || (Run_mode == D_INTT_Radix2)) begin// 基2_D 先走一次这个判断语句 Run_mode比Run_mode_reg先赋值
//     //      p_reg <= 3'b111;
//     //  end
    
//     // Dilithium 基2 8个阶段
//      else if((Run_mode_reg == D_NTT_Radix2) || (Run_mode_reg == D_INTT_Radix2)) begin
//     // 当前阶段p_reg的范围是7到0（共8个阶段）
//     // p_shift = p_reg << 1（即p_shift = 2*p_reg）
    
//     // j计数器逻辑：每个k值下j从0计数到(1<<p_shift)-1
//        if(j_reg == (1 << p_shift) - 1) begin 
//         // 当j达到当前阶段最大值时
//         j_reg <= 0; // j归零
        
//         // k计数器逻辑：每个p阶段k从0计数到(128>>p_shift)-1
//         if(k_reg == (128 >> p_shift) - 1) begin
//             // 当k达到当前阶段最大值时
//             k_reg <= 0; // k归零
//             // p阶段切换逻辑
//             if(p_reg == end_stage) begin
//                 // 如果完成所有阶段（p=0）
//                 p_reg <= begin_stage; // 回到初始阶段（p=7）
//             end
//             else begin
//                 // 否则进入下一阶段
//                 if(Run_mode_reg == D_INTT_Radix2)
//                     p_reg <= p_reg + 1; // INTT模式：p递增（0→1→...→7）
//                 else
//                     p_reg <= p_reg - 1; // NTT模式：p递减（7→6→...→0）
//             end
//         end
//         else begin
//             // k未达到最大值时递增
//             k_reg <= k_reg + 1;
//         end
//        end
//        else begin
//         // j未达到最大值时递增
//         j_reg <= j_reg + 1;
//        end
//      end            
//      else begin
//        p_reg <= begin_stage;
//        j_reg <= 0;
//        k_reg <= 0;
//        i_reg <= 0;
//      end
//   end
// endmodule