
`include "C:/Users/hp/Desktop/my_1942/define.v"
module topPPU#(
    parameter ADDR_WIDTH = 6 //精灵数量只有64个
)(
    input   wire            clk_50MHz   ,
    input   wire            clk_100MHz  ,
    input   wire            clk_25p2MHz ,
    input   wire            rstn        ,
    
    //CPU AHB interface 对spriteRam进行写操作
    input  wire             HCLK        ,    //50MHz
    input  wire             HRESETn     , 
    input  wire             HSEL        ,    
    input  wire   [31:0]    HADDR       ,   
    input  wire   [01:0]    HTRANS      ,  
    input  wire   [02:0]    HSIZE       ,   
    input  wire   [03:0]    HPROT       ,   
    input  wire             HWRITE      ,  
    input  wire   [31:0]    HWDATA      ,   
    input  wire             HREADY      , 
    output wire             HREADYOUT   , 
    output wire   [31:0]    HRDATA      ,  
    output wire   [01:0]    HRESP       ,

    //VGA PIN
    output  wire            hsync       ,//输出行同步信号
    output  wire            vsync       ,//输出场同步信号
    output  wire    [11:0]  rgb          //输出像素点色彩信息

);

    wire    [ADDR_WIDTH-1:0]    BRAM_RDADDR ;
    wire    [ADDR_WIDTH-1:0]    BRAM_WRADDR ;
    wire    [31:0]              BRAM_RDATA  ;
    wire    [31:0]              BRAM_WDATA  ;
    wire    [3:0]               BRAM_WRITE  ;

    //hitCheck.v
    wire    hitCheckStart;
    wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   hitCheck_spriteViewRamIndex;
    wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO_hitCheck;
    wire    [`SPRITE_NUM_MAX-1:0]           allSpriteHit;
    wire                                    hitCheckBusy;
    
    wire    vga_clk = clk_25p2MHz;
        //from VGA_driver
    wire [`VGA_POSXY_BIT-1:0] vgaPosX;
    wire [`VGA_POSXY_BIT-1:0] vgaPosY;

    wire    [$clog2(`SPRITE_NUM_MAX)-1:0]  spriteViewRamIndex00;   //tile的索引值
    wire    [$clog2(`SPRITE_NUM_MAX)-1:0]  spriteViewRamIndex01;
    wire    [$clog2(`SPRITE_NUM_MAX)-1:0]  spriteViewRamIndex02;
    wire    [$clog2(`SPRITE_NUM_MAX)-1:0]  spriteViewRamIndex03;
    wire    [$clog2(`SPRITE_NUM_MAX)-1:0]  spriteViewRamIndex04;
    wire    [$clog2(`SPRITE_NUM_MAX)-1:0]  spriteViewRamIndex05;
    wire    [4*(`BYTE)-1:0]     spriteViewRamDataO00;
    wire    [4*(`BYTE)-1:0]     spriteViewRamDataO01;
    wire    [4*(`BYTE)-1:0]     spriteViewRamDataO02;
    wire    [4*(`BYTE)-1:0]     spriteViewRamDataO03;
    wire    [4*(`BYTE)-1:0]     spriteViewRamDataO04;
    wire    [4*(`BYTE)-1:0]     spriteViewRamDataO05;
    wire    [`SPRITE_TILEROM_ADDRBIT-1:0]  tileIndex00;
    wire    [`SPRITE_TILEROM_ADDRBIT-1:0]  tileIndex01;
    wire    [`SPRITE_TILEROM_ADDRBIT-1:0]  tileIndex02;
    wire    [`SPRITE_TILEROM_ADDRBIT-1:0]  tileIndex03;
    wire    [`SPRITE_TILEROM_ADDRBIT-1:0]  tileIndex04;
    wire    [`SPRITE_TILEROM_ADDRBIT-1:0]  tileIndex05;
    wire  [`SPRITE_TILEDATA_BIT-1:0]  tileDataI00;
    wire  [`SPRITE_TILEDATA_BIT-1:0]  tileDataI01;
    wire  [`SPRITE_TILEDATA_BIT-1:0]  tileDataI02;
    wire  [`SPRITE_TILEDATA_BIT-1:0]  tileDataI03;
    wire  [`SPRITE_TILEDATA_BIT-1:0]  tileDataI04;
    wire  [`SPRITE_TILEDATA_BIT-1:0]  tileDataI05;

    wire  IsScanRange00;
    wire  IsScanRange01;
    wire  IsScanRange02;
    wire  IsScanRange03;
    wire  IsScanRange04;
    wire  IsScanRange05;
    
    //to VGA_driver.v
    wire [`RGB_BIT-1:0] vgaRgbOut00;
    wire [`RGB_BIT-1:0] vgaRgbOut01;
    wire [`RGB_BIT-1:0] vgaRgbOut02;
    wire [`RGB_BIT-1:0] vgaRgbOut03;
    wire [`RGB_BIT-1:0] vgaRgbOut04;
    wire [`RGB_BIT-1:0] vgaRgbOut05;

    //颜色的选择，如果重叠
    wire [`RGB_BIT-1:0] vgaRgbOut = IsScanRange00 ? vgaRgbOut00 : (
                                    IsScanRange01 ? vgaRgbOut01 : (
                                    IsScanRange02 ? vgaRgbOut02 : (
                                    IsScanRange03 ? vgaRgbOut03 : (
                                    IsScanRange04 ? vgaRgbOut04 : (
                                    IsScanRange05 ? vgaRgbOut05 : 12'h0)))));

    ahb_spriteRam_interface ahb_spriteRam_interface_inst(
        .HCLK       (HCLK       ),
        .HRESETn    (HRESETn    ),
        .HSEL       (HSEL       ),
        .HADDR      (HADDR      ),
        .HTRANS     (HTRANS     ),
        .HSIZE      (HSIZE      ),
        .HPROT      (HPROT      ),
        .HWRITE     (HWRITE     ),
        .HWDATA     (HWDATA     ),
        .HREADY     (HREADY     ),
        .HREADYOUT  (HREADYOUT  ),
        .HRDATA     (HRDATA     ),
        .HRESP      (HRESP      ),
        .BRAM_RDADDR(BRAM_RDADDR),
        .BRAM_WRADDR(BRAM_WRADDR),
        .BRAM_RDATA (BRAM_RDATA ),
        .BRAM_WDATA (BRAM_WDATA ),
        .BRAM_WRITE (BRAM_WRITE ) 
    );


    spriteRam spriteRam_inst(
        .clk    (clk_50MHz),
        .addra  (BRAM_WRADDR),
        .addrb  (BRAM_RDADDR),
        .dina   (BRAM_WDATA),
        .doutb  (BRAM_RDATA),
        .wea    (BRAM_WRITE),

        //hitCheck.v
        .hitCheck_spriteViewRamIndex(hitCheck_spriteViewRamIndex),
        .spriteViewRamDataO_hitCheck(spriteViewRamDataO_hitCheck),

    //tileDraw
        .spriteViewRamIndex00(spriteViewRamIndex00),   //tile的索引值
        .spriteViewRamIndex01(spriteViewRamIndex01),   //tile的索引值
        .spriteViewRamIndex02(spriteViewRamIndex02),   //tile的索引值
        .spriteViewRamIndex03(spriteViewRamIndex03),   //tile的索引值
        .spriteViewRamIndex04(spriteViewRamIndex04),   //tile的索引值
        .spriteViewRamIndex05(spriteViewRamIndex05),   //tile的索引值
        .spriteViewRamDataO00(spriteViewRamDataO00),
        .spriteViewRamDataO01(spriteViewRamDataO01),
        .spriteViewRamDataO02(spriteViewRamDataO02),
        .spriteViewRamDataO03(spriteViewRamDataO03),
        .spriteViewRamDataO04(spriteViewRamDataO04),
        .spriteViewRamDataO05(spriteViewRamDataO05)
);

wire IsGameWindow = (vgaPosX>=`GAME_START_POSX && vgaPosX<`GAME_START_POSX+`GAME_WINDOW_WIDTH) &&
                    (vgaPosY>=`GAME_START_POSY && vgaPosY<`GAME_START_POSY+`GAME_WINDOW_HEIGHT);
wire   gameWindowDone = (vgaPosX==`GAME_START_POSX+`GAME_WINDOW_WIDTH-1) &&
                        (vgaPosY==`GAME_START_POSY+`GAME_WINDOW_HEIGHT-1);

reg gameWindowDoneDelay0;
reg gameWindowDoneDelay1;
reg gameWindowDoneDelay2;
reg gameWindowRaiseEdge ;
always@(posedge clk_100MHz)begin
    if(~rstn)begin
        gameWindowDoneDelay0<=0;
        gameWindowDoneDelay1<=0;
        gameWindowDoneDelay2<=0;
        gameWindowRaiseEdge <=0;
    end
    else begin
        gameWindowDoneDelay0<=gameWindowDone;
        gameWindowDoneDelay1<=gameWindowDoneDelay0;
        gameWindowDoneDelay2<=gameWindowDoneDelay1;
        gameWindowRaiseEdge <=gameWindowDoneDelay1 & (~gameWindowDoneDelay2);
    end
end
assign hitCheckStart = gameWindowRaiseEdge;
hitCheck hitCheck_inst(
    .clk (clk_100MHz),
    .rstn(rstn),
    .hitCheckStart(hitCheckStart),
    .hitCheck_spriteViewRamIndex(hitCheck_spriteViewRamIndex),
    .spriteViewRamDataO_hitCheck(spriteViewRamDataO_hitCheck),
    .allSpriteHit(allSpriteHit),
    .hitCheckBusy(hitCheckBusy)
);

tileDraw u_tileDraw00(
    .clk            (clk_100MHz   ),//用于计算的时钟必须大于VGA的扫描时钟，这样计算过程可以多个时钟周期
    .rstn           (rstn         ),
    .vgaPosX        (vgaPosX      ),
    .vgaPosY        (vgaPosY      ),
    .inSpriteViewRamIndex(0),
    .spriteViewRamIndex(spriteViewRamIndex00),
    .spriteViewRamDataO(spriteViewRamDataO00),
    .tileIndex      (tileIndex00    ),
    .tileDataI      (tileDataI00    ),
    .IsScanRange    (IsScanRange00    ),
    .vgaRgbOut      (vgaRgbOut00    )
);

tileDraw u_tileDraw01(
    .clk            (clk_100MHz   ),//用于计算的时钟必须大于VGA的扫描时钟，这样计算过程可以多个时钟周期
    .rstn           (rstn         ),
    .vgaPosX        (vgaPosX      ),
    .vgaPosY        (vgaPosY      ),

    .inSpriteViewRamIndex(1),
    .spriteViewRamIndex(spriteViewRamIndex01),
    .spriteViewRamDataO(spriteViewRamDataO01),
    .tileIndex      (tileIndex01    ),

    .tileDataI      (tileDataI01    ),

    .IsScanRange    (IsScanRange01    ),

    .vgaRgbOut      (vgaRgbOut01    )
);

tileDraw u_tileDraw02(
    .clk            (clk_100MHz   ),//用于计算的时钟必须大于VGA的扫描时钟，这样计算过程可以多个时钟周期
    .rstn           (rstn         ),
    .vgaPosX        (vgaPosX      ),
    .vgaPosY        (vgaPosY      ),

    .inSpriteViewRamIndex(2),
    .spriteViewRamIndex(spriteViewRamIndex02),
    .spriteViewRamDataO(spriteViewRamDataO02),
    .tileIndex      (tileIndex02    ),

    .tileDataI      (tileDataI02    ),

    .IsScanRange    (IsScanRange02    ),

    .vgaRgbOut      (vgaRgbOut02    )
);

tileDraw u_tileDraw03(
    .clk            (clk_100MHz   ),//用于计算的时钟必须大于VGA的扫描时钟，这样计算过程可以多个时钟周期
    .rstn           (rstn         ),
    .vgaPosX        (vgaPosX      ),
    .vgaPosY        (vgaPosY      ),
    .inSpriteViewRamIndex(3),
    .spriteViewRamIndex(spriteViewRamIndex03),
    .spriteViewRamDataO(spriteViewRamDataO03),
    .tileIndex      (tileIndex03    ),
    .tileDataI      (tileDataI03    ),
    .IsScanRange    (IsScanRange03    ),
    .vgaRgbOut      (vgaRgbOut03    )
);
tileDraw u_tileDraw04(
    .clk            (clk_100MHz   ),//用于计算的时钟必须大于VGA的扫描时钟，这样计算过程可以多个时钟周期
    .rstn           (rstn         ),
    .vgaPosX        (vgaPosX      ),
    .vgaPosY        (vgaPosY      ),
    .inSpriteViewRamIndex(4),
    .spriteViewRamIndex(spriteViewRamIndex04),
    .spriteViewRamDataO(spriteViewRamDataO04),
    .tileIndex      (tileIndex04    ),
    .tileDataI      (tileDataI04    ),
    .IsScanRange    (IsScanRange04    ),
    .vgaRgbOut      (vgaRgbOut04    )
);
tileDraw u_tileDraw05(
    .clk            (clk_100MHz   ),//用于计算的时钟必须大于VGA的扫描时钟，这样计算过程可以多个时钟周期
    .rstn           (rstn         ),
    .vgaPosX        (vgaPosX      ),
    .vgaPosY        (vgaPosY      ),
    .inSpriteViewRamIndex(5),
    .spriteViewRamIndex(spriteViewRamIndex05),
    .spriteViewRamDataO(spriteViewRamDataO05),
    .tileIndex      (tileIndex05    ),
    .tileDataI      (tileDataI05    ),
    .IsScanRange    (IsScanRange05    ),
    .vgaRgbOut      (vgaRgbOut05    )
);

spriteTileRom u_spriteTileRom(
    // .tileIndex(tileIndex00),   //tile的索引值
    // .tileDataO(tileDataI00)
    .tileIndex00(tileIndex00),
    .tileIndex01(tileIndex01),
    .tileIndex02(tileIndex02),
    .tileIndex03(tileIndex03),
    .tileIndex04(tileIndex04),
    .tileIndex05(tileIndex05),
    .tileDataO00(tileDataI00),
    .tileDataO01(tileDataI01),
    .tileDataO02(tileDataI02),
    .tileDataO03(tileDataI03),
    .tileDataO04(tileDataI04),
    .tileDataO05(tileDataI05)
);

vga_driver  u_vga_driver
(
    .vga_clk    (vga_clk) ,   //输入工作时钟,频率25MHz
    .rstn   (rstn),   //输入复位信号,低电平有效
    .pixdata(vgaRgbOut)    ,   //输入像素点色彩信息
    .pix_x(vgaPosX) ,   //输出VGA有效显示区域像素点X轴坐标
    .pix_y(vgaPosY) ,   //输出VGA有效显示区域像素点Y轴坐标
    .IsGameWindow(IsGameWindow),
    .hsync(hsync)       ,   //输出行同步信号
    .vsync(vsync)       ,   //输出场同步信号
    .rgb  (rgb  )           //输出像素点色彩信息
);

endmodule