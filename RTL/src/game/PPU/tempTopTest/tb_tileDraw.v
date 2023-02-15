`timescale 1ns/1ps

`include "C:/Users/hp/Desktop/my1942Game/RTL/src/game/PPU/define.v"
module tb_tileDraw();

    reg             clk     ;//100MHz//用于计算的时钟必须大于VGA的扫描时钟，这样计算过程可以多个时钟周期
    reg             vga_clk ;//25MHz
    reg             rstn    ;//系统复位

    //from VGA_driver
    wire [`VGA_POSXY_BIT-1:0] vgaPosX;
    wire [`VGA_POSXY_BIT-1:0] vgaPosY;

    wire [`BYTE-1:0] tileIndex;

    //from spriteTileRom.v 由tileIndex索引得到
    wire  [`SPRITE_TILEDATA_BIT-1:0]  tileDataI;
    
    //to VGA_driver.v
    wire [`RGB_BIT-1:0] vgaRgbOut;

    wire            hsync       ;   //输出行同步信号
    wire            vsync       ;   //输出场同步信号
    wire    [11:0]  rgb         ;   //输出像素点色彩信息

    initial begin
        clk=0;
        vga_clk=0;
        rstn=0;
        #1001
        rstn=1;
    end
    always #1 clk=~clk;
    always #4 vga_clk=~vga_clk;

tileDraw u_tileDraw(
    .clk            (clk          ),//用于计算的时钟必须大于VGA的扫描时钟，这样计算过程可以多个时钟周期
    .rstn           (rstn         ),
    .vgaPosX        (vgaPosX      ),
    .vgaPosY        (vgaPosY      ),
    .spriteTileDataO(32'h0A0A0280),
    // .posX           (10           ),
    // .posY           (5            ),
    .tileIndex      (tileIndex    ),
    // .hFilp          (0            ),
    // .vFilp          (0            ),
    // .PaletteChoice  (0            ),
    .tileDataI      (tileDataI    ),
    .vgaRgbOut      (vgaRgbOut    )
);

spriteTileRom u_spriteTileRom(
    .tileIndex(tileIndex),   //tile的索引值
    .tileDataO(tileDataI)
);

vga_driver  u_vga_driver
(
    .vga_clk    (vga_clk) ,   //输入工作时钟,频率25MHz
    .sys_rstn   (rstn),   //输入复位信号,低电平有效
    .pixdata(vgaRgbOut)    ,   //输入像素点色彩信息
    .pix_x(vgaPosX) ,   //输出VGA有效显示区域像素点X轴坐标
    .pix_y(vgaPosY) ,   //输出VGA有效显示区域像素点Y轴坐标
    .hsync(hsync)       ,   //输出行同步信号
    .vsync(vsync)       ,   //输出场同步信号
    .rgb  (rgb  )           //输出像素点色彩信息
);

endmodule