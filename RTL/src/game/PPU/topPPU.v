
`include "C:/Users/hp/Desktop/my1942Game/RTL/src/game/PPU/define.v"
module topPPU#(
    parameter ADDR_WIDTH = 6 //精灵数量只有64个
)(
    input   wire            clk_50MHz   ,
    input   wire            rstn        ,

    input   wire            clk_125MHz  ,
    input   wire            clk_100MHz  ,
    input   wire            clk_25p2MHz ,
    
    //CPU AHB interface 对spriteRam进行写操作
    input  wire             SPRITE_HCLK         ,
    input  wire             SPRITE_HRESETn      ,
    input  wire             SPRITE_HSEL         ,
    input  wire   [31:0]    SPRITE_HADDR        ,
    input  wire   [01:0]    SPRITE_HTRANS       ,
    input  wire   [02:0]    SPRITE_HSIZE        ,
    input  wire   [03:0]    SPRITE_HPROT        ,
    input  wire             SPRITE_HWRITE       ,
    input  wire   [31:0]    SPRITE_HWDATA       ,
    input  wire             SPRITE_HREADY       ,
    output wire             SPRITE_HREADYOUT    ,
    output wire   [31:0]    SPRITE_HRDATA       ,
    output wire   [01:0]    SPRITE_HRESP        ,
    //CPU AHB interface 对nameTable进行写操作
    input  wire             NAMETABLE_HCLK      ,
    input  wire             NAMETABLE_HRESETn   ,
    input  wire             NAMETABLE_HSEL      ,
    input  wire   [31:0]    NAMETABLE_HADDR     ,
    input  wire   [1:0]     NAMETABLE_HTRANS    ,
    input  wire   [2:0]     NAMETABLE_HSIZE     ,
    input  wire   [3:0]     NAMETABLE_HPROT     ,
    input  wire             NAMETABLE_HWRITE    ,
    input  wire   [31:0]    NAMETABLE_HWDATA    ,
    input  wire             NAMETABLE_HREADY    ,
    output wire             NAMETABLE_HREADYOUT ,
    output wire   [31:0]    NAMETABLE_HRDATA    ,
    output wire   [1:0]     NAMETABLE_HRESP     ,

    //to cpu IRQ
    output  wire            createPlaneIntr     ,//50MHz能够捕捉的信号
    
    //to SPI_FLASH
    output  wire            scrollEn        ,// 用于软件还是硬件控制SPI_FLASH
    output  wire            SPI_CLK         ,
    output  wire            SPI_CS          ,
    output  wire            SPI_MOSI        ,
    input   wire            SPI_MISO        ,
    //中断VGA
    output wire             VGA_Intr            ,

    // //VGA PIN
    // output  wire            hsync       ,//输出行同步信号
    // output  wire            vsync       ,//输出场同步信号
    // output  wire    [11:0]  rgb          //输出像素点色彩信息

    //HDMI OUT PIN
    output wire            tmds_clk_p   ,// TMDS 时钟通道
    output wire            tmds_clk_n   ,
    output wire    [2:0]   tmds_data_p  ,// TMDS 数据通道
    output wire    [2:0]   tmds_data_n  
);

    wire    vga_clk = clk_25p2MHz;

    wire [`VGA_POSXY_BIT-1:0] pix_x;
    wire [`VGA_POSXY_BIT-1:0] pix_y;
    wire [`VGA_POSXY_BIT-1:0] vgaPosX;
    wire [`VGA_POSXY_BIT-1:0] vgaPosY;
    `ifdef SET_GAME_CANVAS_BIG
        assign vgaPosX=pix_x>>1;
        assign vgaPosY=pix_y>>1;
    `else
        assign vgaPosX=pix_x;
        assign vgaPosY=pix_y;
    `endif

    wire IsGameWindow = (vgaPosX>=`GAME_START_POSX && vgaPosX<`GAME_START_POSX+`GAME_WINDOW_WIDTH ) &&
                        (vgaPosY>=`GAME_START_POSY && vgaPosY<`GAME_START_POSY+`GAME_WINDOW_HEIGHT);

    wire    [`RGB_BIT-1:0]  vgaRgbOut           ;

    //精灵颜色与背景颜色的选择
    reg     [`RGB_BIT-1:0]  vgaRgbSel           ;
    wire    [`RGB_BIT-1:0]  spriteVgaRgbOut     ;
    wire    [`RGB_BIT-1:0]  backGroundVgaRgbOut ;
    always@(*)begin
        if(spriteVgaRgbOut==12'h209||spriteVgaRgbOut==12'h000)
            vgaRgbSel=backGroundVgaRgbOut;
        else
            vgaRgbSel=spriteVgaRgbOut;
    end
    assign vgaRgbOut = vgaRgbSel;

    topSpriteDraw u_topSpriteDraw(
        .clk_50MHz          (clk_50MHz          ),
        .clk_100MHz         (clk_100MHz         ),
        .clk_25p2MHz        (clk_25p2MHz        ),
        .rstn               (rstn               ),
        //CPU AHB interface 对spriteRam进行写操作
        .SPRITE_HCLK        (SPRITE_HCLK        ),    //50MHz
        .SPRITE_HRESETn     (SPRITE_HRESETn     ), 
        .SPRITE_HSEL        (SPRITE_HSEL        ),    
        .SPRITE_HADDR       (SPRITE_HADDR       ),   
        .SPRITE_HTRANS      (SPRITE_HTRANS      ),  
        .SPRITE_HSIZE       (SPRITE_HSIZE       ),   
        .SPRITE_HPROT       (SPRITE_HPROT       ),   
        .SPRITE_HWRITE      (SPRITE_HWRITE      ),  
        .SPRITE_HWDATA      (SPRITE_HWDATA      ),   
        .SPRITE_HREADY      (SPRITE_HREADY      ), 
        .SPRITE_HREADYOUT   (SPRITE_HREADYOUT   ), 
        .SPRITE_HRDATA      (SPRITE_HRDATA      ),  
        .SPRITE_HRESP       (SPRITE_HRESP       ),

        .IsGameWindow       (IsGameWindow       ),
        .vgaPosX            (vgaPosX            ),
        .vgaPosY            (vgaPosY            ),
        // .backGroundVgaRgbOut(backGroundVgaRgbOut),
        .spriteVgaRgbOut    (spriteVgaRgbOut    )
);

    topBackGroundDraw u_topBackGroundDraw(
        .clk_50MHz          (clk_50MHz          ),
        .clk_100MHz         (clk_100MHz         ),
        .clk_25p2MHz        (clk_25p2MHz        ),
        .rstn               (rstn               ),
        //cpu ahb-lite bus
        .NAMETABLE_HCLK     (NAMETABLE_HCLK     ),
        .NAMETABLE_HRESETn  (NAMETABLE_HRESETn  ),
        .NAMETABLE_HSEL     (NAMETABLE_HSEL     ),
        .NAMETABLE_HADDR    (NAMETABLE_HADDR    ),
        .NAMETABLE_HTRANS   (NAMETABLE_HTRANS   ),
        .NAMETABLE_HSIZE    (NAMETABLE_HSIZE    ),
        .NAMETABLE_HPROT    (NAMETABLE_HPROT    ),
        .NAMETABLE_HWRITE   (NAMETABLE_HWRITE   ),
        .NAMETABLE_HWDATA   (NAMETABLE_HWDATA   ),
        .NAMETABLE_HREADY   (NAMETABLE_HREADY   ),
        .NAMETABLE_HREADYOUT(NAMETABLE_HREADYOUT),
        .NAMETABLE_HRDATA   (NAMETABLE_HRDATA   ),
        .NAMETABLE_HRESP    (NAMETABLE_HRESP    ),
        //to cpu IRQ
        .createPlaneIntr    (createPlaneIntr    ),
        //from VGA_driver
        .vgaPosX            (vgaPosX            ),
        .vgaPosY            (vgaPosY            ),
        .backGroundVgaRgbOut(backGroundVgaRgbOut),
        //flash spi
        .scrollEn           (scrollEn),// 用于软件还是硬件控制SPI_FLASH
        .SPI_CLK            (SPI_CLK ),
        .SPI_CS             (SPI_CS  ),
        .SPI_MOSI           (SPI_MOSI),
        .SPI_MISO           (SPI_MISO)
    );

    // vga_driver  u_vga_driver(
    //     .vga_clk            (vga_clk            ),
    //     .rstn               (rstn               ),
    //     .pixdata            (vgaRgbOut          ),
    //     .pix_x              (pix_x              ),
    //     .pix_y              (pix_y              ),
    //     .IsGameWindow       (IsGameWindow       ),
    //     .hsync              (hsync              ),
    //     .vsync              (vsync              ),
    //     .rgb                (rgb                )
    // );

    hdmi_driver u_hdmi_driver(
        .hdmi_clk           (clk_25p2MHz        ),
        .hdmi_clk_5         (clk_125MHz         ),
        .rstn               (rstn               ),
        .pixel_xpos         (pix_x              ),
        .pixel_ypos         (pix_y              ),
        .rd_data            ({1'b0,vgaRgbOut[3:0],1'b0,vgaRgbOut[7:4],2'b00,vgaRgbOut[11:8]}   ),
        .IsGameWindow       (IsGameWindow       ),
        .tmds_clk_p         (tmds_clk_p         ),
        .tmds_clk_n         (tmds_clk_n         ),
        .tmds_data_p        (tmds_data_p        ),
        .tmds_data_n        (tmds_data_n        ) 
    );

    reg VGA_Intr_r0;
    reg VGA_Intr_r1;
    always@(posedge clk_50MHz)begin
        if(~rstn)begin
            VGA_Intr_r0<=0;
            VGA_Intr_r1<=0;
        end
        `ifdef SET_GAME_CANVAS_BIG
            else begin
                VGA_Intr_r0<=(pix_x==`GAME_START_POSX+`GAME_WINDOW_WIDTH_BIG-1'b1) && (pix_y==`GAME_START_POSY+`GAME_WINDOW_HEIGHT_BIG-1'b1);
                VGA_Intr_r1<=VGA_Intr_r0;
            end
        `else
            else begin
                VGA_Intr_r0<=(vgaPosX==`GAME_START_POSX+`GAME_WINDOW_WIDTH-1) && (vgaPosY==`GAME_START_POSY+`GAME_WINDOW_HEIGHT-1);
                VGA_Intr_r1<=VGA_Intr_r0;
            end
        `endif
    end
    assign VGA_Intr = VGA_Intr_r0 & (~VGA_Intr_r1);
    
endmodule