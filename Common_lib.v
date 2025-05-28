`timescale 1ns / 1ps
//触发器，clk上升沿时，将data_in信号赋值给data_out
module DFF #(parameter data_width = 24)(
    input clk,rst,
    input [data_width-1:0] data_in,
    output reg [data_width-1:0] data_out 
    );
    always@(posedge clk or posedge rst)
    begin
      if(rst)
        data_out <= 0;
      else
        data_out <= data_in;
    end
endmodule

module shift_1 #(parameter data_width = 24)(  //将data_in延迟1个时钟周期输出
    input rst,clk,
    input [data_width-1:0] data_in,
	output wire [data_width-1:0] data_out
	);
	reg [data_width-1:0] t0;	
	always@(posedge clk or posedge rst)begin
        if(rst) begin
	    t0 <= 0;
	    end
	    else begin
	    t0 <= data_in; 
	  end
	end
	assign data_out = t0;
endmodule

module shift_2 #(parameter data_width = 24)(  //将data_in延迟2个时钟周期输出
    input rst,clk,
    input [data_width-1:0] data_in,
	output wire [data_width-1:0] data_out
	);
	reg [data_width-1:0] t0,t1;	
	always@(posedge clk or posedge rst)begin
        if(rst) begin
	    t0 <= 0; t1 <= 0; 
	    end
	    else begin
	    t0 <= data_in; t1 <= t0; 
	  end
	end
	assign data_out = t1;
endmodule

module shift_3 #(parameter data_width = 24)(  //将data_in延迟3个时钟周期输出
    input rst,clk,
    input [data_width-1:0] data_in,
	output wire [data_width-1:0] data_out
	);
	reg [data_width-1:0] t0,t1,t2;	
	always@(posedge clk or posedge rst)begin
        if(rst) begin
	    t0 <= 0; t1 <= 0; t2 <= 0;
	    end
	    else begin
	    t0 <= data_in; t1 <= t0; t2 <= t1;
	  end
	end
	assign data_out = t2;
endmodule

module shift_4 #(parameter data_width = 24)(  //将data_in延迟4个时钟周期输出
    input rst,clk,
    input [data_width-1:0] data_in,
	output wire [data_width-1:0] data_out
	);
	reg [data_width-1:0] t0,t1,t2,t3;	
	always@(posedge clk or posedge rst)begin
        if(rst) begin
	    t0 <= 0; t1 <= 0; t2 <= 0; t3 <= 0;
	    end
	    else begin
	    t0 <= data_in; t1 <= t0; t2 <= t1; t3 <= t2;
	  end
	end
	assign data_out = t3;
endmodule

module shift_5 #(parameter data_width = 24)(  //将data_in延迟4个时钟周期输出
    input rst,clk,
    input [data_width-1:0] data_in,
	output wire [data_width-1:0] data_out
	);
	reg [data_width-1:0] t0,t1,t2,t3,t4;	
	always@(posedge clk or posedge rst)begin
        if(rst) begin
	    t0 <= 0; t1 <= 0; t2 <= 0; t3 <= 0;t4 <= 0;
	    end
	    else begin
	    t0 <= data_in; t1 <= t0; t2 <= t1; t3 <= t2; t4 <= t3;
	  end
	end
	assign data_out = t4;
endmodule

module shift_6 #(parameter data_width = 24)(  //将data_in延迟6个时钟周期输出
    input rst,clk,
    input [data_width-1:0] data_in,
	output wire [data_width-1:0] data_out
	);
	reg [data_width-1:0] t0,t1,t2,t3,t4,t5;	
	always@(posedge clk or posedge rst)begin
        if(rst) begin
	    t0 <= 0; t1 <= 0; t2 <= 0; t3 <= 0; t4 <= 0; t5 <= 0;
	    end
	    else begin
	    t0 <= data_in; t1 <= t0; t2 <= t1; t3 <= t2; t4 <= t3; t5 <= t4;
	  end
	end
	assign data_out = t5;
endmodule

module shift_7 #(parameter data_width = 24)(  //将data_in延迟7个时钟周期输出
    input rst,clk,
    input [data_width-1:0] data_in,
	output wire [data_width-1:0] data_out
	);
	reg [data_width-1:0] t0,t1,t2,t3,t4,t5,t6;	
	always@(posedge clk or posedge rst)begin
        if(rst) begin
	    t0 <= 0; t1 <= 0; t2 <= 0; t3 <= 0; t4 <= 0; t5 <= 0; t6 <= 0;
	    end
	    else begin
	    t0 <= data_in; t1 <= t0; t2 <= t1; t3 <= t2; t4 <= t3; t5 <= t4; t6 <= t5;
	  end
	end
	assign data_out = t6;
endmodule

module shift_8 #(parameter data_width = 24)(  //将data_in延迟8个时钟周期输出
    input rst,clk,
    input [data_width-1:0] data_in,
	output wire [data_width-1:0] data_out
	);
	reg [data_width-1:0] t0,t1,t2,t3,t4,t5,t6,t7;	
	always@(posedge clk or posedge rst)begin
        if(rst) begin
	    t0 <= 0; t1 <= 0; t2 <= 0; t3 <= 0; t4 <= 0; t5 <= 0; t6 <= 0; t7 <= 0;
	    end
	    else begin
	    t0 <= data_in; t1 <= t0; t2 <= t1; t3 <= t2; t4 <= t3; t5 <= t4; t6 <= t5; t7 <= t6;
	  end
	end
	assign data_out = t7;
endmodule

module shift_9 #(parameter data_width = 24)(  //将data_in延迟9个时钟周期输出
    input rst,clk,
    input [data_width-1:0] data_in,
	output wire [data_width-1:0] data_out
	);
	reg [data_width-1:0] t0,t1,t2,t3,t4,t5,t6,t7,t8;	
	always@(posedge clk or posedge rst)begin
        if(rst) begin
	    t0 <= 0; t1 <= 0; t2 <= 0; t3 <= 0; t4 <= 0; t5 <= 0; t6 <= 0; t7 <= 0; t8 <= 0;
	    end
	    else begin
	    t0 <= data_in; t1 <= t0; t2 <= t1; t3 <= t2; t4 <= t3; t5 <= t4; t6 <= t5; t7 <= t6; t8 <= t7;
	  end
	end
	assign data_out = t8;
endmodule

module shift_10 #(parameter data_width = 24)(  //将data_in延迟10个时钟周期输出
    input rst,clk,
    input [data_width-1:0] data_in,
	output wire [data_width-1:0] data_out
	);
	reg [data_width-1:0] t0,t1,t2,t3,t4,t5,t6,t7,t8,t9;	
	always@(posedge clk or posedge rst)begin
        if(rst) begin
	    t0 <= 0; t1 <= 0; t2 <= 0; t3 <= 0; t4 <= 0; t5 <= 0; 
        t6 <= 0; t7 <= 0; t8 <= 0; t9 <= 0;
	    end
	    else begin
	    t0 <= data_in; t1 <= t0; t2 <= t1; t3 <= t2; t4 <= t3; t5 <= t4; 
        t6 <= t5; t7 <= t6; t8 <= t7; t9 <= t8; 
	  end
	end
	assign data_out = t9;
endmodule

module shift_11 #(parameter data_width = 24)(  //将data_in延迟11个时钟周期输出
    input rst,clk,
    input [data_width-1:0] data_in,
	output wire [data_width-1:0] data_out
	);
	reg [data_width-1:0] t0,t1,t2,t3,t4,t5,t6,t7,t8,t9,t10;	
	always@(posedge clk or posedge rst)begin
        if(rst) begin
	    t0 <= 0; t1 <= 0; t2 <= 0; t3 <= 0; t4 <= 0; t5 <= 0; 
        t6 <= 0; t7 <= 0; t8 <= 0; t9 <= 0; t10 <= 0;
	    end
	    else begin
	    t0 <= data_in; t1 <= t0; t2 <= t1; t3 <= t2; t4 <= t3; t5 <= t4; 
        t6 <= t5; t7 <= t6; t8 <= t7; t9 <= t8; t10 <= t9;
	  end
	end
	assign data_out = t10;
endmodule

module shift_12 #(parameter data_width = 24)(  //将data_in延迟13个时钟周期输出
    input rst,clk,
    input [data_width-1:0] data_in,
	output wire [data_width-1:0] data_out
	);
	reg [data_width-1:0] t0,t1,t2,t3,t4,t5,t6,t7,t8,t9,t10,t11,t12;	
	always@(posedge clk or posedge rst)begin
        if(rst) begin
	    t0 <= 0; t1 <= 0; t2 <= 0; t3 <= 0; t4 <= 0; t5 <= 0; 
        t6 <= 0; t7 <= 0; t8 <= 0; t9 <= 0; t10 <= 0; t11 <= 0;
	    end
	    else begin
	    t0 <= data_in; t1 <= t0; t2 <= t1; t3 <= t2; t4 <= t3; t5 <= t4; 
        t6 <= t5; t7 <= t6; t8 <= t7; t9 <= t8; t10 <= t9; t11 <= t10; 
	  end
	end
	assign data_out = t11;
endmodule

module shift_13 #(parameter data_width = 24)(  //将data_in延迟13个时钟周期输出
    input rst,clk,
    input [data_width-1:0] data_in,
	output wire [data_width-1:0] data_out
	);
	reg [data_width-1:0] t0,t1,t2,t3,t4,t5,t6,t7,t8,t9,t10,t11,t12;	
	always@(posedge clk or posedge rst)begin
        if(rst) begin
	    t0 <= 0; t1 <= 0; t2 <= 0; t3 <= 0; t4 <= 0; t5 <= 0; 
        t6 <= 0; t7 <= 0; t8 <= 0; t9 <= 0; t10 <= 0; t11 <= 0; t12 <= 0;
	    end
	    else begin
	    t0 <= data_in; t1 <= t0; t2 <= t1; t3 <= t2; t4 <= t3; t5 <= t4; 
        t6 <= t5; t7 <= t6; t8 <= t7; t9 <= t8; t10 <= t9; t11 <= t10; t12 <= t11;
	  end
	end
	assign data_out = t12;
endmodule

module shift_14 #(parameter data_width = 24)(  //将data_in延迟14个时钟周期输出
    input rst,clk,
    input [data_width-1:0] data_in,
	output wire [data_width-1:0] data_out
	);
	reg [data_width-1:0] t0,t1,t2,t3,t4,t5,t6,t7,t8,t9,t10,t11,t12,t13;	
	always@(posedge clk or posedge rst)begin
        if(rst) begin
	    t0 <= 0; t1 <= 0; t2 <= 0; t3 <= 0; t4 <= 0; t5 <= 0; 
        t6 <= 0; t7 <= 0; t8 <= 0; t9 <= 0; t10 <= 0; t11 <= 0; t12 <= 0; t13 <= 0;
	    end
	    else begin
	    t0 <= data_in; t1 <= t0; t2 <= t1; t3 <= t2; t4 <= t3; t5 <= t4; 
        t6 <= t5; t7 <= t6; t8 <= t7; t9 <= t8; t10 <= t9; t11 <= t10; t12 <= t11; t13 <= t12;
	  end
	end
	assign data_out = t13;
endmodule