
`include "define.v"
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

    wire [$clog2(`SPRITE_NUM_MAX)-1:0] addrReadEightRam;
    wire [31:0] dataToEightRam;
    //from VGA_driver
    wire [`VGA_POSXY_BIT-1:0] vgaPosX;
    wire [`VGA_POSXY_BIT-1:0] vgaPosY;

    wire IsGameWindow = (vgaPosX>=`GAME_START_POSX && vgaPosX<`GAME_START_POSX+`GAME_WINDOW_WIDTH) &&
                        (vgaPosY>=`GAME_START_POSY && vgaPosY<`GAME_START_POSY+`GAME_WINDOW_HEIGHT);

    wire    [4*(`BYTE)-1:0]                 dataToTileDraw      [0:8-1];
    wire    [`SPRITE_TILEROM_ADDRBIT-1:0]   tileIndex           [0:8-1];
    wire    [`SPRITE_TILEDATA_BIT-1:0]      tileDataI           [0:8-1];
    wire    [8-1:0]           IsScanRange                              ;
    wire    [`RGB_BIT-1:0]                  vgaRgbOut           [0:8-1];

    wire    [`RGB_BIT-1:0]      vgaRgbOutSel =  IsScanRange[0] ? vgaRgbOut[0]:(
                                                IsScanRange[1] ? vgaRgbOut[1]:(
                                                IsScanRange[2] ? vgaRgbOut[2]:(
                                                IsScanRange[3] ? vgaRgbOut[3]:(
                                                IsScanRange[4] ? vgaRgbOut[4]:(
                                                IsScanRange[5] ? vgaRgbOut[5]:(
                                                IsScanRange[6] ? vgaRgbOut[6]:(
                                                IsScanRange[7] ? vgaRgbOut[7]:12'h0)))))));

    genvar  i;
    generate
        for(i=0;i<8;i=i+1)begin:tiltDraw_inst
            tileDraw u_tileDraw(
                .clk                    (clk_100MHz             ),//用于计算的时钟必须大于VGA的扫描时钟，这样计算过程可以多个时钟周期
                .rstn                   (rstn                  ),
                .vgaPosX                (vgaPosX                ),
                .vgaPosY                (vgaPosY                ),
                .spriteViewRamDataO     (dataToTileDraw[i]      ),
                .tileIndex              (tileIndex[i]           ),
                .tileDataI              (tileDataI[i]           ),
                .IsScanRange            (IsScanRange[i]         ),
                .vgaRgbOut              (vgaRgbOut[i]           )
            );
        end
    endgenerate



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
    //eightRam
    .clkEightRam(clk_100MHz),
    .addrReadEightRam(addrReadEightRam),
    .dataToEightRam(dataToEightRam)
);

eightRam eightRam_inst(
    .clkEightRam(clk_100MHz),
    .rstn(rstn),

    .vgaPosY(vgaPosY),//当前行
    //spriteRam
    .addrReadEightRam(addrReadEightRam),
    .dataToEightRam(dataToEightRam),

    //8个tiledraw模块
    .dataToTileDraw00(dataToTileDraw[00]),
    .dataToTileDraw01(dataToTileDraw[01]),
    .dataToTileDraw02(dataToTileDraw[02]),
    .dataToTileDraw03(dataToTileDraw[03]),
    .dataToTileDraw04(dataToTileDraw[04]),
    .dataToTileDraw05(dataToTileDraw[05]),
    .dataToTileDraw06(dataToTileDraw[06]),
    .dataToTileDraw07(dataToTileDraw[07]),

    .IsGameWindow(IsGameWindow) //当前vga的posX posY是否处于游戏界面
);

spriteTileRom spriteTileRom_inst(
    //from tiltDraw.v
    .tileIndex00(tileIndex[00]), //tileçç´˘ĺźĺ??
    .tileIndex01(tileIndex[01]),
    .tileIndex02(tileIndex[02]),
    .tileIndex03(tileIndex[03]),
    .tileIndex04(tileIndex[04]),
    .tileIndex05(tileIndex[05]),
    .tileIndex06(tileIndex[06]),
    .tileIndex07(tileIndex[07]),

    .tileDataO00(tileDataI[00]),
    .tileDataO01(tileDataI[01]),
    .tileDataO02(tileDataI[02]),
    .tileDataO03(tileDataI[03]),
    .tileDataO04(tileDataI[04]),
    .tileDataO05(tileDataI[05]),
    .tileDataO06(tileDataI[06]),
    .tileDataO07(tileDataI[07])
);

vga_driver  u_vga_driver
(
    .vga_clk    (vga_clk) ,   //输入工作时钟,频率25MHz
    .rstn   (rstn),   //输入复位信号,低电平有效
    .pixdata(vgaRgbOutSel)    ,   //输入像素点色彩信息
    .pix_x(vgaPosX) ,   //输出VGA有效显示区域像素点X轴坐标
    .pix_y(vgaPosY) ,   //输出VGA有效显示区域像素点Y轴坐标
    .IsGameWindow(IsGameWindow),
    .hsync(hsync)       ,   //输出行同步信号
    .vsync(vsync)       ,   //输出场同步信号
    .rgb  (rgb  )           //输出像素点色彩信息
);

// wire   gameWindowDone = (vgaPosX==`GAME_START_POSX+`GAME_WINDOW_WIDTH-1) &&
//                         (vgaPosY==`GAME_START_POSY+`GAME_WINDOW_HEIGHT-1);

// reg gameWindowDoneDelay0;
// reg gameWindowDoneDelay1;
// reg gameWindowDoneDelay2;
// reg gameWindowRaiseEdge ;
// always@(posedge clk_100MHz)begin
//     if(~rstn)begin
//         gameWindowDoneDelay0<=0;
//         gameWindowDoneDelay1<=0;
//         gameWindowDoneDelay2<=0;
//         gameWindowRaiseEdge <=0;
//     end
//     else begin
//         gameWindowDoneDelay0<=gameWindowDone;
//         gameWindowDoneDelay1<=gameWindowDoneDelay0;
//         gameWindowDoneDelay2<=gameWindowDoneDelay1;
//         gameWindowRaiseEdge <=gameWindowDoneDelay1 & (~gameWindowDoneDelay2);
//     end
// end
// assign hitCheckStart = gameWindowRaiseEdge;

// hitCheck hitCheck_inst(
//     .clk (clk_100MHz),
//     .rstn(rstn),
//     .hitCheckStart(hitCheckStart),
//     .hitCheck_spriteViewRamIndex(hitCheck_spriteViewRamIndex),
//     .spriteViewRamDataO_hitCheck(spriteViewRamDataO_hitCheck),
//     .allSpriteHit(allSpriteHit),
//     .hitCheckBusy(hitCheckBusy)
// );

endmodule