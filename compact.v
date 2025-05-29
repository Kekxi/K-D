module compact_bf #(parameter data_width = 12)(
        input clk,rst,
        input [data_width-1:0] u0,v0,u1,v1, //从b0-b3取，往PE里送的四个12bit数 对应q0-q3 对应F0-F3
        input [data_width-1:0] wa1,wa2,wa3, //wa1--H,wa2---M,wa3--L,
        input sel_0,sel_1,KD_mode,
        output [data_width-1:0] bf_0_upper,bf_0_lower,bf_1_upper,bf_1_lower //对应存回b0-b3
        );
        wire [23:0] PE0_in,w0_in,PE0_out; //PE0 2输入 1输出
        wire [23:0] PE1_a_in,PE1_b_in,w1_in,PE1_out1,PE1_out2;//PE1 3输入 2输出
        wire [23:0] PE2_a0_in,PE2_b0_in,PE2_a1_in,PE2_b1_in,PE2_out3,PE2_out4;//PE2 4输入 2输出
        
        reg [23:0] PE0_in_reg,w0_in_reg;
        reg [23:0] PE1_a_in_reg,PE1_b_in_reg,w1_in_reg;
        reg [23:0] PE2_a0_in_reg,PE2_b0_in_reg,PE2_a1_in_reg,PE2_b1_in_reg;
        reg [data_width-1:0] bf_0_upper_reg,bf_0_lower_reg,bf_1_upper_reg,bf_1_lower_reg;

        
        assign PE0_in = PE0_in_reg;
        assign w0_in = w0_in_reg;
    
        assign PE1_a_in = PE1_a_in_reg;
        assign PE1_b_in = PE1_b_in_reg;
        assign w1_in = w1_in_reg;
        
        assign PE2_a0_in = PE2_a0_in_reg;
        assign PE2_a1_in = PE2_a1_in_reg;
        assign PE2_b0_in = PE2_b0_in_reg;
        assign PE2_b1_in = PE2_b1_in_reg;
        

        assign bf_0_upper = bf_0_upper_reg;
        assign bf_0_lower = bf_0_lower_reg;
        assign bf_1_upper = bf_1_upper_reg;
        assign bf_1_lower = bf_1_lower_reg;
        // wire [23:0] PE0_in_reg_tmp;
        // assign PE0_in_reg_tmp = {u0,u1};

        PE0 m_pe0(  
             .clk(clk),  //clk信号有问题 ！
             .rst(rst),
             .sel_0(sel_0),
             .sel_1(sel_1),
             .KD_mode(KD_mode),
             .PE0_a(PE0_in),
             .w0(w0_in),
             .PE0_out(PE0_out));
        // module PE0 #(parameter data_width = 24)(
        //    input clk,rst,
        //    input sel_1,KD_mode,
        //    input [data_width-1:0] PE0_a,w0,  
        //    output [data_width-1:0] PE0_out);

        PE1 m_pe1(
             .clk(clk),
             .rst(rst),
             .sel_0(sel_0),
             .sel_1(sel_1),
             .KD_mode(KD_mode),
             .PE1_a(PE1_a_in),
             .PE1_b(PE1_b_in),
             .w1(w1_in),
             .PE1_out1(PE1_out1),.PE1_out2(PE1_out2));     
        // module PE1(
        //    input clk,rst,
        //    input sel_1,KD_mode, 
        //    input [23:0] PE1_a,PE1_b,w1,
        //    output [23:0] PE1_out1,PE1_out2);
        //
        PE2 m_pe2(
              .clk(clk),
              .rst(rst),
              .sel_0(sel_0),
              .sel_1(sel_1),
              .KD_mode(KD_mode),
              .PE2_a0(PE2_a0_in),
              .PE2_b0(PE2_b0_in),
              .PE2_a1(PE2_a1_in),
              .PE2_b1(PE2_b1_in),
              .PE2_out3(PE2_out3),.PE2_out4(PE2_out4));  
        // module PE2(
        //    input clk,rst,
        //    input sel_1,KD_mode,
        //    input [23:0] PE2_a0,PE2_b0,PE2_a1,PE2_b1,
        //    output [23:0] PE2_out3,PE2_out4);  
      
     always@(*)
     begin //6中情况 Kyber--基2NTT/INTT 基4NTT/INTT Dilithium--基2NTT/INTT 三个信号生成6个新的信号
          case ({sel_0, sel_1, KD_mode})
              3'b000: // sel_0 = 0, sel_1 = 0, KD_mode = 0 //基2 NTT Kyber------PE0 和 PE1 并行！
              begin //u0,v0,u1,v1---b0,b1,b2,b3
                  //PE0
                  PE0_in_reg <= {u0,u1}; //(F0,F2)
                  w0_in_reg <= {12'b1,12'b101001010010}; //(wH=1,constω=2642) constω--基2阶段固定的一个旋转因子
                  // PE0_out----(F0 + F2*constw,F0 - F2*constw) 最终结果存回b0,b2
                  //A0 = PE0_out[23:12]
                  //A2 = PE0_out[11:0]
   
                  //PE1
                  PE1_a_in_reg <= {v0,v1}; //(F1,F3)
                  PE1_b_in_reg <= 24'b0;   //计算用不到
                  w1_in_reg <= {12'b1,12'b101001010010}; //(wH=1,constω=2642)
                  // PE0_out1----(F1 + F3*constw,F1 - F3*constw) 最终结果存回b1,b3
                  // A1 = PE1_out1[23:12]
                  // A3 = PE1_out1[11:0]
                  //注意，此处PE0_out2计算的值无效，考虑是否可以优化它不走 会节省资源
   
                  //PE2
                  PE2_a0_in_reg <= 0;
                  PE2_b0_in_reg <= 0;
                  PE2_a1_in_reg <= 0;
                  PE2_b1_in_reg <= 0;
                  
                  bf_0_upper_reg <= PE0_out[23:12];   //A0
                  bf_0_lower_reg <= PE1_out1[23:12];  //A1
                  bf_1_upper_reg <= PE0_out[11:0];    //A2
                  bf_1_lower_reg <= PE1_out1[11:0];   //A3 
              end

              3'b100: // sel_0 = 1, sel_1 = 0, KD_mode = 0 //基4 NTT Kyber-----PE0 和 PE1 非并行！
              begin //u0,v0,u1,v1---b0,b1,b2,b3
                  //PE0
                  PE0_in_reg <= {v0,v1}; //(F1,F3)
                  w0_in_reg <= {wa1,wa3}; //(w1,w3)
                  // PE0_out----(T2,T3) = (F1*w1 + F3*w3,F1*w1 - F3*w3) 
                  //T2 = F1*w1 + F3*w3 = PE0_out[23:12] T2送到PE2
                  //T3 = F1*w1 - F3*w3 = PE0_out[11:0]  T3送到PE1
   
                  //PE1
                  PE1_a_in_reg <= {u1,PE0_out[11:0]}; //(F2,T3)F2--shif_4 才能对齐T3
                  PE1_b_in_reg <= {u0,12'b0}; //(F0,12'b0)
                  w1_in_reg <= {wa2,12'b011100011101};//(w2,1821) w(4,1)=1821 常量
                  //PE1_out1=(F0-F2*w2,T3*1821+0)  PE1_out2=(F0+F2*w2,0-T3*1821)
                  //T0=F0+F2*w2=PE1_out2[23:12] 
                  //T1=F0-F2*w2=PE1_out1[23:12]
                  //T3*1821 = PE1_out1[11:0]
                  //-T3*1821 = PE1_out2[11:0]
   
                  //PE2
                  PE2_a0_in_reg <= {PE1_out2[23:12],PE1_out2[23:12]};//(T0,T0)
                  PE2_b0_in_reg <= {PE0_out[23:12],PE0_out[23:12]};//(T2,T2)
                  PE2_a1_in_reg <= {PE1_out1[23:12],PE1_out1[23:12]};//(T1,T1)
                  PE2_b1_in_reg <= {PE1_out1[11:0],PE1_out2[11:0]};//(T3*1821,-T3*1821)
                  //A0 = T0+T2 = PE2_out3[23:12]
                  //A1 = T0-T2 = PE2_out3[11:0]
                  //A2 = T1+T3*1821 = PE2_out4[23:12]
                  //A3 = T0+(-T3*1821) = PE2_out4[11:0]
                  bf_0_upper_reg <= PE2_out3[23:12];  //A0
                  bf_0_lower_reg <= PE2_out3[11:0];   //A1
                  bf_1_upper_reg <= PE2_out4[23:12];  //A2
                  bf_1_lower_reg <= PE2_out4[11:0];   //A3 
              end
              3'b110: // sel_0 = 1, sel_1 = 1, KD_mode = 0 //基4 INTT Kyber
              begin
                  //PE2
                  PE2_a0_in_reg <= {u0,u0};//(F0,F0)
                  PE2_b0_in_reg <= {u1,u1};//(F2,F2)
                  PE2_a1_in_reg <= 24'b0;//24'b0
                  PE2_b1_in_reg <= 24'b0;//24'b0
                  //PE2_out3 = (T0,T1) = (F0+F2,F0-F2)*(1/2)
                  //PE2_out4 = 24'b0
                  //T0 = PE2_out3[23:12]
                  //T1 = PE2_out3[11:0]
   
                  //PE1
                  PE1_a_in_reg <= {v0,v1}; //(F1,F3)
                  PE1_b_in_reg <= {PE2_out3[23:12],PE2_out3[23:12]}; //(T0,T0)
                  w1_in_reg <= {12'b000100111101,wa2};//(317,w2^-1) w2^-1也按照w2输入了，实际上值是错误的！ w(4,-1)=317 常量
                  //PE1_out1=(T3,a2)*(1/2)={(F1-F3)*317,(T0-T2)*w2}*(1/2)       
                  //PE1_out2=(a0,T2)*(1/2)=(T0+T2,F1+F3)*(1/2) 
                  //T3 = PE1_out1[23:12]
                  //a2 = PE1_out1[11:0]
                  //a0 = PE1_out2[23:12]
                  //T2 = PE1_out2[11:0]
   
                  //PE0
                  PE0_in_reg <= {PE2_out3[11:0],PE1_out1[23:12]}; //(T1,T3)
                  w0_in_reg <= {wa1,wa3}; //(w1^-1,w3^-1)  w1^-1,w3^-1也按照w1、w3输入了，实际上值是错误的！
                  //PE0_out= (a1,a3) = {(T1+T3)*w1,(T1-T3)*w3}*(1/2) 
                  //a1 = PE0_out[23:12]
                  //a3 = PE0_out[11:0]
   
                  bf_0_upper_reg <= PE1_out2[23:12];  //a0
                  bf_0_lower_reg <= PE0_out[23:12];   //a1
                  bf_1_upper_reg <= PE1_out1[11:0];  //a2
                  bf_1_lower_reg <= PE0_out[11:0];   //a3
              end
              3'b010: // sel_0 = 0, sel_1 = 1, KD_mode = 0 //基2 INTT Kyber
              begin
                  //PE0
                  PE0_in_reg <= {u0,u1}; //(F0,F2)
                  w0_in_reg <= {12'b1,12'b001010101111}; //(1,constw^(-1))  constw^(-1) = 687
                  //PE0_out= {(F0+F2)*1,(F0-F2)*constw^(-1)}*(1/2) 
                  //a0 = PE0_out[23:12] 存b0
                  //a2 = PE0_out[11:0]  存b2
   
                  //PE1
                  PE1_a_in_reg <= {v0,v1}; //(F1,F3)
                  PE1_b_in_reg <= 0; //24'b0
                  w1_in_reg <= {12'b1,12'b001010101111}; //(1,constw^(-1))  constw^(-1) = 687 
                  //PE1_out1 = {(F1+F3)*1,(F1-F3)*constω^(-1)}*(1/2)   整体乘了1/2 在结构图中体现 结果汇总再乘 应该修改代码 单独乘1/2!!
                  //a1 = PE1_out1[23:12] 存b1
                  //a3 = PE1_out1[11:0]  存b3
   
                  //PE2
                  PE2_a0_in_reg <= 0;
                  PE2_b0_in_reg <= 0;
                  PE2_a1_in_reg <= 0;
                  PE2_b1_in_reg <= 0;
                  
                  bf_0_upper_reg <= PE0_out[23:12];    //a0
                  bf_0_lower_reg <= PE1_out1[23:12];   //a1
                  bf_1_upper_reg <= PE0_out[11:0];     //a2
                  bf_1_lower_reg <= PE1_out1[11:0];    //a3
              end
              3'b001: // sel_0 = 0, sel_1 = 0, KD_mode = 1 //基2 NTT Dilithium
              begin
                  //PE0
                  PE0_in_reg <= {v1,v1}; //(F3,F3)
                  w0_in_reg <= {wa2,wa3}; //(wH,wL)= (w2,w3) 
                  //PE0_out= F3·ωH·2^12 + F3·ωL = P0 
   
                  //PE1
                  PE1_a_in_reg <= {u1,u1}; //(F2,F2)
                  PE1_b_in_reg <= PE0_out[23:0]; //P0
                  w1_in_reg <= {wa2,wa3}; //(wH,wL)= (w2,w3)
                  //PE1_out1 = P0 + F2·ωH·2^24 + F2·ωL·2^12 = Q0 
                  
                  //PE2
                  PE2_a0_in_reg <= {u0,v0};//(F0,F1)
                  PE2_b0_in_reg <= PE1_out1[23:0]; //Q0
                  PE2_a1_in_reg <= {u0,v0};//(F0,F1)
                  PE2_b1_in_reg <= PE1_out1[23:0]; //Q0
                  //PE2_out3 = (F0,F1) + Q0 存b0 b1
                  //PE2_out4 = (F0,F1) - Q0 存b2 b3
   
                  bf_0_upper_reg <= PE2_out3[23:12];    
                  bf_0_lower_reg <= PE2_out3[11:0];   
                  bf_1_upper_reg <= PE2_out4[23:12];     
                  bf_1_lower_reg <= PE2_out4[11:0];    
              end
              3'b011: // sel_0 = 0, sel_1 = 1, KD_mode = 1 //基2 INTT Dilithium
              begin
                  //PE2
                  PE2_a0_in_reg <= {u0,v0};//(F0,F1)
                  PE2_b0_in_reg <= {u1,v1}; //(F2,F3)
                  PE2_a1_in_reg <= {u0,v0};//(F0,F1)
                  PE2_b1_in_reg <= {u1,v1}; //(F2,F3)
                  //PE2_out3 = [(F0,F1) + (F2,F3)]*(1/2) 存b0,b1
                  //PE2_out4 = (F0,F1) - (F2,F3) = (rH,rL)
   
                  //PE0
                  PE0_in_reg <= PE2_out4[23:0]; //(rH,rL)
                  w0_in_reg <= {wa3,wa3}; //(wL,wL)= (w3,w3) 
                  //PE0_out= rH·ωL·2^12 + rL·ωL = P0 
   
                  //PE1
                  PE1_a_in_reg <= PE2_out4[23:0]; //(rH,rL)
                  PE1_b_in_reg <= PE0_out[23:0]; //P0
                  w1_in_reg <= {wa2,wa2}; //(wH,wH)= (w2,w2)
                  //PE1_out1 = (P0 + rH·ωH·2^24 + rL·ωH·2^12)*(1/2) = Q0   最后*(1/2) 存b2,b3
                  bf_0_upper_reg <= PE2_out3[23:12];    
                  bf_0_lower_reg <= PE2_out3[11:0];   
                  bf_1_upper_reg <= PE1_out1[23:12];     
                  bf_1_lower_reg <= PE1_out1[11:0];     
              end
          endcase
     end
endmodule