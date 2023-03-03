/****************************/
//作者:Wei Xuejing
//邮箱:2682152871@qq.com
//描述:VGA 640*480@60Hz的驱动
//时间:2023.01.30
/****************************/

`include "define.v"
module  vga_driver
(
    input   wire            vga_clk     ,   //输入工作时钟,频率25MHz
    input   wire            rstn   ,   //输入复位信号,低电平有效
    //from vga_bmp
    input   wire    [11:0]  pixdata    ,   //输入像素点色彩信息
    //to vga_bmp\pic_ram
    output  wire    [11:0]  pix_x       ,   //输出VGA有效显示区域像素点X轴坐标
    output  wire    [11:0]  pix_y       ,   //输出VGA有效显示区域像素点Y轴坐标

    // output  reg     [11:0]  pix_x       ,   //输出VGA有效显示区域像素点X轴坐标
    // output  reg     [11:0]  pix_y       ,   //输出VGA有效显示区域像素点Y轴坐标
    
    input   wire            IsGameWindow,   //当前坐标式游戏画面的标志位
    //out pin
    output  wire            hsync       ,   //输出行同步信号
    output  wire            vsync       ,   //输出场同步信号
    output  wire    [11:0]  rgb             //输出像素点色彩信息
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
parameter H_SYNC    =   10'd96  ,   //行同步
          H_BACK    =   10'd40  ,   //行时序后沿
          H_LEFT    =   10'd8   ,   //行时序左边框
          H_VALID   =   10'd640 ,   //行有效数据
          H_RIGHT   =   10'd8   ,   //行时序右边框
          H_FRONT   =   10'd8   ,   //行时序前沿
          H_TOTAL   =   10'd800 ;   //行扫描周期
parameter V_SYNC    =   10'd2   ,   //场同步
          V_BACK    =   10'd25  ,   //场时序后沿
          V_TOP     =   10'd8   ,   //场时序上边框
          V_VALID   =   10'd480 ,   //场有效数据
          V_BOTTOM  =   10'd8   ,   //场时序下边框
          V_FRONT   =   10'd2   ,   //场时序前沿
          V_TOTAL   =   10'd525 ;   //场扫描周期

//wire  define
wire            pixdata_req    ;   //像素点色彩信息请求信号

//reg   define
reg     [11:0]  cnt_h           ;   //行同步信号计数器
reg     [11:0]  cnt_v           ;   //场同步信号计数器

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//cnt_h:行同步信号计数器
always@(posedge vga_clk or negedge rstn)
    if(rstn == 1'b0)
        cnt_h   <=  12'd0   ;
    else    if(cnt_h == H_TOTAL - 1'd1)
        cnt_h   <=  12'd0   ;
    else
        cnt_h   <=  cnt_h + 1'd1   ;

//hsync:行同步信号
assign  hsync = (cnt_h  <=  H_SYNC - 1'd1) ? 1'b1 : 1'b0  ;

//cnt_v:场同步信号计数器
always@(posedge vga_clk or negedge rstn)
    if(rstn == 1'b0)
        cnt_v   <=  12'd0 ;
    else    if((cnt_v == V_TOTAL - 1'd1) &&  (cnt_h == H_TOTAL-1'd1))
        cnt_v   <=  12'd0 ;
    else    if(cnt_h == H_TOTAL - 1'd1)
        cnt_v   <=  cnt_v + 1'd1 ;
    else
        cnt_v   <=  cnt_v ;

//vsync:场同步信号
assign  vsync = (cnt_v  <=  V_SYNC - 1'd1) ? 1'b1 : 1'b0  ;

//rgb_valid:VGA有效显示区域
wire rgb_valid;
assign  rgb_valid = (((cnt_h >= H_SYNC + H_BACK + H_LEFT)
                    && (cnt_h < H_SYNC + H_BACK + H_LEFT + H_VALID))
                    &&((cnt_v >= V_SYNC + V_BACK + V_TOP)
                    && (cnt_v < V_SYNC + V_BACK + V_TOP + V_VALID)))
                    ? 1'b1 : 1'b0;

//pixdata_req:像素点色彩信息请求信号,超前rgb_valid信号一个时钟周期
assign  pixdata_req = (((cnt_h >= H_SYNC + H_BACK + H_LEFT - 1'b1)
                    && (cnt_h < H_SYNC + H_BACK + H_LEFT + H_VALID - 1'b1))
                    &&((cnt_v >= V_SYNC + V_BACK + V_TOP)
                    && (cnt_v < V_SYNC + V_BACK + V_TOP + V_VALID)))
                    ? 1'b1 : 1'b0;

// pix_x,pix_y:VGA有效显示区域像素点坐标
assign  pix_x = (pixdata_req == 1'b1)
                ? (cnt_h - (H_SYNC + H_BACK + H_LEFT - 1'b1)) : 12'hfff;
assign  pix_y = (pixdata_req == 1'b1)
                ? (cnt_v - (V_SYNC + V_BACK + V_TOP)) : 12'hfff;

// always@(posedge vga_clk)begin
//     if(~rstn)begin
//         pix_x<=12'hfff;
//         pix_y<=12'hfff;
//     end
//     else if(pixdata_req==1'b1)begin
//         pix_x<=(cnt_h - (H_SYNC + H_BACK + H_LEFT - 1'b1));
//         pix_y<=(cnt_v - (V_SYNC + V_BACK + V_TOP));
//     end
//     else begin
//         pix_x<=12'hfff;
//         pix_y<=12'hfff;
//     end
// end

//rgb:输出像素点色彩信息
assign  rgb = (rgb_valid == 1'b1) ? (IsGameWindow ==1'b1 ? pixdata:12'h220) : 12'h0 ;


endmodule
