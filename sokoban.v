`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:10:17 12/07/2015 
// Design Name: 
// Module Name:    top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module top(
            clk,
				rst_n,
				BTN_EAST,
				BTN_NORTH,
				BTN_SOUTH,
				BTN_WEST,
				seg,
				an,
				led,
				vga_red,
				vga_green,
				vga_blue,
				vga_hsync,//水平同步
				vga_vsync,//垂直同步			 
				);				
//输入输出
input  clk;
input  rst_n;
input  BTN_EAST;
input  BTN_NORTH;
input  BTN_SOUTH;
input  BTN_WEST;

output [6:0]seg;
output [3:0]an;
output [1:0]led;

output vga_hsync;
output vga_vsync;
output vga_red;
output vga_green;
output vga_blue;

//vga display
reg vga_hsync;
reg vga_vsync;
wire vga_red;
wire vga_green;
wire vga_blue;

//led&segment display
wire [6:0]seg;
wire [1:0]led;
assign an =4'b1110;

reg biankuang;//边框区域
reg xiangzi_biaozhi;//小人标志
reg xiangzi_show;//第一个箱子区域
reg xiangzi_show_1;//第二个箱子区域
reg xiangzi_show_2;//第三个箱子区域

//两个简单的障碍设置
reg zhangai_1;
reg zhangai_2;

reg [12:0] h_cnt;
reg [11:0] v_cnt;

wire s_counter3_flg;

//最终胜利bit 1为获胜
wire win_point;

//3个目标点
reg win_point_flg;
reg win_point_flg_1;
reg win_point_flg_2;

//判断是否有箱子到达目标点bit 1为有箱子到达
reg win_point_1;
reg win_point_2;
reg win_point_3;

//小人移动标志
wire move_left;
wire move_right;
wire move_up;
wire move_down;

//箱子1移动标志
reg move_left_1;
reg move_right_1;
reg move_up_1;
reg move_down_1;

//箱子2移动标志
reg move_left_2;
reg move_right_2;
reg move_up_2;
reg move_down_2;

//箱子3移动标志
reg move_left_3;
reg move_right_3;
reg move_up_3;
reg move_down_3;

reg [10:0] xiangzi_h;
reg [10:0] xiangzi_v;

reg [10:0] xiangzi_h_1;
reg [10:0] xiangzi_v_1;
reg [10:0] xiangzi_h_2;
reg [10:0] xiangzi_v_2;


reg [10:0] xiangzi_h_11;
reg [10:0] xiangzi_v_11;
reg [10:0] xiangzi_h_22;
reg [10:0] xiangzi_v_22;

reg [10:0] xiangzi_h_111;
reg [10:0] xiangzi_v_111;
reg [10:0] xiangzi_h_222;
reg [10:0] xiangzi_v_222;

	 
initial
   begin 
     xiangzi_h <= 10'd200;
	  xiangzi_v <= 10'd200;
	  xiangzi_v_1 <= 10'd400;
	  xiangzi_h_1 <= 10'd400;
	  xiangzi_v_2 <= 10'd300;
	  xiangzi_h_2 <= 10'd300;
	  xiangzi_v_11 <= 10'd400;
	  xiangzi_h_11 <= 10'd600;
	  xiangzi_v_22 <= 10'd300;
	  xiangzi_h_22 <= 10'd500;
	  xiangzi_v_111 <= 10'd260;
	  xiangzi_h_111 <= 10'd260;
	  xiangzi_v_222 <= 10'd380;
	  xiangzi_h_222 <= 10'd380;
	  end
	 
parameter hsync_back_porch  = 240;
parameter vsync_back_porch  =24;

parameter hsync_time        = 1056;
parameter vsync_time        =625;
	
	//一行扫描时钟周期为1056，此always实现0~1056计数
always@(posedge clk or negedge rst_n)
begin
    if(~rst_n)begin
	   h_cnt <= 11'd0;
	end
    else if(h_cnt==(hsync_time - 1))begin
      h_cnt <= 11'd0;
    end
    else begin
    h_cnt <= h_cnt+11'd1;
   end
  end

 //一帧的扫描时钟周期为625行，此always实现0~624计数
always@(posedge clk or negedge rst_n)
begin 
     if(~rst_n)begin
	   v_cnt <= 10'd0;
	end
    else if(h_cnt == (hsync_time - 1))begin
	    if(v_cnt == (vsync_time-1))begin
      v_cnt <= 10'd0;
       end
      else begin
      v_cnt <= v_cnt+10'd1;
      end
   end
   else begin
   v_cnt <= v_cnt;
    end
  end 

	//边框

always@(posedge clk or negedge rst_n)
    begin
        if(~rst_n)begin
	    biankuang <= 1'b0;
	end
	else if (( v_cnt >= vsync_back_porch + 60 )&&( v_cnt < (vsync_back_porch + 560 ))&&(h_cnt < (hsync_back_porch + 700))&& (h_cnt >= hsync_back_porch + 100))begin
        biankuang <= 1'b1;
	end
	else begin
	    biankuang <= 1'b0;
	end
end

	//第一座障碍墙
 always@(posedge clk or negedge rst_n)
    begin
        if(~rst_n)begin
	    zhangai_1 <= 1'b0;
	end
	else if 
	((h_cnt >= 340 + hsync_back_porch)&&(h_cnt < 360 + hsync_back_porch )&&(v_cnt >= 240 + vsync_back_porch )&&(v_cnt < 460 + vsync_back_porch ))begin
        zhangai_1 <= 1'b1;
	end
	else begin
	    zhangai_1 <= 1'b0;
	end
end
 
 //第二座障碍墙
 always@(posedge clk or negedge rst_n)
    begin
        if(~rst_n)begin
	    zhangai_2 <= 1'b0;
	end
	else if 
	((h_cnt >= 420 + hsync_back_porch)&&(h_cnt < 460 + hsync_back_porch )&&(v_cnt >= 240 + vsync_back_porch )&&(v_cnt < 460 + vsync_back_porch ))begin
        zhangai_2 <= 1'b1;
	end
	else begin
	    zhangai_2 <= 1'b0;
	end
end

	
	//小人位置	
always@(posedge clk or negedge rst_n)
    begin
        if(~rst_n)begin
	    xiangzi_biaozhi <= 1'b0;
	end
	else if 
	((h_cnt >= xiangzi_h + hsync_back_porch )&&(h_cnt < xiangzi_h + hsync_back_porch + 20)&&(v_cnt >= xiangzi_v + vsync_back_porch )&&(v_cnt < xiangzi_v + vsync_back_porch + 20))begin
            xiangzi_biaozhi <= 1'b1;
	end
	else begin
	    xiangzi_biaozhi <= 1'b0;
	end
end
	 
	 //第一个箱子
always@(posedge clk or negedge rst_n)
    begin
        if(~rst_n)begin
	    xiangzi_show <= 1'b0;
	end
	else if ((h_cnt >= xiangzi_h_1 + hsync_back_porch)&&(h_cnt < xiangzi_h_1 + hsync_back_porch + 20)&&(v_cnt >= xiangzi_v_1 + vsync_back_porch )&&(v_cnt < xiangzi_v_1 + vsync_back_porch + 20))begin
            xiangzi_show <= 1'b1;
	end
	else begin
	    xiangzi_show <= 1'b0;
	end
end
		
	 //第二个箱子
always@(posedge clk or negedge rst_n)
    begin
        if(~rst_n)begin
	    xiangzi_show_1 <= 1'b0;
	end
	else if ((h_cnt >= xiangzi_h_11 + hsync_back_porch)&&(h_cnt < xiangzi_h_11 + hsync_back_porch + 20)&&(v_cnt >= xiangzi_v_11 + vsync_back_porch )&&(v_cnt < xiangzi_v_11 + vsync_back_porch + 20))begin
        xiangzi_show_1 <= 1'b1;
	end
	else begin
	    xiangzi_show_1 <= 1'b0;
	end
end
		
	//第三个箱子
always@(posedge clk or negedge rst_n)
    begin
        if(~rst_n)begin
	    xiangzi_show_2 <= 1'b0;
	end
	else if ((h_cnt >= xiangzi_h_111 + hsync_back_porch)&&(h_cnt < xiangzi_h_111 + hsync_back_porch + 20)&&(v_cnt >= xiangzi_v_111 + vsync_back_porch )&&(v_cnt < xiangzi_v_111 + vsync_back_porch + 20))begin
        xiangzi_show_2 <= 1'b1;
	end
	else begin
	    xiangzi_show_2 <= 1'b0;
	end
end
		
	//第一个点
always@(posedge clk or negedge rst_n)
    begin
        if(~rst_n)begin
	  win_point_flg <= 1'b0;
	end
	else if ((h_cnt >= xiangzi_h_2 + hsync_back_porch)&&(h_cnt < xiangzi_h_2 + hsync_back_porch + 20)&&(v_cnt >= xiangzi_v_2 + vsync_back_porch )&&(v_cnt < xiangzi_v_2 + vsync_back_porch + 20))begin
            win_point_flg <= 1'b1;
	end
	else begin
	    win_point_flg <= 1'b0;
	end
end
	
	//第二个点
always@(posedge clk or negedge rst_n)
    begin
        if(~rst_n)begin
	  win_point_flg_1 <= 1'b0;
	end
	else if ((h_cnt >= xiangzi_h_22 + hsync_back_porch)&&(h_cnt < xiangzi_h_22 + hsync_back_porch + 20)&&(v_cnt >= xiangzi_v_22 + vsync_back_porch )&&(v_cnt < xiangzi_v_22 + vsync_back_porch + 20))begin
            win_point_flg_1 <= 1'b1;
	end
	else begin
	    win_point_flg_1 <= 1'b0;
	end
end
	
	//第三个点
always@(posedge clk or negedge rst_n)
    begin
        if(~rst_n)begin
	  win_point_flg_2 <= 1'b0;
	end
	else if ((h_cnt >= xiangzi_h_222 + hsync_back_porch)&&(h_cnt < xiangzi_h_222 + hsync_back_porch + 20)&&(v_cnt >= xiangzi_v_222 + vsync_back_porch )&&(v_cnt < xiangzi_v_222 + vsync_back_porch + 20))begin
            win_point_flg_2 <= 1'b1;
	end
	else begin
	    win_point_flg_2 <= 1'b0;
	end
end

	//箱子和小人撞到墙的逻辑判断
 always@(posedge clk or negedge rst_n )begin 
     if(~rst_n)begin
     xiangzi_h <= 10'd200;
     xiangzi_v <= 10'd200;
     end
     else if((move_left == 1'b1)&&(win_point == 1'b0))begin
          if((xiangzi_h < hsync_back_porch - 120)||(( xiangzi_h < hsync_back_porch + 140 )&&( xiangzi_h >= hsync_back_porch + 120 )&&
         ( xiangzi_v >= vsync_back_porch + 200 )&&( xiangzi_v < vsync_back_porch + 420 ))|| 
         (( xiangzi_h < hsync_back_porch + 240)&&( xiangzi_h >= hsync_back_porch + 200)&&
         ( xiangzi_v >= vsync_back_porch + 200 )&&( xiangzi_v < vsync_back_porch + 420 ))||((xiangzi_h_1 < hsync_back_porch - 120) && (xiangzi_v_1 == xiangzi_v))||
	     (( xiangzi_h_1 < hsync_back_porch + 140 )&&( xiangzi_h_1 >= hsync_back_porch + 120 )&&
         ( xiangzi_v_1 >= vsync_back_porch + 200 )&&( xiangzi_v_1 < vsync_back_porch + 420 )&&(xiangzi_v_1 == xiangzi_v))||
		 (( xiangzi_h_1 < hsync_back_porch + 240)&&( xiangzi_h_1 >= hsync_back_porch + 200)&&
         ( xiangzi_v_1 >= vsync_back_porch + 200 )&&( xiangzi_v_1 < vsync_back_porch + 420 )&&(xiangzi_v_1 == xiangzi_v))||
	     ((xiangzi_h_11 < hsync_back_porch - 120) && (xiangzi_v_11 == xiangzi_v))||
	     (( xiangzi_h_11 < hsync_back_porch + 140 )&&( xiangzi_h_11 >= hsync_back_porch + 120 )&&
         ( xiangzi_v_11 >= vsync_back_porch + 200 )&&( xiangzi_v_11 < vsync_back_porch + 420 )&&(xiangzi_v_11 == xiangzi_v))||
		 (( xiangzi_h_11 < hsync_back_porch + 240)&&( xiangzi_h_11 >= hsync_back_porch + 200)&&
         ( xiangzi_v_11 >= vsync_back_porch + 200 )&&( xiangzi_v_11 < vsync_back_porch + 420 )&&(xiangzi_v_11 == xiangzi_v))||
	     ((xiangzi_h_111 < hsync_back_porch - 120) && (xiangzi_v_111 == xiangzi_v))||
	     (( xiangzi_h_111 < hsync_back_porch + 140 )&&( xiangzi_h_111 >= hsync_back_porch + 120 )&&
         ( xiangzi_v_111 >= vsync_back_porch + 200 )&&( xiangzi_v_111 < vsync_back_porch + 420 )&&(xiangzi_v_111 == xiangzi_v))||
	     (( xiangzi_h_111 < hsync_back_porch + 240)&&( xiangzi_h_111 >= hsync_back_porch + 200)&&
         ( xiangzi_v_111 >= vsync_back_porch + 200 )&&( xiangzi_v_111 < vsync_back_porch + 420)&&(xiangzi_v_111 == xiangzi_v)) )begin
              xiangzi_h <= xiangzi_h;
              xiangzi_v <= xiangzi_v;
	        end
	        else begin
            xiangzi_h <= xiangzi_h - 5'd20;
            xiangzi_v <= xiangzi_v;
	        end
	 end
     else if((move_right == 1'b1)&&(win_point == 1'b0) )begin
          if((xiangzi_h >= hsync_back_porch + 440 )||(( xiangzi_h < hsync_back_porch + 100 )&&( xiangzi_h >= hsync_back_porch + 80 )&&
          ( xiangzi_v >= vsync_back_porch + 200 )&&( xiangzi_v < vsync_back_porch + 420 ))|| (( xiangzi_h < hsync_back_porch + 180)&&( xiangzi_h >= hsync_back_porch + 160)&&
          ( xiangzi_v >= vsync_back_porch + 200 )&&( xiangzi_v < vsync_back_porch + 420 ))||((xiangzi_h_1 >= hsync_back_porch + 440) && (xiangzi_v_1 == xiangzi_v))||
	      (( xiangzi_h_1 < hsync_back_porch + 100 )&&( xiangzi_h_1 >= hsync_back_porch + 80 )&&
          ( xiangzi_v_1 >= vsync_back_porch + 200 )&&( xiangzi_v_1 < vsync_back_porch + 420 )&&(xiangzi_v_1 == xiangzi_v))||
		  (( xiangzi_h_1 < hsync_back_porch + 180)&&( xiangzi_h_1 >= hsync_back_porch + 160)&&
          ( xiangzi_v_1 >= vsync_back_porch + 200 )&&( xiangzi_v_1 < vsync_back_porch + 420 )&&(xiangzi_v_1 == xiangzi_v))||
	      ((xiangzi_h_11 >= hsync_back_porch + 440) && (xiangzi_v_11 == xiangzi_v))||
	      (( xiangzi_h_11 < hsync_back_porch + 100 )&&( xiangzi_h_11 >= hsync_back_porch + 80 )&&
          ( xiangzi_v_11 >= vsync_back_porch + 200 )&&( xiangzi_v_11 < vsync_back_porch + 420 )&&(xiangzi_v_11 == xiangzi_v))||
		  (( xiangzi_h_11 < hsync_back_porch + 180)&&( xiangzi_h_11 >= hsync_back_porch + 160)&&
          ( xiangzi_v_11 >= vsync_back_porch + 200 )&&( xiangzi_v_11 < vsync_back_porch + 420 )&&(xiangzi_v_11 == xiangzi_v))||
	      ((xiangzi_h_111 >= hsync_back_porch + 440) && (xiangzi_v_111 == xiangzi_v))||
		  (( xiangzi_h_111 < hsync_back_porch + 100 )&&( xiangzi_h_111 >= hsync_back_porch + 80 )&&
          ( xiangzi_v_111 >= vsync_back_porch + 200 )&&( xiangzi_v_111 < vsync_back_porch + 420 )&&(xiangzi_v_111 == xiangzi_v))||
		  (( xiangzi_h_111 < hsync_back_porch + 180)&&( xiangzi_h_111 >= hsync_back_porch + 160)&&
          ( xiangzi_v_111 >= vsync_back_porch + 200 )&&( xiangzi_v_111 < vsync_back_porch + 420 )&&(xiangzi_v_111 == xiangzi_v)))   begin
            xiangzi_h <= xiangzi_h;
            xiangzi_v <= xiangzi_v;
	        end
            else  begin
           xiangzi_h <= xiangzi_h + 5'd20;
           xiangzi_v <= xiangzi_v;
	       end
     end
     else if((move_up == 1'b1)&&(win_point == 1'b0)   ) begin
          if((xiangzi_v < vsync_back_porch + 40)|| (( xiangzi_h < hsync_back_porch + 120 )&&( xiangzi_h >= hsync_back_porch + 100 )&&
          ( xiangzi_v >= vsync_back_porch + 220 )&&( xiangzi_v < vsync_back_porch + 440 ))|| (( xiangzi_h < hsync_back_porch + 220)&&( xiangzi_h >= hsync_back_porch + 180)&&
          ( xiangzi_v >= vsync_back_porch + 220 )&&( xiangzi_v < vsync_back_porch + 440 ))|| ((xiangzi_v_1 < vsync_back_porch + 40) && (xiangzi_h_1 == xiangzi_h))||
	      (( xiangzi_h_1 < hsync_back_porch + 120 )&&( xiangzi_h_1 >= hsync_back_porch + 100 )&&
          ( xiangzi_v_1 >= vsync_back_porch + 220 )&&( xiangzi_v_1 < vsync_back_porch + 440 )&&(xiangzi_h_1 == xiangzi_h))||
		  (( xiangzi_h_1 < hsync_back_porch + 220)&&( xiangzi_h_1 >= hsync_back_porch + 180)&&
          ( xiangzi_v_1 >= vsync_back_porch + 220 )&&( xiangzi_v_1 < vsync_back_porch + 440 )&&(xiangzi_h_1 == xiangzi_h))||
	      ((xiangzi_v_11 < vsync_back_porch + 40) && (xiangzi_h_11 == xiangzi_h))||
	      (( xiangzi_h_11 < hsync_back_porch + 120 )&&( xiangzi_h_11 >= hsync_back_porch + 100 )&&
          ( xiangzi_v_11 >= vsync_back_porch + 220 )&&( xiangzi_v_11 < vsync_back_porch + 440 )&&(xiangzi_h_11 == xiangzi_h))||
	      (( xiangzi_h_11 < hsync_back_porch + 220)&&( xiangzi_h_11 >= hsync_back_porch + 180)&&
          ( xiangzi_v_11 >= vsync_back_porch + 220 )&&( xiangzi_v_11 < vsync_back_porch + 440 )&&(xiangzi_h_11 == xiangzi_h))||
	      ((xiangzi_v_111 < vsync_back_porch + 40) && (xiangzi_h_111 == xiangzi_h))||
	      (( xiangzi_h_111 < hsync_back_porch + 120 )&&( xiangzi_h_111 >= hsync_back_porch + 100 )&&
          ( xiangzi_v_111 >= vsync_back_porch + 220 )&&( xiangzi_v_111 < vsync_back_porch + 440 )&&(xiangzi_h_111 == xiangzi_h))||
		  (( xiangzi_h_111 < hsync_back_porch + 220)&&( xiangzi_h_111 >= hsync_back_porch + 180)&&
          ( xiangzi_v_111 >= vsync_back_porch + 220 )&&( xiangzi_v_111 < vsync_back_porch + 440 )&&(xiangzi_h_111 == xiangzi_h))   ) begin
            xiangzi_h <= xiangzi_h;
            xiangzi_v <= xiangzi_v;
	        end
	        else begin
	        xiangzi_h <= xiangzi_h;
            xiangzi_v <= xiangzi_v - 5'd20;
	         end
	 end
      else if((move_down == 1'b1)&&(win_point == 1'b0)  ) begin
           if((xiangzi_v >= vsync_back_porch + 520)||  (( xiangzi_h < hsync_back_porch + 120 )&&( xiangzi_h >= hsync_back_porch + 100 )&&
           ( xiangzi_v >= vsync_back_porch + 180 )&&( xiangzi_v < vsync_back_porch + 440 ))|| (( xiangzi_h < hsync_back_porch + 220)&&( xiangzi_h >= hsync_back_porch + 180)&&
           ( xiangzi_v >= vsync_back_porch + 180 )&&( xiangzi_v < vsync_back_porch + 440 ))|| ((xiangzi_v_1 >= vsync_back_porch + 520) && (xiangzi_h_1 == xiangzi_h))||
	       (( xiangzi_h_1 < hsync_back_porch + 120 )&&( xiangzi_h_1 >= hsync_back_porch + 100 )&&
           ( xiangzi_v_1 >= vsync_back_porch + 180 )&&( xiangzi_v_1 < vsync_back_porch + 440 )&&(xiangzi_h_1 == xiangzi_h))||
		   (( xiangzi_h_1 < hsync_back_porch + 220)&&( xiangzi_h_1 >= hsync_back_porch + 180)&&
           ( xiangzi_v_1 >= vsync_back_porch + 180 )&&( xiangzi_v_1 < vsync_back_porch + 440 )&&(xiangzi_h_1 == xiangzi_h))||
	       ((xiangzi_v_11 >= vsync_back_porch + 520) && (xiangzi_h_11 == xiangzi_h))||
	       (( xiangzi_h_11 < hsync_back_porch + 120 )&&( xiangzi_h_11 >= hsync_back_porch + 100 )&&
           ( xiangzi_v_11 >= vsync_back_porch + 180 )&&( xiangzi_v_11 < vsync_back_porch + 440 )&&(xiangzi_h_11 == xiangzi_h))||
		   (( xiangzi_h_11 < hsync_back_porch + 220)&&( xiangzi_h_11 >= hsync_back_porch + 180)&&
           ( xiangzi_v_11 >= vsync_back_porch + 180 )&&( xiangzi_v_11 < vsync_back_porch + 440 )&&(xiangzi_h_11 == xiangzi_h))||      
		   ((xiangzi_v_111 > vsync_back_porch + 520) && (xiangzi_h_111 == xiangzi_h))||
	       (( xiangzi_h_11 < hsync_back_porch + 120 )&&( xiangzi_h_11 >= hsync_back_porch + 100 )&&
           ( xiangzi_v_111 >= vsync_back_porch + 180 )&&( xiangzi_v_111 < vsync_back_porch + 440 )&&(xiangzi_h_111 == xiangzi_h))||
		   (( xiangzi_h_111 < hsync_back_porch + 220)&&( xiangzi_h_111 >= hsync_back_porch + 180)&&
           ( xiangzi_v_111 >= vsync_back_porch + 180 )&&( xiangzi_v_111 < vsync_back_porch + 440 )&&(xiangzi_h_111 == xiangzi_h)) )  begin
             xiangzi_h <= xiangzi_h;
             xiangzi_v <= xiangzi_v;
	         end
	         else begin
             xiangzi_h <= xiangzi_h;
             xiangzi_v <= xiangzi_v + 5'd20;
	         end
	 end
 end
 
 
	//第一个箱子移动的标志	
always@(posedge clk or negedge rst_n)
	begin
	     if(~rst_n)begin
	  move_left_1 <= 1'b0;
	  move_right_1 <= 1'b0;
	  move_up_1 <= 1'b0;
	  move_down_1 <= 1'b0;
    end
	else if (( xiangzi_h_1 == xiangzi_h - 20 )&&(  move_left == 1'b1 )&&(xiangzi_v_1 == xiangzi_v)) begin
	        move_left_1 <= 1'b1;
	end
    else if (( xiangzi_h_1 == xiangzi_h + 20 )&&( move_right == 1'b1)&&(xiangzi_v_1 == xiangzi_v) ) begin
	        move_right_1 <= 1'b1;
	end
	else if (( xiangzi_v_1 == xiangzi_v - 20 )&&( move_up == 1'b1 )&&( xiangzi_h_1 == xiangzi_h) ) begin
            move_up_1 <= 1'b1;	  
	end
	else if (( xiangzi_v_1 == xiangzi_v + 20 )&&( move_down == 1'b1)&&( xiangzi_h_1 == xiangzi_h) ) begin
	        move_down_1 <= 1'b1;
    end
	else begin
	  move_left_1 <= 1'b0;
	  move_right_1 <= 1'b0;
	  move_up_1 <= 1'b0;
	  move_down_1 <= 1'b0;
	end
	   
end
	//第二个箱子移动的标志	
always@(posedge clk or negedge rst_n)
    begin
	if(~rst_n)begin
	  move_left_2 <= 1'b0;
	  move_right_2 <= 1'b0;
	  move_up_2 <= 1'b0;
	  move_down_2 <= 1'b0;
    end
	else if (( xiangzi_h_11 == xiangzi_h - 20 )&&(  move_left == 1'b1 )&&(xiangzi_v_11 == xiangzi_v)) begin
	        move_left_2 <= 1'b1;
	        end
    else if (( xiangzi_h_11 == xiangzi_h + 20 )&&( move_right == 1'b1)&&(xiangzi_v_11 == xiangzi_v) ) begin
	        move_right_2 <= 1'b1;
	        end
    else if (( xiangzi_v_11 == xiangzi_v - 20 )&&( move_up == 1'b1 )&&( xiangzi_h_11 == xiangzi_h) ) begin
            move_up_2 <= 1'b1;	  
			end
	else if (( xiangzi_v_11 == xiangzi_v + 20 )&&( move_down == 1'b1)&&( xiangzi_h_11 == xiangzi_h) ) begin
	        move_down_2 <= 1'b1;
            end
	else begin
	  move_left_2 <= 1'b0;
	  move_right_2 <= 1'b0;
	  move_up_2 <= 1'b0;
	  move_down_2 <= 1'b0;
    end
	   
end
	//第三个箱子移动的标志	
always@(posedge clk or negedge rst_n)
	begin
	     if(~rst_n)begin
	  move_left_3 <= 1'b0;
	  move_right_3 <= 1'b0;
	  move_up_3 <= 1'b0;
	  move_down_3 <= 1'b0;
    end
	else if (( xiangzi_h_111 == xiangzi_h - 20 )&&(  move_left == 1'b1 )&&(xiangzi_v_111 == xiangzi_v)) begin
	        move_left_3 <= 1'b1;
	        end
    else if (( xiangzi_h_111 == xiangzi_h + 20 )&&( move_right == 1'b1)&&(xiangzi_v_111 == xiangzi_v) ) begin
	        move_right_3 <= 1'b1;
	        end
	else if (( xiangzi_v_111 == xiangzi_v - 20 )&&( move_up == 1'b1 )&&( xiangzi_h_111 == xiangzi_h) ) begin
            move_up_3 <= 1'b1;	  
	        end
	else if (( xiangzi_v_111 == xiangzi_v + 20 )&&( move_down == 1'b1)&&( xiangzi_h_111 == xiangzi_h) ) begin
	        move_down_3 <= 1'b1;
            end
	else begin
	  move_left_3 <= 1'b0;
	  move_right_3 <= 1'b0;
	  move_up_3 <= 1'b0;
	  move_down_3 <= 1'b0;
	end
end
 
 
//到达目标点的箱子不能再移动
	 //数字位数表示第几个箱子/点，1表示箱子，2表示点
	
	//箱子1到达固定点不动。
always@(posedge clk or negedge rst_n)
	 begin
	     if(~rst_n)begin
	     win_point_1 <= 1'b0;
	     end
	     else if((( xiangzi_h_1 == xiangzi_h_2)&&(xiangzi_v_1 == xiangzi_v_2 ))||(( xiangzi_h_1 == xiangzi_h_22)&&(xiangzi_v_1 == xiangzi_v_22))||(( xiangzi_h_1 == xiangzi_h_222)&&(xiangzi_v_1 == xiangzi_v_222 )))begin
	     win_point_1 <= 1'b1;
         end
         else begin
         win_point_1 <= 1'b0;
	     end
	 end
	  
	  
	  //箱子2到达固定点不动。
always@(posedge clk or negedge rst_n)
	 begin
	     if(~rst_n)begin
	     win_point_2 <= 1'b0;
	     end
	     else if((( xiangzi_h_11 == xiangzi_h_2)&&(xiangzi_v_11 == xiangzi_v_2 ))||(( xiangzi_h_11 == xiangzi_h_22)&&(xiangzi_v_11 == xiangzi_v_22))||(( xiangzi_h_11 == xiangzi_h_222)&&(xiangzi_v_11 == xiangzi_v_222 )))begin
	     win_point_2 <= 1'b1;
         end
         else begin
    	 win_point_2 <= 1'b0;
	     end
	end
	  //箱子3到达固定点不动。

 always@(posedge clk or negedge rst_n)
	begin
	     if(~rst_n)begin
	     win_point_3 <= 1'b0;
	     end
	     else if((( xiangzi_h_111 == xiangzi_h_2)&&(xiangzi_v_111 == xiangzi_v_2 ))||(( xiangzi_h_111 == xiangzi_h_22)&&(xiangzi_v_111 == xiangzi_v_22))||(( xiangzi_h_111 == xiangzi_h_222)&&(xiangzi_v_111 == xiangzi_v_222 )))begin
	     win_point_3 <= 1'b1;
         end
         else begin
         win_point_3 <= 1'b0;
	     end
	end


//箱子移动时的图像显示
always@(posedge clk or negedge rst_n)
	begin
		 if(~rst_n)begin
	     xiangzi_v_1 <= 10'd400;
	     xiangzi_h_1 <= 10'd400;
	     end
	     else if((move_left_1 == 1'b1)&&(win_point_1 == 1'b0))begin
           if((xiangzi_h_1 < hsync_back_porch - 120)||(( xiangzi_h_1 < hsync_back_porch + 140 )&&( xiangzi_h_1 >= hsync_back_porch + 120 )&&
           ( xiangzi_v_1 >= vsync_back_porch + 200 )&&( xiangzi_v_1 < vsync_back_porch + 420 ))|| (( xiangzi_h_1 < hsync_back_porch + 240)&&( xiangzi_h_1 >= hsync_back_porch + 200)&&
           ( xiangzi_v_1 >= vsync_back_porch + 200 )&&( xiangzi_v_1 < vsync_back_porch + 420 )))
 
            begin
            xiangzi_h_1 <= xiangzi_h_1;
            xiangzi_v_1 <= xiangzi_v_1;
	        end
	        else begin
            xiangzi_h_1 <= xiangzi_h_1 - 5'd20;
            xiangzi_v_1 <= xiangzi_v_1;
	        end
	     end
         else if((move_right_1 == 1'b1)&&(win_point_1 == 1'b0) )begin
            if((xiangzi_h_1 >= hsync_back_porch + 440 )|| (( xiangzi_h_1 < hsync_back_porch + 100 )&&( xiangzi_h_1 >= hsync_back_porch + 80 )&&
            ( xiangzi_v_1 >= vsync_back_porch + 200 )&&( xiangzi_v_1 < vsync_back_porch + 420 ))|| (( xiangzi_h_1 < hsync_back_porch + 180)&&( xiangzi_h_1 >= hsync_back_porch + 160)&&
            ( xiangzi_v_1 >= vsync_back_porch + 200 )&&( xiangzi_v_1 < vsync_back_porch + 420 )))   begin
             xiangzi_h_1 <= xiangzi_h_1;
             xiangzi_v_1 <= xiangzi_v_1;
	         end
	         else begin
             xiangzi_h_1 <= xiangzi_h_1 + 5'd20;
             xiangzi_v_1<= xiangzi_v_1;
	         end
	     end
         else if((move_up_1 == 1'b1)&&(win_point_1 == 1'b0)   ) begin
             if((xiangzi_v_1 < vsync_back_porch + 40)||  (( xiangzi_h_1 < hsync_back_porch + 120 )&&( xiangzi_h_1 >= hsync_back_porch + 100 )&&
             ( xiangzi_v_1 >= vsync_back_porch + 220 )&&( xiangzi_v_1 < vsync_back_porch + 440 ))||
		     (( xiangzi_h_1 < hsync_back_porch + 220)&&( xiangzi_h_1 >= hsync_back_porch + 180)&&
             ( xiangzi_v_1 >= vsync_back_porch + 220 )&&( xiangzi_v_1 < vsync_back_porch + 440 )))  begin
              xiangzi_h_1 <= xiangzi_h_1;
              xiangzi_v_1 <= xiangzi_v_1;
	          end
	          else begin
	          xiangzi_h_1 <= xiangzi_h_1;
              xiangzi_v_1 <= xiangzi_v_1 - 5'd20;
	          end
	     end
         else if((move_down_1 == 1'b1)&&(win_point_1 == 1'b0)  ) begin
              if((xiangzi_v_1 >= vsync_back_porch + 520)|| (( xiangzi_h_1 < hsync_back_porch + 120 )&&( xiangzi_h_1 >= hsync_back_porch + 100 )&&
             ( xiangzi_v_1 >= vsync_back_porch + 180 )&&( xiangzi_v_1 < vsync_back_porch + 440 ))||
		     (( xiangzi_h_1 < hsync_back_porch + 220)&&( xiangzi_h_1 >= hsync_back_porch + 180)&&
             ( xiangzi_v_1 >= vsync_back_porch + 180 )&&( xiangzi_v_1 < vsync_back_porch + 440 )))      
               begin
               xiangzi_h_1 <= xiangzi_h_1;
               xiangzi_v_1 <= xiangzi_v_1;
	           end
	           else begin
               xiangzi_h_1 <= xiangzi_h_1;
               xiangzi_v_1 <= xiangzi_v_1 + 5'd20;
	           end
	    end
        else begin 
        xiangzi_h_1 <= xiangzi_h_1;
        xiangzi_v_1 <= xiangzi_v_1;
        end
 end

always@(posedge clk or negedge rst_n)
	begin
	if(~rst_n)begin
    xiangzi_v_11 <= 10'd400;
    xiangzi_h_11 <= 10'd600;
    end
	else if((move_left_2 == 1'b1)&&(win_point_2 == 1'b0))begin
         if((xiangzi_h_11 < hsync_back_porch - 120)||(( xiangzi_h_11 < hsync_back_porch + 140 )&&( xiangzi_h_11 >= hsync_back_porch + 120 )&&
         ( xiangzi_v_11 >= vsync_back_porch + 200 )&&( xiangzi_v_11 < vsync_back_porch + 420 ))|| (( xiangzi_h_11 < hsync_back_porch + 240)&&( xiangzi_h_11 >= hsync_back_porch + 220)&&
         ( xiangzi_v_11 >= vsync_back_porch + 200 )&&( xiangzi_v_11 < vsync_back_porch + 420 )))
       begin
       xiangzi_h_11 <= xiangzi_h_11;
       xiangzi_v_11 <= xiangzi_v_11;
	   end
	   else begin
       xiangzi_h_11 <= xiangzi_h_11 - 5'd20;
       xiangzi_v_11 <= xiangzi_v_11;
	   end
	 end
     else if((move_right_2 == 1'b1)&&(win_point_2 == 1'b0) )begin
     if((xiangzi_h_11 >= hsync_back_porch + 440 ) ||(( xiangzi_h_11 < hsync_back_porch + 100 )&&( xiangzi_h_11 >= hsync_back_porch + 80 )&&
     ( xiangzi_v_11 >= vsync_back_porch + 200 )&&( xiangzi_v_11 < vsync_back_porch + 420 ))|| (( xiangzi_h_11 < hsync_back_porch + 180)&&( xiangzi_h_11 >= hsync_back_porch + 160)&&
     ( xiangzi_v_11 >= vsync_back_porch + 200 )&&( xiangzi_v_11 < vsync_back_porch + 420 )))  begin
        xiangzi_h_11 <= xiangzi_h_11;
        xiangzi_v_11 <= xiangzi_v_11;
	    end
	    else begin
        xiangzi_h_11 <= xiangzi_h_11 + 5'd20;
        xiangzi_v_11 <= xiangzi_v_11;
	    end
    end
     else if((move_up_2 == 1'b1)&&(win_point_2 == 1'b0)   ) begin
      if((xiangzi_v_11 < vsync_back_porch + 40) || (( xiangzi_h_11 < hsync_back_porch + 120 )&&( xiangzi_h_11 >= hsync_back_porch + 100 )&&
      ( xiangzi_v_11 >= vsync_back_porch + 220 )&&( xiangzi_v_11 < vsync_back_porch + 440 ))||
	  (( xiangzi_h_11 < hsync_back_porch + 220)&&( xiangzi_h_11 >= hsync_back_porch + 180)&&
      ( xiangzi_v_11 >= vsync_back_porch + 220 )&&( xiangzi_v_11 < vsync_back_porch + 440 )))  begin
       xiangzi_h_11 <= xiangzi_h_11;
       xiangzi_v_11 <= xiangzi_v_11;
	   end
	   else begin
	   xiangzi_h_11 <= xiangzi_h_11;
       xiangzi_v_11 <= xiangzi_v_11 - 5'd20;
	   end
    end
      else if((move_down_2 == 1'b1)&&(win_point_2 == 1'b0)  ) begin
      if((xiangzi_v_11 >= vsync_back_porch + 520)|| (( xiangzi_h_11 < hsync_back_porch + 120 )&&( xiangzi_h_11 >= hsync_back_porch + 100 )&&
      ( xiangzi_v_11 >= vsync_back_porch + 180 )&&( xiangzi_v_11 < vsync_back_porch + 440 ))||
      (( xiangzi_h_11 < hsync_back_porch + 220)&&( xiangzi_h_11 >= hsync_back_porch + 180)&&
       ( xiangzi_v_11 >= vsync_back_porch + 180 )&&( xiangzi_v_11 < vsync_back_porch + 440 )))  begin
        xiangzi_h_11 <= xiangzi_h_11;
        xiangzi_v_11 <= xiangzi_v_11;
	    end
	    else begin
        xiangzi_h_11 <= xiangzi_h_11;
        xiangzi_v_11 <= xiangzi_v_11 + 5'd20;
	    end
	end
    else begin 
    xiangzi_h_11 <= xiangzi_h_11;
    xiangzi_v_11 <= xiangzi_v_11;
    end
end
	  
always@(posedge clk or negedge rst_n)
	begin
		if(~rst_n)begin
	    xiangzi_v_111 <= 10'd260;
	    xiangzi_h_111 <= 10'd260;
	    end
	    else if((move_left_3 == 1'b1)&&(win_point_3 == 1'b0))begin
        if((xiangzi_h_111 < hsync_back_porch - 120 ) ||(( xiangzi_h_111 < hsync_back_porch + 140 )&&( xiangzi_h_111 >= hsync_back_porch + 120 )&&
        ( xiangzi_v_111 >= vsync_back_porch + 200 )&&( xiangzi_v_111 < vsync_back_porch + 420 ))|| (( xiangzi_h_111 < hsync_back_porch + 240)&&( xiangzi_h_111 >= hsync_back_porch + 220)&&
        ( xiangzi_v_111 >= vsync_back_porch + 200 )&&( xiangzi_v_111 < vsync_back_porch + 420 )))  begin
             xiangzi_h_111 <= xiangzi_h_111;
             xiangzi_v_111 <= xiangzi_v_111;
	         end
	         else begin
             xiangzi_h_111 <= xiangzi_h_111 - 5'd20;
             xiangzi_v_111 <= xiangzi_v_111;
	         end
	    end
        else if((move_right_3 == 1'b1)&&(win_point_3 == 1'b0) )begin
             if((xiangzi_h_111 >= hsync_back_porch + 440 )||(( xiangzi_h_111 < hsync_back_porch + 100 )&&( xiangzi_h_111 >= hsync_back_porch + 80 )&&
             ( xiangzi_v_111 >= vsync_back_porch + 200 )&&( xiangzi_v_111 < vsync_back_porch + 420 ))|| (( xiangzi_h_111 < hsync_back_porch + 180)&&( xiangzi_h_111 >= hsync_back_porch + 160)&&
             ( xiangzi_v_111 >= vsync_back_porch + 200 )&&( xiangzi_v_111 < vsync_back_porch + 420 )))
 
              begin
              xiangzi_h_111 <= xiangzi_h_111;
              xiangzi_v_111 <= xiangzi_v_111;
	          end
	          else begin
              xiangzi_h_111 <= xiangzi_h_111 + 5'd20;
              xiangzi_v_111 <= xiangzi_v_111;
	          end
	    end
        else if((move_up_3 == 1'b1)&&(win_point_3 == 1'b0)   ) begin
             if((xiangzi_v_111 < vsync_back_porch + 40) ||(( xiangzi_h_111 < hsync_back_porch + 120 )&&( xiangzi_h_111 >= hsync_back_porch + 100 )&&
             ( xiangzi_v_111 >= vsync_back_porch + 220 )&&( xiangzi_v_111 < vsync_back_porch + 440 ))||
		     (( xiangzi_h_111 < hsync_back_porch + 220)&&( xiangzi_h_111 >= hsync_back_porch + 180)&&
             (xiangzi_v_111 >= vsync_back_porch + 220 )&&( xiangzi_v_111 < vsync_back_porch + 440 )))   begin
             xiangzi_h_111 <= xiangzi_h_111;
             xiangzi_v_111 <= xiangzi_v_111;
	         end
	         else begin
	         xiangzi_h_111 <= xiangzi_h_111;
             xiangzi_v_111 <= xiangzi_v_111 - 5'd20;
	         end
	    end
        else if((move_down_3 == 1'b1)&&(win_point_3 == 1'b0)  ) begin
             if((xiangzi_v_111 >= vsync_back_porch + 520)  ||(( xiangzi_h_111 < hsync_back_porch + 120 )&&( xiangzi_h_111 >= hsync_back_porch + 100 )&&
             ( xiangzi_v_111 >= vsync_back_porch + 180 )&&( xiangzi_v_111 < vsync_back_porch + 440 ))||
		     (( xiangzi_h_111 < hsync_back_porch + 220)&&( xiangzi_h_111 >= hsync_back_porch + 180)&&
             ( xiangzi_v_111 >= vsync_back_porch + 180 )&&( xiangzi_v_111 < vsync_back_porch + 440 )))   begin
             xiangzi_h_111 <= xiangzi_h_111;
             xiangzi_v_111 <= xiangzi_v_111;
	         end
	         else begin
             xiangzi_h_111 <= xiangzi_h_111;
             xiangzi_v_111 <= xiangzi_v_111+ 5'd20;
	         end
	    end
        else begin 
        xiangzi_h_111 <= xiangzi_h_111;
        xiangzi_v_111 <= xiangzi_v_111;
         end
     end
	  
reg			 enable_green;
reg[1374:0]  over_word; 
reg[1199:0]  over_word_1;
reg[399:0]   over_word_2;
reg[20:0]	 h;
reg[20:0]	 v;
	
reg enable_red_1;
reg enable_red_2;
reg enable_red_3;
reg enable_blue_2;

reg [20:0]   h_1;
reg [20:0]   v_1;
reg [20:0]   h_2;
reg [20:0]   v_2;
reg [20:0]   h_3;
reg [20:0]   v_3;
reg [20:0]   h_4;
reg [20:0]   v_4;

parameter hsync_sync        = 80;
parameter vsync_sync        =3;
	  
//产生行同步信号  
always@(posedge clk or negedge rst_n)
begin
 if(~rst_n)begin
	   vga_hsync<=1'b1;
	end
    else if((h_cnt>=11'd0)&&(h_cnt < hsync_sync))begin
      vga_hsync<=1'b0;
    end
    else begin
    vga_hsync<=1'b1;
   end
 end  


//产生帧同步 
always@(posedge clk or negedge rst_n)
begin
 if(~rst_n)begin
	   vga_vsync<=1'b1;
	end
    else if((v_cnt>=10'd0)&&(v_cnt < vsync_sync))begin
      vga_vsync<=1'b0;
    end
    else begin
    vga_vsync<=1'b1;
   end
 end 
	
	
	always@(posedge clk or negedge rst_n)
 begin
	over_word_1[19:0]      ='b11111_11111_11111_11111;
	over_word_1[39:20]     ='b11111_11111_11111_11111;
	over_word_1[59:40]     ='b11111_11111_11111_11111;
	over_word_1[79:60]     ='b11111_00000_00000_11111;
	over_word_1[99:80]     ='b11111_00000_00000_11111;	
   over_word_1[119:100]   ='b11111_00000_00000_11111;
	over_word_1[139:120]   ='b11111_00000_00000_11111;
	over_word_1[159:140]   ='b11111_00000_00000_11111;
	over_word_1[179:160]   ='b11111_00000_00000_11111;
	over_word_1[199:180]   ='b11111_00000_00000_11111;
   over_word_1[219:200]   ='b11111_00000_00000_11111;
	over_word_1[239:220]   ='b11111_00000_00000_11111;
	over_word_1[259:240]   ='b11111_00000_00000_11111;
	over_word_1[279:260]   ='b11111_00000_00000_11111;
	over_word_1[299:280]   ='b11111_00000_00000_11111;	
	over_word_1[319:300]   ='b11111_00000_00000_11111;	
	over_word_1[339:320]   ='b11111_00000_00000_11111;
	over_word_1[359:340]   ='b11111_11111_11111_11111;
	over_word_1[379:360]   ='b11111_11111_11111_11111;
	over_word_1[399:380]   ='b11111_11111_11111_11111;	//目标点1
	
	over_word_1[419:400]   ='b11111_11111_11111_11111;
	over_word_1[439:420]   ='b11111_11111_11111_11111;
	over_word_1[459:440]   ='b11111_11111_11111_11111;
	over_word_1[479:460]   ='b11111_00000_00000_11111;
	over_word_1[499:480]   ='b11111_00000_00000_11111;	
   over_word_1[519:500]   ='b11111_00000_00000_11111;
	over_word_1[539:520]   ='b11111_00000_00000_11111;
	over_word_1[559:540]   ='b11111_00000_00000_11111;
	over_word_1[579:560]   ='b11111_00000_00000_11111;
	over_word_1[599:580]   ='b11111_00000_00000_11111;
   over_word_1[619:600]   ='b11111_00000_00000_11111;
	over_word_1[639:620]   ='b11111_00000_00000_11111;
	over_word_1[659:640]   ='b11111_00000_00000_11111;
	over_word_1[679:660]   ='b11111_00000_00000_11111;
	over_word_1[699:680]   ='b11111_00000_00000_11111;	
	over_word_1[719:700]   ='b11111_00000_00000_11111;	
	over_word_1[739:720]   ='b11111_00000_00000_11111;
	over_word_1[759:740]   ='b11111_11111_11111_11111;
	over_word_1[779:760]   ='b11111_11111_11111_11111;
	over_word_1[799:780]   ='b11111_11111_11111_11111;	//目标点2
	
	over_word_1[819:800]     ='b11111_11111_11111_11111;
	over_word_1[839:820]     ='b11111_11111_11111_11111;
	over_word_1[859:840]     ='b11111_11111_11111_11111;
	over_word_1[879:860]     ='b11111_00000_00000_11111;
	over_word_1[899:880]     ='b11111_00000_00000_11111;	
   over_word_1[919:900]     ='b11111_00000_00000_11111;
	over_word_1[939:920]     ='b11111_00000_00000_11111;
	over_word_1[959:940]     ='b11111_00000_00000_11111;
	over_word_1[979:960]     ='b11111_00000_00000_11111;
	over_word_1[999:980]     ='b11111_00000_00000_11111;
   over_word_1[1019:1000]   ='b11111_00000_00000_11111;
	over_word_1[1039:1020]   ='b11111_00000_00000_11111;
	over_word_1[1059:1040]   ='b11111_00000_00000_11111;
	over_word_1[1079:1060]   ='b11111_00000_00000_11111;
	over_word_1[1099:1080]   ='b11111_00000_00000_11111;	
	over_word_1[1119:1100]   ='b11111_00000_00000_11111;	
	over_word_1[1139:1120]   ='b11111_00000_00000_11111;
	over_word_1[1159:1140]   ='b11111_11111_11111_11111;
	over_word_1[1179:1160]   ='b11111_11111_11111_11111;
	over_word_1[1199:1180]   ='b11111_11111_11111_11111;	//目标点3
end

	//目标点的颜色设置,依次为1,2,3三个目标点
always@(posedge clk or negedge rst_n) 
 begin
	if(~rst_n)begin
		enable_red_1 = 0;
		h_1 = 0;
		v_1 = 0;
	 end	
     else begin
		if(win_point_flg == 1'b1 )begin
			h_1 = (h_cnt -( xiangzi_h_2 + hsync_back_porch ));
			v_1 = (v_cnt -( xiangzi_v_2 + vsync_back_porch ));
			if(over_word_1[19 - h_1 + v_1 * 20] == 1) begin
				enable_red_1 = 1;
		    end
	        else  begin
			enable_red_1 = 0;
			end
	     end
     else begin
				enable_red_1 = 0;
		   end
	end
end
	
always@(posedge clk or negedge rst_n) 
begin
	if(~rst_n)begin
		enable_red_2 = 0;
		h_2 = 0;
		v_2 = 0;
	end	
    else begin
		if(win_point_flg_1 == 1'b1 )begin
			h_2 = (h_cnt - (xiangzi_h_22 + hsync_back_porch));
			v_2 = (v_cnt - (xiangzi_v_22 + vsync_back_porch));
			if(over_word_1[419 - h_2 + v_2 * 20] == 1) 
				enable_red_2 = 1;
			else  
				enable_red_2 = 0;
		     end
		
        else 
				enable_red_2 = 0;
	end
end
	
	
always@(posedge clk or negedge rst_n) 
begin
	if(~rst_n)begin
		enable_red_3 = 0;
		h_3 = 0;
		v_3 = 0;
	end	
    else begin
		if(win_point_flg_2 == 1'b1 )begin
			h_3 = (h_cnt - (xiangzi_h_222 + hsync_back_porch));
			v_3 = (v_cnt - (xiangzi_v_222 + vsync_back_porch));
			if(over_word_1[819 - h_3 + v_3 * 20] == 1) 
				enable_red_3 = 1;
			else  
				enable_red_3 = 0;
		     end
		
        else 
				enable_red_3 = 0;
	end
end
	
	
//小人输出图像设置
always@(posedge clk or negedge rst_n)
begin
	over_word_2[19:0]      ='b00000_00111_11100_00000;
	over_word_2[39:20]     ='b00000_00111_11100_00000;
	over_word_2[59:40]     ='b00000_00011_11000_00000;
	over_word_2[79:60]     ='b00000_00011_11000_00000;
	over_word_2[99:80]     ='b00001_11111_11111_10000;	
   over_word_2[119:100]   ='b00001_11111_11111_10000;
	over_word_2[139:120]   ='b11111_11111_11111_11111;
	over_word_2[159:140]   ='b11111_11111_11111_11111;
	over_word_2[179:160]   ='b11111_11111_11111_11111;
	over_word_2[199:180]   ='b00001_11111_11111_10000;
   over_word_2[219:200]   ='b00001_11111_11111_10000;
	over_word_2[239:220]   ='b00001_11111_11111_10000;
	over_word_2[259:240]   ='b00000_11100_00111_00000;
	over_word_2[279:260]   ='b00000_11100_00111_00000;
	over_word_2[299:280]   ='b00000_11100_00111_00000;	
	over_word_2[319:300]   ='b00000_11100_00111_00000;
	over_word_2[339:320]   ='b00000_11100_00111_00000;
	over_word_2[359:340]   ='b00000_11100_00111_00000;
	over_word_2[379:360]   ='b00000_11100_00111_00000;
	over_word_2[399:380]   ='b00000_11100_00111_00000;	//小人
	end
	
	//小人颜色输出
	always@(posedge clk or negedge rst_n) 
begin
	if(~rst_n)begin
		enable_blue_2 = 0;
		h_4 = 0;
		v_4 = 0;
	end	
else begin
		if(xiangzi_biaozhi == 1'b1 )begin
			h_4 = (h_cnt - (xiangzi_h + hsync_back_porch));
			v_4 = (v_cnt - (xiangzi_v + vsync_back_porch));
			if(over_word_2[20 - h_4 + v_4 * 20] == 1) 
				enable_blue_2 = 1;
			else  
				enable_blue_2 = 0;
		 end
         else 
				enable_blue_2 = 0;
	end
end	


	//you win显示
	always@(posedge clk or negedge rst_n)
begin				
	over_word[14:0]     ='b11100_00000_00111;
	over_word[29:15]    ='b11100_00000_00111;
	over_word[44:30]    ='b01110_00000_01110;
	over_word[59:45]    ='b01110_00000_01110;
	over_word[74:60]    ='b00111_00000_11100;
	over_word[89:75]    ='b00011_10001_11000;
	over_word[104:90]   ='b00001_11011_10000;
	over_word[119:105]  ='b00001_11011_10000;
	over_word[134:120]  ='b00000_11111_00000;
	over_word[149:135]  ='b00000_11111_00000;
	over_word[164:150]  ='b00000_11111_00000;
	over_word[179:165]  ='b00000_11111_00000;
	over_word[194:180]  ='b00000_11111_00000;
	over_word[209:195]  ='b00000_11111_00000;
	over_word[224:210]  ='b00000_11111_00000;//y
	
	over_word[244:230]  ='b00111_11111_11100;
	over_word[259:245]  ='b01111_11111_11110;
	over_word[274:260]  ='b11111_00000_11111;
	over_word[289:275]  ='b11111_00000_11111;
	over_word[304:290]  ='b11111_00000_11111;
	over_word[319:305]  ='b11111_00000_11111;
	over_word[334:320]  ='b11111_00000_11111;
	over_word[349:335]  ='b11111_00000_11111;
	over_word[364:350]  ='b11111_00000_11111;
	over_word[379:365]  ='b11111_00000_11111;
	over_word[394:380]  ='b11111_00000_11111;
	over_word[409:395]  ='b11111_00000_11111;
	over_word[424:410]  ='b11111_00000_11111;
	over_word[439:425]  ='b01111_11111_11110;
	over_word[454:440]  ='b00111_11111_11100;//o
	
	over_word[474:460]  ='b11111_00000_11111;
	over_word[489:475]  ='b11111_00000_11111;
	over_word[504:490]  ='b11111_00000_11111;
	over_word[519:505]  ='b11111_00000_11111;
	over_word[534:520]  ='b11111_00000_11111;
	over_word[549:535]  ='b11111_00000_11111;
	over_word[564:550]  ='b11111_00000_11111;
	over_word[579:565]  ='b11111_00000_11111;
	over_word[594:580]  ='b11111_00000_11111;
	over_word[609:595]  ='b11111_00000_11111;
	over_word[624:610]  ='b11111_00000_11111;
	over_word[639:625]  ='b11111_00000_11111;
	over_word[654:640]  ='b01111_00000_11110;
	over_word[669:655]  ='b00111_11111_11100;
	over_word[684:670]  ='b00111_11111_11100;//u
	
	over_word[704:690]  ='b11000_01110_00011;
	over_word[719:705]  ='b11000_01110_00011;
	over_word[734:720]  ='b11000_01110_00011;
	over_word[749:735]  ='b11000_01110_00011;
	over_word[764:750]  ='b11000_01010_00011;
	over_word[779:765]  ='b11000_01010_00011;
	over_word[794:780]  ='b01100_01010_00110;
	over_word[809:795]  ='b01100_01010_00110;
	over_word[824:810]  ='b01100_11011_00110;
	over_word[839:825]  ='b01100_11011_00110;
	over_word[854:840]  ='b01100_11011_00110;
	over_word[869:855]  ='b00110_11011_01100;
	over_word[884:870]  ='b00110_11011_01100;
	over_word[899:885]  ='b00110_10001_01100;
	over_word[914:900]  ='b00011_10001_11000;//w
	
	over_word[934:920]	 ='b00000_11111_00000;
	over_word[949:935]    ='b00000_11111_00000;
	over_word[964:950]    ='b00000_11111_00000;
	over_word[979:965]    ='b00000_11111_00000;
	over_word[994:980]    ='b00000_11111_00000;
	over_word[1009:995]   ='b00000_11111_00000;
	over_word[1024:1010]  ='b00000_11111_00000;
	over_word[1039:1025]  ='b00000_11111_00000;
	over_word[1054:1040]  ='b00000_11111_00000;
	over_word[1069:1055]  ='b00000_11111_00000;
	over_word[1084:1070]  ='b00000_11111_00000;
	over_word[1099:1085]  ='b00000_11111_00000;
	over_word[1114:1100]  ='b00000_11111_00000;
	over_word[1129:1115]  ='b00000_11111_00000;
	over_word[1144:1130]  ='b00000_11111_00000;//i
	
	over_word[1164:1150]  ='b11111_00000_00111;
	over_word[1179:1165]  ='b11101_10000_00111;
	over_word[1194:1180]  ='b11101_10000_00111;
	over_word[1209:1195]  ='b11100_11000_00111;
	over_word[1224:1210]  ='b11100_11000_00111;
	over_word[1239:1225]  ='b11100_01100_00111;
	over_word[1254:1240]  ='b11100_01100_00111;
	over_word[1269:1255]  ='b11100_01100_00111;
	over_word[1284:1270]  ='b11100_00110_00111;
	over_word[1299:1285]  ='b11100_00110_00111;
	over_word[1314:1300]  ='b11100_00011_00111;
	over_word[1329:1315]  ='b11100_00011_00111;
	over_word[1344:1330]  ='b11100_00001_10111;
	over_word[1359:1345]  ='b11100_00001_10111;
	over_word[1374:1360]  ='b11100_00000_11111;//n
		
	
end

	//clever颜色设置
always@(posedge clk or negedge rst_n) 
begin
	if(~rst_n)begin
		enable_green = 0;
		h = 0;
		v = 0;
	end		
	else begin
		if((h_cnt > 240) && (h_cnt < 360) && (v_cnt > 240) && (v_cnt < 360))begin
			h = (h_cnt - 240)/8;
			v = (v_cnt - 240)/8;
			if(over_word[ 14 - h + v * 15] == 1) 
				enable_green = 1;
			else  
				enable_green = 0;
		end	
		else if((h_cnt > 380) && (h_cnt < 500) && (v_cnt > 240) && (v_cnt < 360))begin
			h = (h_cnt - 380)/8;
			v = (v_cnt - 240)/8;
			if(over_word[ 244 - h + v * 15] == 1) 
				enable_green = 1;
			else  
				enable_green = 0;
		end	
		else if((h_cnt > 520) && (h_cnt < 640) && (v_cnt > 240) && (v_cnt < 360))begin
			h = (h_cnt - 520)/8;
			v = (v_cnt - 240)/8;
			if(over_word[ 474 - h + v * 15] == 1) 
				enable_green = 1;
			else  
				enable_green = 0;
		end	
		else if((h_cnt > 660) && (h_cnt < 780) && (v_cnt > 240) && (v_cnt < 360))begin
			h = (h_cnt - 660)/8;
			v = (v_cnt - 240)/8;
			if(over_word[ 704 - h + v * 15] == 1) 
				enable_green = 1;
			else  
				enable_green = 0;
		end			
	
        else if((h_cnt > 800) && (h_cnt < 920) && (v_cnt > 240) && (v_cnt < 360))begin
			h = (h_cnt - 800)/8;
			v = (v_cnt - 240)/8;
			if(over_word[ 934 - h + v * 15] == 1) 
				enable_green = 1;
			else  
				enable_green = 0;
		end		
		
		else if((h_cnt > 940) && (h_cnt < 1060) && (v_cnt > 240) && (v_cnt < 360))begin
			h = (h_cnt - 940)/8;
			v = (v_cnt - 240)/8;
			if(over_word[ 1164 - h + v * 15] == 1) 
				enable_green = 1;
			else  
				enable_green = 0;
		    end		
	    else 
				enable_green = 0;
	end
end


	//7个模块
	display m1(clk,rst_n,win_point_1,win_point_2,win_point_3,led,seg);
	
	divider m2(clk,rst_n,s_counter3_flg);
	
	people_move m3(clk,rst_n,BTN_WEST,BTN_EAST,BTN_SOUTH,BTN_NORTH,s_counter3_flg,
	move_left, move_right,move_up,move_down);

	enabled_color m6(clk,rst_n,biankuang,zhangai_1,zhangai_2,xiangzi_biaozhi,
	xiangzi_show,xiangzi_show_1,xiangzi_show_2,win_point,win_point_1,win_point_2,
	win_point_flg,win_point_flg_1,win_point_flg_2,enable_green,enable_blue_2,enable_red_1,enable_red_2,enable_red_3,
	vga_red,vga_green,vga_blue);
	
	judge m7(clk,rst_n,win_point_1,win_point_2,win_point_3,win_point);
	
endmodule 

//分频器
module divider(
	input clk,
	input rst_n,
	output reg s_counter3_flg
	);
	//计时0.2S
	reg [9:0] s_counter1;
	reg [9:0] s_counter2;
	reg [9:0] s_counter3;
	reg s_counter2_flg;
	
always@(posedge clk or negedge rst_n)
begin
    if(~rst_n) begin
	    s_counter1 <=6'd0;
	end
	else if(s_counter1 == 6'd49) begin
		s_counter1 <=6'd0;
	end
	else begin
		s_counter1 <= s_counter1 + 6'd1;
	end
end
//分频后s_counter1为1MHz

always@(posedge clk or negedge rst_n)
begin
    if(~rst_n) begin
	    s_counter2 <= 10'd0;
		s_counter2_flg <= 1'd0;
	end
    else if(s_counter1 ==6'd49) begin
        if(s_counter2 ==10'd999) begin
			s_counter2_flg <= 1'd1;
			s_counter2     <= 10'd0;
		end
		else begin
		s_counter2_flg <= 1'd0;
		s_counter2     <= s_counter2 + 10'd1;
		end
	end
	else begin
		s_counter2_flg <= 1'd0;
		s_counter2     <= s_counter2;
	end
end
//分频后s_counter2_flg为1kHz
	  
always@(posedge clk or negedge rst_n)
begin
    if(~rst_n) begin
	    s_counter3 <= 10'd0;
		s_counter3_flg <= 1'd0;
	end
    else if(s_counter2_flg ==1'd1) begin
        if(s_counter3 ==10'd199) begin
			s_counter3_flg <= 1'd1;
			s_counter3     <= 10'd0;
		end
	    else begin
			s_counter3_flg <= 1'd0;
			s_counter3     <= s_counter3 + 10'd1;
	    end
	end
    else begin
		s_counter3_flg <= 1'd0;
		s_counter3     <= s_counter3;
	end
end
//分频后s_counter3_flg为5Hz
endmodule

//判断和执行小人移动
module people_move(
input clk,
input rst_n,
input BTN_WEST,
input BTN_EAST,
input BTN_SOUTH,
input BTN_NORTH,
input s_counter3_flg,
output reg move_left,
output reg move_right,
output reg move_up,
output reg move_down
	);
	always@(posedge clk or negedge rst_n )begin
     if(~rst_n)begin
     move_left <= 1'b0;
     move_right <= 1'b0;
     move_up <= 1'b0;
     move_down <= 1'b0;
     end
	  
     else if ((BTN_WEST==1)&&(s_counter3_flg == 1'b1 ))begin
     move_left <= 1'b1;
     end
     else if ((BTN_EAST==1)&& (s_counter3_flg == 1'b1) )begin
     move_right <= 1'b1;
     end
     else if ((BTN_NORTH==1) &&(s_counter3_flg == 1'b1) )begin
     move_up <= 1'b1;
     end
     else if ((BTN_SOUTH==1) &&(s_counter3_flg == 1'b1) )begin
     move_down <= 1'b1;
     end
     else begin
     move_left <= 1'b0;
     move_right <= 1'b0;
     move_up <= 1'b0;
     move_down <= 1'b0;
     end
	  end
endmodule 


//最终获胜判断
module judge(
	input clk,
	input rst_n,
	input win_point_1,
	input win_point_2,
	input win_point_3,
	output reg win_point
	);
	//胜利点..
always@(posedge clk or negedge rst_n)
    begin
         if(~rst_n)begin
	     win_point <= 1'b0;
	     end
	     else if ((win_point_1 == 1'b1)&&( win_point_2 == 1'b1 )&&(win_point_3 == 1'b1))
      	 begin
         win_point <= 1'b1;
	     end
	     else begin
	     win_point <= 1'b0;
	     end
	end
		
endmodule



	//边框 背景输出颜色控制,enable颜色与vga颜色接口对接
module enabled_color(
input clk,
input rst_n,
input biankuang,
input zhangai_1,
input zhangai_2,
input xiangzi_biaozhi,
input xiangzi_show,
input xiangzi_show_1,
input xiangzi_show_2,
input win_point,
input win_point_1,
input win_point_2,
input win_point_flg,
input win_point_flg_1,
input win_point_flg_2,
input enable_green,
input enable_blue_2,
input enable_red_1,
input enable_red_2,
input enable_red_3,
output reg vga_red,
output reg vga_green,
output reg vga_blue
	);
	
 always@(posedge clk or negedge rst_n)
begin
	if(~rst_n) begin
		vga_blue  <=1'b0;
	   vga_green <=1'b0;
		vga_red   <=1'b0;
	end
	else if (  win_point == 1'b1 ) begin
	   vga_blue  <=1'b0;
	   vga_green <= enable_green;
		vga_red   <=1'b0;
		end
	else if (( xiangzi_biaozhi == 1'b1 )&&( win_point == 1'b0 ))begin
	    if (enable_blue_2 == 1'b1 )begin
		vga_blue  <=1'b1;
	   vga_green <=1'b0;
		vga_red   <=1'b0;
	  end
	  else begin
	    vga_blue  <=1'b1;
	    vga_green <=1'b1;
		vga_red   <=1'b1;
		end
		end
	else if (( xiangzi_show == 1'b1  )&&( win_point == 1'b0 )) begin
	    vga_blue  <=1'b0;
	    vga_green <=1'b1;
		vga_red   <=1'b0;
		end
	else if (( xiangzi_show_1 == 1'b1  )&&( win_point == 1'b0 )) begin
	    vga_blue  <=1'b0;
	    vga_green <=1'b1;
		vga_red   <=1'b0;
		end
	else if (( xiangzi_show_2 == 1'b1  )&&( win_point == 1'b0 )) begin
	    vga_blue  <=1'b0;
	    vga_green <=1'b1;
		vga_red   <=1'b0;
		end
		
	else if (( win_point_flg == 1'b1  ) &&( win_point == 1'b0 ))begin
	    if (enable_red_1 == 1'b1 )begin
		vga_blue  <=1'b0;
	    vga_green <=1'b0;
		vga_red   <=1'b1;
	  end
	  else begin
	    vga_blue  <=1'b1;
	    vga_green <=1'b1;
		vga_red   <=1'b1;
		end
		end
	else if (( win_point_flg_1 == 1'b1  ) &&( win_point == 1'b0 ))begin
	    if (enable_red_2 == 1'b1 )begin
		vga_blue  <=1'b0;
	    vga_green <=1'b0;
		vga_red   <=1'b1;
	  end
	  else begin
	    vga_blue  <=1'b1;
	    vga_green <=1'b1;
		vga_red   <=1'b1;
		end
		end
	else if (( win_point_flg_2 == 1'b1  ) &&( win_point == 1'b0 ))begin
	     if (enable_red_3 == 1'b1 )begin
		vga_blue  <=1'b0;
	    vga_green <=1'b0;
		vga_red   <=1'b1;
	  end
	  else begin
	    vga_blue  <=1'b1;
	    vga_green <=1'b1;
		vga_red   <=1'b1;
		end
		end
	else if (( zhangai_1 == 1'b1  )&&( win_point == 1'b0 )) begin
	    vga_blue  <=1'b1;
	    vga_green <=1'b1;
		vga_red   <=1'b0;
		end
	else if (( zhangai_2 == 1'b1  )&&( win_point == 1'b0 )) begin
	    vga_blue  <=1'b1;
	    vga_green <=1'b1;
		vga_red   <=1'b0;
		end

	else if((xiangzi_biaozhi == 1'b0)&&(xiangzi_show == 1'b0)&&(win_point_flg == 1'b0)&&(biankuang == 1'b1)&&( win_point == 1'b0 )&&
	     ( xiangzi_show_1 == 1'b0 )&&( win_point_flg_1 == 1'b0 )&&( xiangzi_show_2 == 1'b0 )&&( win_point_flg_2 == 1'b0 )&&
		 (zhangai_1 == 1'b0)&&(zhangai_2 == 1'b0))begin
	    vga_blue  <=1'b1;
	    vga_green <=1'b1;
		vga_red   <=1'b1;
	end
	else begin 
	    vga_blue  <=1'b0;
	    vga_green <=1'b0;
		vga_red   <=1'b0;
	end
end

endmodule 



module display(
	input clk,
	input rst_n,
	input win_point_1,
	input win_point_2,
	input win_point_3,
	output reg [1:0]led,
	output reg [6:0]seg
	);
	
	always@(posedge clk or negedge rst_n)
	begin
	     if(~rst_n)begin
		  led<=2'b00;
		  seg<=7'b1000000;
		  end
		  else if((win_point_1==1'b0)&&(win_point_2==1'b0)&&(win_point_3==1'b0))begin
					led<=2'b00;
					seg<=7'b1000000;
					end
		  else if(((win_point_1==1'b1)&&(win_point_2==1'b0)&&(win_point_3==1'b0))
					||((win_point_1==1'b0)&&(win_point_2==1'b1)&&(win_point_3==1'b0))
					||((win_point_1==1'b0)&&(win_point_2==1'b0)&&(win_point_3==1'b1)))begin
					led<=2'b01;
					seg<=7'b1111001;
					end
			else if(((win_point_1==1'b1)&&(win_point_2==1'b1)&&(win_point_3==1'b0))
					||((win_point_1==1'b0)&&(win_point_2==1'b1)&&(win_point_3==1'b1))
					||((win_point_1==1'b1)&&(win_point_2==1'b0)&&(win_point_3==1'b1)))begin
					led<=2'b10;
					seg<=7'b0100100;
					end
			else if((win_point_1==1'b1)&&(win_point_2==1'b1)&&(win_point_3==1'b1))
					begin
					led<=2'b11;
					seg<=7'b0110000;
					end
	end
endmodule
