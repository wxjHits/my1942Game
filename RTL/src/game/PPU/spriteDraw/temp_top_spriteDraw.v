`include "C:/Users/hp/Desktop/my1942Game/RTL/src/game/PPU/define.v"
module temp_top_spriteDraw(
        input wire clk,
        input wire rstn,

        output  wire            hsync       ,   //输出行同步信号
        output  wire            vsync       ,   //输出场同步信号
        output  wire    [11:0]  rgb             //输出像素点色彩信息
    );

    // wire clk_50MHz=clk;
    // wire clk_100MHz;
    // wire clk_25p2MHz;
    // wire    vga_clk = clk_25p2MHz;

    // clk_wiz_0 instance_name(
    //               .clk_100MHz(clk_100MHz),
    //               .clk_25p2MHz(clk_25p2MHz),
    //               .clk_in1(clk_50MHz)
    //           );

    // //from VGA_driver
    // wire [`VGA_POSXY_BIT-1:0] vgaPosX;
    // wire [`VGA_POSXY_BIT-1:0] vgaPosY;

    // wire IsGameWindow = (vgaPosX>=`GAME_START_POSX && vgaPosX<`GAME_START_POSX+`GAME_WINDOW_WIDTH) &&
    //      (vgaPosY>=`GAME_START_POSY && vgaPosY<`GAME_START_POSY+`GAME_WINDOW_HEIGHT);

    // wire [`RGB_BIT-1:0] spriteVgaRgbOut;
    // topSpriteDraw u_topSpriteDraw(
    //                       .clk_50MHz   (clk_50MHz   ),
    //                       .clk_100MHz  (clk_100MHz  ),
    //                       .clk_25p2MHz (clk_25p2MHz ),
    //                       .rstn        (rstn        ),

    //                       //from VGA_driver
    //                       .vgaPosX    (vgaPosX        ),
    //                       .vgaPosY    (vgaPosY        ),

    //                       .IsGameWindow(IsGameWindow),

    //                       .spriteVgaRgbOut(spriteVgaRgbOut)
    //                   );


    // vga_driver  u_vga_driver
    //             (
    //                 .vga_clk    (vga_clk) ,   //输入工作时钟,频率25MHz
    //                 .rstn   (rstn),   //输入复位信号,低电平有效
    //                 .pixdata(spriteVgaRgbOut)    ,   //输入像素点色彩信息
    //                 .pix_x(vgaPosX) ,   //输出VGA有效显示区域像素点X轴坐标
    //                 .pix_y(vgaPosY) ,   //输出VGA有效显示区域像素点Y轴坐标
    //                 .IsGameWindow(IsGameWindow),
    //                 .hsync(hsync)       ,   //输出行同步信号
    //                 .vsync(vsync)       ,   //输出场同步信号
    //                 .rgb  (rgb  )           //输出像素点色彩信息
    //             );

    wire clk_50MHz=clk;
    wire clk_100MHz;
    wire clk_25p2MHz;
    wire    vga_clk = clk_25p2MHz;

    clk_wiz_0 instance_name(
                  .clk_100MHz(clk_100MHz),
                  .clk_25p2MHz(clk_25p2MHz),
                  .clk_in1(clk_50MHz)
              );

    //from VGA_driver
    wire [`VGA_POSXY_BIT-1:0] pos_x;
    wire [`VGA_POSXY_BIT-1:0] pos_y;
    wire [`VGA_POSXY_BIT-1:0] vgaPosX=pos_x>>1;
    wire [`VGA_POSXY_BIT-1:0] vgaPosY=pos_y>>1;

    wire IsGameWindow = (vgaPosX>=`GAME_START_POSX && vgaPosX<`GAME_START_POSX+`GAME_WINDOW_WIDTH) &&
         (vgaPosY>=`GAME_START_POSY && vgaPosY<`GAME_START_POSY+`GAME_WINDOW_HEIGHT);

    wire [`RGB_BIT-1:0] spriteVgaRgbOut;
    topSpriteDraw u_topSpriteDraw(
                          .clk_50MHz   (clk_50MHz   ),
                          .clk_100MHz  (clk_100MHz  ),
                          .clk_25p2MHz (clk_25p2MHz ),
                          .rstn        (rstn        ),

                          //from VGA_driver
                          .vgaPosX    (vgaPosX        ),
                          .vgaPosY    (vgaPosY        ),

                          .IsGameWindow(IsGameWindow),

                          .spriteVgaRgbOut(spriteVgaRgbOut)
                      );


    vga_driver  u_vga_driver
                (
                    .vga_clk    (vga_clk) ,   //输入工作时钟,频率25MHz
                    .rstn   (rstn),   //输入复位信号,低电平有效
                    .pixdata(spriteVgaRgbOut)    ,   //输入像素点色彩信息
                    .pix_x(pos_x) ,   //输出VGA有效显示区域像素点X轴坐标
                    .pix_y(pos_y) ,   //输出VGA有效显示区域像素点Y轴坐标
                    .IsGameWindow(IsGameWindow),
                    .hsync(hsync)       ,   //输出行同步信号
                    .vsync(vsync)       ,   //输出场同步信号
                    .rgb  (rgb  )           //输出像素点色彩信息
                );

endmodule
