
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

     wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex  [0:`SPRITE_NUM_MAX-1];
    wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO  [0:`SPRITE_NUM_MAX-1];
    wire    [`SPRITE_TILEROM_ADDRBIT-1:0]   tileIndex           [0:`SPRITE_NUM_MAX-1];
    wire    [`SPRITE_TILEDATA_BIT-1:0]      tileDataI           [0:`SPRITE_NUM_MAX-1];
    wire    [`SPRITE_NUM_MAX-1:0]           IsScanRange                              ;
    wire    [`RGB_BIT-1:0]                  vgaRgbOut           [0:`SPRITE_NUM_MAX-1];

    genvar  i;
    generate
        for(i=0;i<`SPRITE_NUM_MAX;i=i+1)begin:tiltDraw_inst
            tileDraw u_tileDraw(
                .clk                    (clk_100MHz             ),//用于计算的时钟必须大于VGA的扫描时钟，这样计算过程可以多个时钟周期
                .rstn                   (rstn                  ),
                .vgaPosX                (vgaPosX                ),
                .vgaPosY                (vgaPosY                ),
                // .inSpriteViewRamIndex   (i                      ),
                // .spriteViewRamIndex     (spriteViewRamIndex[i]  ),
                .spriteViewRamDataO     (spriteViewRamDataO[i]  ),
                .tileIndex              (tileIndex[i]           ),
                .tileDataI              (tileDataI[i]           ),
                .IsScanRange            (IsScanRange[i]         ),
                .vgaRgbOut              (vgaRgbOut[i]           )
            );
        end
    endgenerate

    reg [`RGB_BIT-1:0] vgaRgbOutSel;
    integer j;
    always@(*)begin
        for(j=`SPRITE_NUM_MAX-1;j>=0;j=j-1)begin
            if(IsScanRange[j]==1'b1)
                vgaRgbOutSel=vgaRgbOut[j];
            else 
                vgaRgbOutSel=vgaRgbOutSel;
        end
    end

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
    // //tileDraw
    // .spriteViewRamIndex00(spriteViewRamIndex[00]),
    // .spriteViewRamIndex01(spriteViewRamIndex[01]),
    // .spriteViewRamIndex02(spriteViewRamIndex[02]),
    // .spriteViewRamIndex03(spriteViewRamIndex[03]),
    // .spriteViewRamIndex04(spriteViewRamIndex[04]),
    // .spriteViewRamIndex05(spriteViewRamIndex[05]),
    // .spriteViewRamIndex06(spriteViewRamIndex[06]),
    // .spriteViewRamIndex07(spriteViewRamIndex[07]),
    // .spriteViewRamIndex08(spriteViewRamIndex[08]),
    // .spriteViewRamIndex09(spriteViewRamIndex[09]),
    // .spriteViewRamIndex10(spriteViewRamIndex[10]),
    // .spriteViewRamIndex11(spriteViewRamIndex[11]),
    // .spriteViewRamIndex12(spriteViewRamIndex[12]),
    // .spriteViewRamIndex13(spriteViewRamIndex[13]),
    // .spriteViewRamIndex14(spriteViewRamIndex[14]),
    // .spriteViewRamIndex15(spriteViewRamIndex[15]),
    // .spriteViewRamIndex16(spriteViewRamIndex[16]),
    // .spriteViewRamIndex17(spriteViewRamIndex[17]),
    // .spriteViewRamIndex18(spriteViewRamIndex[18]),
    // .spriteViewRamIndex19(spriteViewRamIndex[19]),
    // .spriteViewRamIndex20(spriteViewRamIndex[20]),
    // .spriteViewRamIndex21(spriteViewRamIndex[21]),
    // .spriteViewRamIndex22(spriteViewRamIndex[22]),
    // .spriteViewRamIndex23(spriteViewRamIndex[23]),
    // .spriteViewRamIndex24(spriteViewRamIndex[24]),
    // .spriteViewRamIndex25(spriteViewRamIndex[25]),
    // .spriteViewRamIndex26(spriteViewRamIndex[26]),
    // .spriteViewRamIndex27(spriteViewRamIndex[27]),
    // .spriteViewRamIndex28(spriteViewRamIndex[28]),
    // .spriteViewRamIndex29(spriteViewRamIndex[29]),
    // .spriteViewRamIndex30(spriteViewRamIndex[30]),
    // .spriteViewRamIndex31(spriteViewRamIndex[31]),
    // .spriteViewRamIndex32(spriteViewRamIndex[32]),
    // .spriteViewRamIndex33(spriteViewRamIndex[33]),
    // .spriteViewRamIndex34(spriteViewRamIndex[34]),
    // .spriteViewRamIndex35(spriteViewRamIndex[35]),
    // .spriteViewRamIndex36(spriteViewRamIndex[36]),
    // .spriteViewRamIndex37(spriteViewRamIndex[37]),
    // .spriteViewRamIndex38(spriteViewRamIndex[38]),
    // .spriteViewRamIndex39(spriteViewRamIndex[39]),
    // .spriteViewRamIndex40(spriteViewRamIndex[40]),
    // .spriteViewRamIndex41(spriteViewRamIndex[41]),
    // .spriteViewRamIndex42(spriteViewRamIndex[42]),
    // .spriteViewRamIndex43(spriteViewRamIndex[43]),
    // .spriteViewRamIndex44(spriteViewRamIndex[44]),
    // .spriteViewRamIndex45(spriteViewRamIndex[45]),
    // .spriteViewRamIndex46(spriteViewRamIndex[46]),
    // .spriteViewRamIndex47(spriteViewRamIndex[47]),
    // .spriteViewRamIndex48(spriteViewRamIndex[48]),
    // .spriteViewRamIndex49(spriteViewRamIndex[49]),
    // .spriteViewRamIndex50(spriteViewRamIndex[50]),
    // .spriteViewRamIndex51(spriteViewRamIndex[51]),
    // .spriteViewRamIndex52(spriteViewRamIndex[52]),
    // .spriteViewRamIndex53(spriteViewRamIndex[53]),
    // .spriteViewRamIndex54(spriteViewRamIndex[54]),
    // .spriteViewRamIndex55(spriteViewRamIndex[55]),
    // .spriteViewRamIndex56(spriteViewRamIndex[56]),
    // .spriteViewRamIndex57(spriteViewRamIndex[57]),
    // .spriteViewRamIndex58(spriteViewRamIndex[58]),
    // .spriteViewRamIndex59(spriteViewRamIndex[59]),
    // .spriteViewRamIndex60(spriteViewRamIndex[60]),
    // .spriteViewRamIndex61(spriteViewRamIndex[61]),
    // .spriteViewRamIndex62(spriteViewRamIndex[62]),
    // .spriteViewRamIndex63(spriteViewRamIndex[63]),

    .spriteViewRamDataO00(spriteViewRamDataO[00]),
    .spriteViewRamDataO01(spriteViewRamDataO[01]),
    .spriteViewRamDataO02(spriteViewRamDataO[02]),
    .spriteViewRamDataO03(spriteViewRamDataO[03]),
    .spriteViewRamDataO04(spriteViewRamDataO[04]),
    .spriteViewRamDataO05(spriteViewRamDataO[05]),
    .spriteViewRamDataO06(spriteViewRamDataO[06]),
    .spriteViewRamDataO07(spriteViewRamDataO[07]),
    .spriteViewRamDataO08(spriteViewRamDataO[08]),
    .spriteViewRamDataO09(spriteViewRamDataO[09]),
    .spriteViewRamDataO10(spriteViewRamDataO[10]),
    .spriteViewRamDataO11(spriteViewRamDataO[11]),
    .spriteViewRamDataO12(spriteViewRamDataO[12]),
    .spriteViewRamDataO13(spriteViewRamDataO[13]),
    .spriteViewRamDataO14(spriteViewRamDataO[14]),
    .spriteViewRamDataO15(spriteViewRamDataO[15]),
    .spriteViewRamDataO16(spriteViewRamDataO[16]),
    .spriteViewRamDataO17(spriteViewRamDataO[17]),
    .spriteViewRamDataO18(spriteViewRamDataO[18]),
    .spriteViewRamDataO19(spriteViewRamDataO[19]),
    .spriteViewRamDataO20(spriteViewRamDataO[20]),
    .spriteViewRamDataO21(spriteViewRamDataO[21]),
    .spriteViewRamDataO22(spriteViewRamDataO[22]),
    .spriteViewRamDataO23(spriteViewRamDataO[23]),
    .spriteViewRamDataO24(spriteViewRamDataO[24]),
    .spriteViewRamDataO25(spriteViewRamDataO[25]),
    .spriteViewRamDataO26(spriteViewRamDataO[26]),
    .spriteViewRamDataO27(spriteViewRamDataO[27]),
    .spriteViewRamDataO28(spriteViewRamDataO[28]),
    .spriteViewRamDataO29(spriteViewRamDataO[29]),
    .spriteViewRamDataO30(spriteViewRamDataO[30]),
    .spriteViewRamDataO31(spriteViewRamDataO[31]),
    .spriteViewRamDataO32(spriteViewRamDataO[32]),
    .spriteViewRamDataO33(spriteViewRamDataO[33]),
    .spriteViewRamDataO34(spriteViewRamDataO[34]),
    .spriteViewRamDataO35(spriteViewRamDataO[35]),
    .spriteViewRamDataO36(spriteViewRamDataO[36]),
    .spriteViewRamDataO37(spriteViewRamDataO[37]),
    .spriteViewRamDataO38(spriteViewRamDataO[38]),
    .spriteViewRamDataO39(spriteViewRamDataO[39]),
    .spriteViewRamDataO40(spriteViewRamDataO[40]),
    .spriteViewRamDataO41(spriteViewRamDataO[41]),
    .spriteViewRamDataO42(spriteViewRamDataO[42]),
    .spriteViewRamDataO43(spriteViewRamDataO[43]),
    .spriteViewRamDataO44(spriteViewRamDataO[44]),
    .spriteViewRamDataO45(spriteViewRamDataO[45]),
    .spriteViewRamDataO46(spriteViewRamDataO[46]),
    .spriteViewRamDataO47(spriteViewRamDataO[47]),
    .spriteViewRamDataO48(spriteViewRamDataO[48]),
    .spriteViewRamDataO49(spriteViewRamDataO[49]),
    .spriteViewRamDataO50(spriteViewRamDataO[50]),
    .spriteViewRamDataO51(spriteViewRamDataO[51]),
    .spriteViewRamDataO52(spriteViewRamDataO[52]),
    .spriteViewRamDataO53(spriteViewRamDataO[53]),
    .spriteViewRamDataO54(spriteViewRamDataO[54]),
    .spriteViewRamDataO55(spriteViewRamDataO[55]),
    .spriteViewRamDataO56(spriteViewRamDataO[56]),
    .spriteViewRamDataO57(spriteViewRamDataO[57]),
    .spriteViewRamDataO58(spriteViewRamDataO[58]),
    .spriteViewRamDataO59(spriteViewRamDataO[59]),
    .spriteViewRamDataO60(spriteViewRamDataO[60]),
    .spriteViewRamDataO61(spriteViewRamDataO[61]),
    .spriteViewRamDataO62(spriteViewRamDataO[62]),
    .spriteViewRamDataO63(spriteViewRamDataO[63]) 
);

spriteTileRom u_spriteTileRom(
    //from tiltDraw.v
    .tileDataO00(tileDataI[00]), //tile的索引值
    .tileDataO01(tileDataI[01]),
    .tileDataO02(tileDataI[02]),
    .tileDataO03(tileDataI[03]),
    .tileDataO04(tileDataI[04]),
    .tileDataO05(tileDataI[05]),
    .tileDataO06(tileDataI[06]),
    .tileDataO07(tileDataI[07]),
    .tileDataO08(tileDataI[08]),
    .tileDataO09(tileDataI[09]),
    .tileDataO10(tileDataI[10]),
    .tileDataO11(tileDataI[11]),
    .tileDataO12(tileDataI[12]),
    .tileDataO13(tileDataI[13]),
    .tileDataO14(tileDataI[14]),
    .tileDataO15(tileDataI[15]),
    .tileDataO16(tileDataI[16]),
    .tileDataO17(tileDataI[17]),
    .tileDataO18(tileDataI[18]),
    .tileDataO19(tileDataI[19]),
    .tileDataO20(tileDataI[20]),
    .tileDataO21(tileDataI[21]),
    .tileDataO22(tileDataI[22]),
    .tileDataO23(tileDataI[23]),
    .tileDataO24(tileDataI[24]),
    .tileDataO25(tileDataI[25]),
    .tileDataO26(tileDataI[26]),
    .tileDataO27(tileDataI[27]),
    .tileDataO28(tileDataI[28]),
    .tileDataO29(tileDataI[29]),
    .tileDataO30(tileDataI[30]),
    .tileDataO31(tileDataI[31]),
    .tileDataO32(tileDataI[32]),
    .tileDataO33(tileDataI[33]),
    .tileDataO34(tileDataI[34]),
    .tileDataO35(tileDataI[35]),
    .tileDataO36(tileDataI[36]),
    .tileDataO37(tileDataI[37]),
    .tileDataO38(tileDataI[38]),
    .tileDataO39(tileDataI[39]),
    .tileDataO40(tileDataI[40]),
    .tileDataO41(tileDataI[41]),
    .tileDataO42(tileDataI[42]),
    .tileDataO43(tileDataI[43]),
    .tileDataO44(tileDataI[44]),
    .tileDataO45(tileDataI[45]),
    .tileDataO46(tileDataI[46]),
    .tileDataO47(tileDataI[47]),
    .tileDataO48(tileDataI[48]),
    .tileDataO49(tileDataI[49]),
    .tileDataO50(tileDataI[50]),
    .tileDataO51(tileDataI[51]),
    .tileDataO52(tileDataI[52]),
    .tileDataO53(tileDataI[53]),
    .tileDataO54(tileDataI[54]),
    .tileDataO55(tileDataI[55]),
    .tileDataO56(tileDataI[56]),
    .tileDataO57(tileDataI[57]),
    .tileDataO58(tileDataI[58]),
    .tileDataO59(tileDataI[59]),
    .tileDataO60(tileDataI[60]),
    .tileDataO61(tileDataI[61]),
    .tileDataO62(tileDataI[62]),
    .tileDataO63(tileDataI[63]),

    .tileIndex00(tileIndex[00]),
    .tileIndex01(tileIndex[01]),
    .tileIndex02(tileIndex[02]),
    .tileIndex03(tileIndex[03]),
    .tileIndex04(tileIndex[04]),
    .tileIndex05(tileIndex[05]),
    .tileIndex06(tileIndex[06]),
    .tileIndex07(tileIndex[07]),
    .tileIndex08(tileIndex[08]),
    .tileIndex09(tileIndex[09]),
    .tileIndex10(tileIndex[10]),
    .tileIndex11(tileIndex[11]),
    .tileIndex12(tileIndex[12]),
    .tileIndex13(tileIndex[13]),
    .tileIndex14(tileIndex[14]),
    .tileIndex15(tileIndex[15]),
    .tileIndex16(tileIndex[16]),
    .tileIndex17(tileIndex[17]),
    .tileIndex18(tileIndex[18]),
    .tileIndex19(tileIndex[19]),
    .tileIndex20(tileIndex[20]),
    .tileIndex21(tileIndex[21]),
    .tileIndex22(tileIndex[22]),
    .tileIndex23(tileIndex[23]),
    .tileIndex24(tileIndex[24]),
    .tileIndex25(tileIndex[25]),
    .tileIndex26(tileIndex[26]),
    .tileIndex27(tileIndex[27]),
    .tileIndex28(tileIndex[28]),
    .tileIndex29(tileIndex[29]),
    .tileIndex30(tileIndex[30]),
    .tileIndex31(tileIndex[31]),
    .tileIndex32(tileIndex[32]),
    .tileIndex33(tileIndex[33]),
    .tileIndex34(tileIndex[34]),
    .tileIndex35(tileIndex[35]),
    .tileIndex36(tileIndex[36]),
    .tileIndex37(tileIndex[37]),
    .tileIndex38(tileIndex[38]),
    .tileIndex39(tileIndex[39]),
    .tileIndex40(tileIndex[40]),
    .tileIndex41(tileIndex[41]),
    .tileIndex42(tileIndex[42]),
    .tileIndex43(tileIndex[43]),
    .tileIndex44(tileIndex[44]),
    .tileIndex45(tileIndex[45]),
    .tileIndex46(tileIndex[46]),
    .tileIndex47(tileIndex[47]),
    .tileIndex48(tileIndex[48]),
    .tileIndex49(tileIndex[49]),
    .tileIndex50(tileIndex[50]),
    .tileIndex51(tileIndex[51]),
    .tileIndex52(tileIndex[52]),
    .tileIndex53(tileIndex[53]),
    .tileIndex54(tileIndex[54]),
    .tileIndex55(tileIndex[55]),
    .tileIndex56(tileIndex[56]),
    .tileIndex57(tileIndex[57]),
    .tileIndex58(tileIndex[58]),
    .tileIndex59(tileIndex[59]),
    .tileIndex60(tileIndex[60]),
    .tileIndex61(tileIndex[61]),
    .tileIndex62(tileIndex[62]),
    .tileIndex63(tileIndex[63])
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

endmodule