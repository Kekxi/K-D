// arbiter m3(
//              .a0(bank_number_0),.a1(bank_number_1),
//              .a2(bank_number_2),.a3(bank_number_3),
//              .sel_a_0(sel_a_0),.sel_a_1(sel_a_1),
//              .sel_a_2(sel_a_2),.sel_a_3(sel_a_3)); 
module Arbiter(
    input [1:0] a0,a1,a2,a3, //输进来肯定是不同的
    //input KD_mode,    //不需要区分K和D  因为无论K和D 都是把4个 需要计算的系数 换个地方放 再无冲突的取到
    output reg [1:0] sel_a_0,sel_a_1,sel_a_2,sel_a_3
    );
    
    always@(*)
    begin
      if(a0 == 0)          // bank_number_0
        sel_a_0 = 0;
      else if(a1 == 0)     //  bank_number_1
         sel_a_0 = 1;
      else if(a2 == 0)     //  bank_number_2
         sel_a_0 = 2;
      else if(a3 == 0)     //  bank_number_3
         sel_a_0 = 3;   
       else
         sel_a_0 = 0;  
    end
    
    always@(*)
    begin
      if(a0 == 1)            
        sel_a_1 = 0;
      else if(a1 == 1)
         sel_a_1 = 1;
      else if(a2 == 1)
         sel_a_1 = 2;
      else if(a3 == 1)
         sel_a_1 = 3;   
       else
         sel_a_1 = 0;  
    end
    
    always@(*)
    begin
      if(a0 == 2) 
        sel_a_2 = 0;
      else if(a1 == 2)
         sel_a_2 = 1;
      else if(a2 == 2)
         sel_a_2 = 2;
      else if(a3 == 2)
         sel_a_2 = 3;   
       else
         sel_a_2 = 0;  
    end
    
    always@(*)
    begin
      if(a0 == 3) 
        sel_a_3 = 0;
      else if(a1 == 3)
         sel_a_3 = 1;
      else if(a2 == 3)
         sel_a_3 = 2;
      else if(a3 == 3)
         sel_a_3 = 3;    
       else
         sel_a_3 = 0;  
    end
    
endmodule