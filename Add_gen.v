//生成了每轮蝶形运算需要的系数
//Dilithium就按照256点12bit 2个bank算  剩余2个bank复制 在后续映射时需要处理到512点 （其实可以直接512点）
//对于Kyber 实际有效[6:0]  Dilithium实际有效[7:0] 设置[8:0]是为了Bank_address_mapping.v位宽匹配
module Add_gen( 
    input KD_mode,// 1--kyber  0--Dilithium
    input [4:0] i, //max = 31    2^5       
    input [6:0] j, //max = 127   2^7
    input [6:0] k, //max = 127
    input [2:0] stage,    //阶段数 3位 表示最多8个阶段
    output wire [7:0] old_add_0,old_add_1,old_add_2,old_add_3  // 按照N = 256 设置位宽 2^8

);
    reg [7:0] old_add_0_reg,old_add_1_reg,old_add_2_reg,old_add_3_reg;
    
    always@(*) begin
        case (stage) // 3 0 2 1 0    7 6 5 4 3 2 1 0
            3'b000:begin
                if (~KD_mode)begin //Kyber stage = 0  N=128
                    old_add_0_reg = ((k << 2) << (stage << 1)) + j;              //0  k = 0,...,31,s = 0 ,j = 0
                    old_add_1_reg = {old_add_0_reg[6:1],1'b1};                     //1
                    old_add_2_reg = {old_add_0_reg[6:2],1'b1,old_add_0_reg[1]};    //2
                    old_add_3_reg = {old_add_0_reg[6:2],2'b11};                     //3
                end
                else begin //Dilithium N=256 stage = 0
                    old_add_0_reg = (k << 1) + j;                               //0  k = 0  ... 127, s = 0 ,j = 0
                    old_add_1_reg = old_add_0_reg;                              //0
                    old_add_2_reg = {old_add_0_reg[7:1],1'b1};                  //1 
                    old_add_3_reg = old_add_2_reg;                              //1
                end
            end
            3'b001:begin
                if (~KD_mode)begin //Kyber stage = 1
                    old_add_0_reg = ((k << 2) << (stage << 1)) + j;                //0 k = 0,...,7,s = 1 ,j = 0 ... 3
                    old_add_1_reg = {old_add_0_reg[6:3],1'b1,old_add_0_reg[1:0]};  //4
                    old_add_2_reg = {old_add_0_reg[6:4],1'b1,old_add_0_reg[2:0]};  //8
                    old_add_3_reg = {old_add_0_reg[6:4],2'b11,old_add_0_reg[1:0]};  //12
                end
                else begin //Dilithium
                    old_add_0_reg = ((k << 1) << stage ) + j;                   //0 k = 0,...,63,s = 1 ,j = 0,1
                    old_add_1_reg = old_add_0_reg;                              //0
                    old_add_2_reg = {old_add_0_reg[7:2],1'b1,old_add_0_reg[0]}; //2
                    old_add_3_reg = old_add_2_reg;                              //2
                end
            end
            3'b010:begin
                if (~KD_mode)begin //Kyber stage = 2
                    old_add_0_reg = ((k << 2) << (stage << 1)) + j;                //0  k = 0,1, s = 2, j = 0,..,15
                    old_add_1_reg = {old_add_0_reg[6:5],1'b1,old_add_0_reg[3:0]};  //16
                    old_add_2_reg = {old_add_0_reg[6],1'b1,old_add_0_reg[4:0]};    //32
                    old_add_3_reg = {old_add_0_reg[6],2'b11,old_add_0_reg[3:0]};    //48
                end
                else begin //Dilithium
                    old_add_0_reg = ((k << 1) << stage ) + j;                     //0   k = 0  ... 31, s = 2 ,j = 0 ... 3
                    old_add_1_reg = old_add_0_reg;                                //0
                    old_add_2_reg = {old_add_0_reg[7:3],1'b1,old_add_0_reg[1:0]}; //4
                    old_add_3_reg = old_add_2_reg;                                //4
                end
            end
            3'b011:begin
                if (~KD_mode)begin //Kyber stage = 3 
                    old_add_0_reg = i;   //i是7位 前边会自动补一个0吧？                    //0  i = 0,..,31
                    old_add_1_reg = {old_add_0_reg[6],1'b1,old_add_0_reg[4:0]};    //32
                    old_add_2_reg = {1'b1,old_add_0_reg[5:0]};                     //64
                    old_add_3_reg = {2'b11,old_add_0_reg[4:0]};                  //96
                    // old_add_3_reg = {1'b1,old_add_1_reg[5:0]};                     //96
                end
                else begin //Dilithium
                    old_add_0_reg = ((k << 1) << stage) + j;                      //0 k = 0  ... 15, s = 3 ,j = 0 ... 7
                    old_add_1_reg = old_add_0_reg;                                //0
                    old_add_2_reg = {old_add_0_reg[7:4],1'b1,old_add_0_reg[2:0]}; //8
                    old_add_3_reg = old_add_2_reg;                                //8
                end
            end
            3'b100:begin //Dilithium stage = 4
                old_add_0_reg = ((k << 5) << (stage << 1)) + j;               //0 k = 0  ... 7, s = 4 ,j = 0 ... 15
                old_add_1_reg = old_add_0_reg;                                //0
                old_add_2_reg = {old_add_0_reg[7:5],1'b1,old_add_0_reg[3:0]};  //16
                old_add_3_reg = old_add_2_reg;                                 //16
            end
            3'b101:begin //Dilithium stage = 5
                old_add_0_reg = ((k << 4) << (stage << 1)) + j;               //0 k = 0,1,2,3, s = 5 ,j = 0 ... 31
                old_add_1_reg = old_add_0_reg;                                //0
                old_add_2_reg = {old_add_0_reg[7:6],1'b1,old_add_0_reg[4:0]}; //32
                old_add_3_reg = old_add_2_reg;                                //32
                 
            end
            3'b110:begin //Dilithium stage = 6
                old_add_0_reg = ((k << 3) << (stage << 1)) + j;               //0 k = 0,1, s = 6 ,j = 0 ... 63
                old_add_1_reg = old_add_0_reg;                                //0
                old_add_2_reg = {old_add_0_reg[7],1'b1,old_add_0_reg[5:0]};   //64
                old_add_3_reg = old_add_2_reg;                                //64

                // old_add_0_reg = ((k << 3) << (stage << 1)) + j;                   //0 k = 0,1, s = 6 ,j = 0 ... 63
                // old_add_1_reg = {old_add_0_reg[8:7],1'b1,old_add_0_reg[5:0]};     //64
                // old_add_2_reg = {1'b1,old_add_0_reg[7:0]};                        //256
                // old_add_3_reg = {1'b1,old_add_0_reg[6],1'b1,old_add_0_reg[5:0]};   //320
            end
            3'b111:begin //Dilithium stage = 7
                old_add_0_reg = ((k << 3) << (stage << 1)) + j;               //0 k = 0, s = 7 ,j = 0 ... 127
                old_add_1_reg = old_add_0_reg;                                //0
                old_add_2_reg = {1'b1,old_add_0_reg[6:0]};                    //128
                old_add_3_reg = old_add_2_reg;                                //128
                                         
                //直接用512点映射 不是实际意义上的512点蝶形运算系数 按8个阶段 后续可以试一下！
                // old_add_?_reg 位宽[8:0]调整！
                // old_add_0_reg = ((k << 2) << (stage << 1)) + j;               //0 k = 0, s = 7 ,j = 0 ... 127
                // old_add_1_reg = {old_add_0_reg[8],1'b1,old_add_0_reg[6:0]};   //128
                // old_add_2_reg = {1'b1,old_add_0_reg[7:0]};                     //256
                // old_add_3_reg = {2'b11,old_add_0_reg[6:0]};                    //384
            end                              
            
        endcase
    end
    assign old_add_0 = old_add_0_reg;
    assign old_add_1 = old_add_1_reg;
    assign old_add_2 = old_add_2_reg;
    assign old_add_3 = old_add_3_reg;
endmodule
// //生成了每轮蝶形运算需要的系数
// //Dilithium就按照256点12bit 2个bank算  剩余2个bank复制 在后续映射时需要处理到512点
// //对于Kyber 实际有效[6:0]  Dilithium实际有效[7:0] 设置[8:0]是为了Bank_address_mapping.v位宽匹配
// module Add_gen( 
//     input KD_mode,// 1--kyber  0--Dilithium
//     input [4:0] i, //max = 31    2^5       
//     input [6:0] j, //max = 127   2^7
//     input [6:0] k, //max = 127
//     input [2:0] stage,    //阶段数 3位 表示最多8个阶段
//     output wire [7:0] old_add_0,old_add_1,old_add_2,old_add_3  // 按照N = 256 设置位宽 2^8

// );
//     reg [7:0] old_add_0_reg,old_add_1_reg,old_add_2_reg,old_add_3_reg;
    
//     always@(*) begin
//         case (stage) // 3 0 2 1 0    7 6 5 4 3 2 1 0
//             3'b000:begin
//                 if (KD_mode)begin //Kyber stage = 0  N=128
//                     old_add_0_reg = ((k << 2) << (stage << 1)) + j;              //0  k = 0,...,31,s = 0 ,j = 0
//                     old_add_1_reg = {old_add_0_reg[6:1],1'b1};                     //1
//                     old_add_2_reg = {old_add_0_reg[6:2],1'b1,old_add_0_reg[1]};    //2
//                     old_add_3_reg = {old_add_0_reg[6:2],2'b1};                     //3
//                 end
//                 else begin //Dilithium N=256
//                     old_add_0_reg = (k << 1) + j;                               //0  k = 0  ... 127, s = 0 ,j = 0
//                     old_add_1_reg = old_add_0_reg;                              //0
//                     old_add_2_reg = {1'b1,old_add_0_reg[6:0]};                  //128 
//                     old_add_3_reg = old_add_2_reg;                              //128 
//                 end
//             end
//             3'b001:begin
//                 if (KD_mode)begin //Kyber stage = 1
//                     old_add_0_reg = ((k << 2) << (stage << 1)) + j;                //0 k = 0,...,7,s = 1 ,j = 0 ... 3
//                     old_add_1_reg = {old_add_0_reg[6:3],1'b1,old_add_0_reg[1:0]};  //4
//                     old_add_2_reg = {old_add_0_reg[6:4],1'b1,old_add_0_reg[2:0]};  //8
//                     old_add_3_reg = {old_add_0_reg[6:4],2'b1,old_add_0_reg[1:0]};  //12
//                 end
//                 else begin //Dilithium
//                     old_add_0_reg = ((k << 1) << stage ) + j;                   //0 k = 0,...,63,s = 1 ,j = 0,1
//                     old_add_1_reg = old_add_0_reg;                              //0
//                     old_add_2_reg = {old_add_0_reg[7],1'b1,old_add_0_reg[5:0]}; //64
//                     old_add_3_reg = old_add_2_reg;                              //64
//                 end
//             end
//             3'b010:begin
//                 if (KD_mode)begin //Kyber stage = 2
//                     old_add_0_reg = ((k << 2) << (stage << 1)) + j;                //0  k = 0,1, s = 2, j = 0,..,15
//                     old_add_1_reg = {old_add_0_reg[6:5],1'b1,old_add_0_reg[3:0]};  //16
//                     old_add_2_reg = {old_add_0_reg[6],1'b1,old_add_0_reg[4:0]};    //32
//                     old_add_3_reg = {old_add_0_reg[6],2'b1,old_add_0_reg[3:0]};    //48
//                 end
//                 else begin //Dilithium
//                     old_add_0_reg = ((k << 1) << stage ) + j;                     //0   k = 0  ... 31, s = 2 ,j = 0 ... 3
//                     old_add_1_reg = old_add_0_reg;                                //0
//                     old_add_2_reg = {old_add_0_reg[7:6],1'b1,old_add_0_reg[4:0]}; //32
//                     old_add_3_reg = old_add_2_reg;                                //32
//                 end
//             end
//             3'b011:begin
//                 if (KD_mode)begin //Kyber stage = 3 
//                     old_add_0_reg = i;   //i是7位 前边会自动补一个0吧？                    //0  i = 0,..,31
//                     old_add_1_reg = {old_add_0_reg[6],1'b1,old_add_0_reg[4:0]};    //32
//                     old_add_2_reg = {1'b1,old_add_0_reg[5:0]};                     //64
//                     old_add_3_reg = {2'b1,old_add_0_reg[4:0]};                     //96
//                   //old_add_3_reg = {1'b1,old_add_1_reg[5:0]};
//                 end
//                 else begin //Dilithium
//                     old_add_0_reg = ((k << 1) << stage) + j;                      //0 k = 0  ... 15, s = 3 ,j = 0 ... 7
//                     old_add_1_reg = old_add_0_reg;                                //0
//                     old_add_2_reg = {old_add_0_reg[7:5],1'b1,old_add_0_reg[3:0]}; //16
//                     old_add_3_reg = old_add_2_reg;                                //16
//                 end
//             end
//             3'b100:begin //Dilithium stage = 4
//                 old_add_0_reg = ((k << 5) << (stage << 1)) + j;               //0 k = 0  ... 7, s = 4 ,j = 0 ... 15
//                 old_add_1_reg = old_add_0_reg;                                //0
//                 old_add_2_reg = {old_add_0_reg[7:4],1'b1,old_add_0_reg[2:0]}; //8
//                 old_add_3_reg = old_add_2_reg;                                //8
//             end
//             3'b101:begin //Dilithium stage = 5
//                 old_add_0_reg = ((k << 4) << (stage << 1)) + j;               //0 k = 0,1,2,3, s = 5 ,j = 0 ... 31
//                 old_add_1_reg = old_add_0_reg;                                //0
//                 old_add_2_reg = {old_add_0_reg[7:3],1'b1,old_add_0_reg[1:0]}; //4
//                 old_add_3_reg = old_add_2_reg;                                //4
//             end
//             3'b110:begin //Dilithium stage = 6
//                 old_add_0_reg = ((k << 3) << (stage << 1)) + j;               //0 k = 0,1, s = 6 ,j = 0 ... 63
//                 old_add_1_reg = old_add_0_reg;                                //0
//                 old_add_2_reg = {old_add_0_reg[7:2],1'b1,old_add_0_reg[0]};   //2
//                 old_add_3_reg = old_add_2_reg;                                //2
//             end
//             3'b111:begin //Dilithium stage = 7
//                 old_add_0_reg = ((k << 3) << (stage << 1)) + j;               //0 k = 0, s = 7 ,j = 0 ... 127
//                 old_add_1_reg = old_add_0_reg;                                //0
//                 old_add_2_reg = {old_add_0_reg[7:1],1'b1};                    //1
//                 old_add_3_reg = old_add_2_reg;                                //1
//             end      
//         endcase
//     end
//     assign old_add_0 = old_add_0_reg;
//     assign old_add_1 = old_add_1_reg;
//     assign old_add_2 = old_add_2_reg;
//     assign old_add_3 = old_add_3_reg;
// endmodule