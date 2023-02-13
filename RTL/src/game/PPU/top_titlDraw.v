`include "C:/Users/hp/Desktop/my_1942/define.v"
module top_tileDraw(
    input   wire            clk_50MHz   ,
    input   wire            sys_rstn    ,
    output  wire            hsync       ,//输出行同步信号
    output  wire            vsync       ,//输出场同步信号
    output  wire    [11:0]  rgb          //输出像素点色彩信息

);
    wire        clk_100MHz  ;//100MHz//用于计算的时钟必须大于VGA的扫描时钟，这样计算过程可以多个时钟周期
    wire        vga_clk     ;//25MHz

    clk_wiz_0 instance_name
    (
        .clk_100MHz(clk_100MHz),     // output clk_100MHz
        .clk_25p2MHz(vga_clk),     // output clk_25p2MHz
        .clk_in1(clk_50MHz)
    );
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
                .rstn                   (sys_rstn               ),
                .vgaPosX                (vgaPosX                ),
                .vgaPosY                (vgaPosY                ),
                .inSpriteViewRamIndex   (i                      ),
                .spriteViewRamIndex     (spriteViewRamIndex[i]  ),
                .spriteViewRamDataO     (spriteViewRamDataO[i]  ),
                .tileIndex              (tileIndex[i]           ),
                .tileDataI              (tileDataI[i]           ),
                .IsScanRange            (IsScanRange[i]         ),
                .vgaRgbOut              (vgaRgbOut[i]           )
            );
        end
    endgenerate

spriteRam u_spriteRam(
    //例化的64个tileDraw
    .spriteViewRamIndex00(spriteViewRamIndex[00]),
    .spriteViewRamIndex01(spriteViewRamIndex[01]),
    .spriteViewRamIndex02(spriteViewRamIndex[02]),
    .spriteViewRamIndex03(spriteViewRamIndex[03]),
    .spriteViewRamIndex04(spriteViewRamIndex[04]),
    .spriteViewRamIndex05(spriteViewRamIndex[05]),
    .spriteViewRamIndex06(spriteViewRamIndex[06]),
    .spriteViewRamIndex07(spriteViewRamIndex[07]),
    .spriteViewRamIndex08(spriteViewRamIndex[08]),
    .spriteViewRamIndex09(spriteViewRamIndex[09]),
    .spriteViewRamIndex10(spriteViewRamIndex[10]),
    .spriteViewRamIndex11(spriteViewRamIndex[11]),
    .spriteViewRamIndex12(spriteViewRamIndex[12]),
    .spriteViewRamIndex13(spriteViewRamIndex[13]),
    .spriteViewRamIndex14(spriteViewRamIndex[14]),
    .spriteViewRamIndex15(spriteViewRamIndex[15]),
    .spriteViewRamIndex16(spriteViewRamIndex[16]),
    .spriteViewRamIndex17(spriteViewRamIndex[17]),
    .spriteViewRamIndex18(spriteViewRamIndex[18]),
    .spriteViewRamIndex19(spriteViewRamIndex[19]),
    .spriteViewRamIndex20(spriteViewRamIndex[20]),
    .spriteViewRamIndex21(spriteViewRamIndex[21]),
    .spriteViewRamIndex22(spriteViewRamIndex[22]),
    .spriteViewRamIndex23(spriteViewRamIndex[23]),
    .spriteViewRamIndex24(spriteViewRamIndex[24]),
    .spriteViewRamIndex25(spriteViewRamIndex[25]),
    .spriteViewRamIndex26(spriteViewRamIndex[26]),
    .spriteViewRamIndex27(spriteViewRamIndex[27]),
    .spriteViewRamIndex28(spriteViewRamIndex[28]),
    .spriteViewRamIndex29(spriteViewRamIndex[29]),
    .spriteViewRamIndex30(spriteViewRamIndex[30]),
    .spriteViewRamIndex31(spriteViewRamIndex[31]),
    .spriteViewRamIndex32(spriteViewRamIndex[32]),
    .spriteViewRamIndex33(spriteViewRamIndex[33]),
    .spriteViewRamIndex34(spriteViewRamIndex[34]),
    .spriteViewRamIndex35(spriteViewRamIndex[35]),
    .spriteViewRamIndex36(spriteViewRamIndex[36]),
    .spriteViewRamIndex37(spriteViewRamIndex[37]),
    .spriteViewRamIndex38(spriteViewRamIndex[38]),
    .spriteViewRamIndex39(spriteViewRamIndex[39]),
    .spriteViewRamIndex40(spriteViewRamIndex[40]),
    .spriteViewRamIndex41(spriteViewRamIndex[41]),
    .spriteViewRamIndex42(spriteViewRamIndex[42]),
    .spriteViewRamIndex43(spriteViewRamIndex[43]),
    .spriteViewRamIndex44(spriteViewRamIndex[44]),
    .spriteViewRamIndex45(spriteViewRamIndex[45]),
    .spriteViewRamIndex46(spriteViewRamIndex[46]),
    .spriteViewRamIndex47(spriteViewRamIndex[47]),
    .spriteViewRamIndex48(spriteViewRamIndex[48]),
    .spriteViewRamIndex49(spriteViewRamIndex[49]),
    .spriteViewRamIndex50(spriteViewRamIndex[50]),
    .spriteViewRamIndex51(spriteViewRamIndex[51]),
    .spriteViewRamIndex52(spriteViewRamIndex[52]),
    .spriteViewRamIndex53(spriteViewRamIndex[53]),
    .spriteViewRamIndex54(spriteViewRamIndex[54]),
    .spriteViewRamIndex55(spriteViewRamIndex[55]),
    .spriteViewRamIndex56(spriteViewRamIndex[56]),
    .spriteViewRamIndex57(spriteViewRamIndex[57]),
    .spriteViewRamIndex58(spriteViewRamIndex[58]),
    .spriteViewRamIndex59(spriteViewRamIndex[59]),
    .spriteViewRamIndex60(spriteViewRamIndex[60]),
    .spriteViewRamIndex61(spriteViewRamIndex[61]),
    .spriteViewRamIndex62(spriteViewRamIndex[62]),
    .spriteViewRamIndex63(spriteViewRamIndex[63]),

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

    // wire    [$clog2(`SPRITE_NUM_MAX)-1:0]  spriteViewRamIndex00;   //tile的索引值
    // wire    [$clog2(`SPRITE_NUM_MAX)-1:0]  spriteViewRamIndex01;
    // wire    [$clog2(`SPRITE_NUM_MAX)-1:0]  spriteViewRamIndex02;
    // wire    [$clog2(`SPRITE_NUM_MAX)-1:0]  spriteViewRamIndex03;
    // wire    [$clog2(`SPRITE_NUM_MAX)-1:0]  spriteViewRamIndex04;
    // wire    [$clog2(`SPRITE_NUM_MAX)-1:0]  spriteViewRamIndex05;
    // wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO00;
    // wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO01;
    // wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO02;
    // wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO03;
    // wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO04;
    // wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO05;
    // wire    [`SPRITE_TILEROM_ADDRBIT-1:0]   tileIndex00;
    // wire    [`SPRITE_TILEROM_ADDRBIT-1:0]   tileIndex01;
    // wire    [`SPRITE_TILEROM_ADDRBIT-1:0]   tileIndex02;
    // wire    [`SPRITE_TILEROM_ADDRBIT-1:0]   tileIndex03;
    // wire    [`SPRITE_TILEROM_ADDRBIT-1:0]   tileIndex04;
    // wire    [`SPRITE_TILEROM_ADDRBIT-1:0]   tileIndex05;
    // wire    [`SPRITE_TILEDATA_BIT-1:0]      tileDataI00;
    // wire    [`SPRITE_TILEDATA_BIT-1:0]      tileDataI01;
    // wire    [`SPRITE_TILEDATA_BIT-1:0]      tileDataI02;
    // wire    [`SPRITE_TILEDATA_BIT-1:0]      tileDataI03;
    // wire    [`SPRITE_TILEDATA_BIT-1:0]      tileDataI04;
    // wire    [`SPRITE_TILEDATA_BIT-1:0]      tileDataI05;
    // wire                                    IsScanRange00;
    // wire                                    IsScanRange01;
    // wire                                    IsScanRange02;
    // wire                                    IsScanRange03;
    // wire                                    IsScanRange04;
    // wire                                    IsScanRange05;
    
    // //to VGA_driver.v
    // wire [`RGB_BIT-1:0] vgaRgbOut00;
    // wire [`RGB_BIT-1:0] vgaRgbOut01;
    // wire [`RGB_BIT-1:0] vgaRgbOut02;
    // wire [`RGB_BIT-1:0] vgaRgbOut03;
    // wire [`RGB_BIT-1:0] vgaRgbOut04;
    // wire [`RGB_BIT-1:0] vgaRgbOut05;

//     //颜色的选择，如果重叠
//     wire [`RGB_BIT-1:0] vgaRgbOutSel = IsScanRange00 ? vgaRgbOut00 : (
//                                     IsScanRange01 ? vgaRgbOut01 : (
//                                     IsScanRange02 ? vgaRgbOut02 : (
//                                     IsScanRange03 ? vgaRgbOut03 : (
//                                     IsScanRange04 ? vgaRgbOut04 : (
//                                     IsScanRange05 ? vgaRgbOut05 : 12'h0)))));


    

// tileDraw u_tileDraw00(
//     .clk            (clk_100MHz   ),//用于计算的时钟必须大于VGA的扫描时钟，这样计算过程可以多个时钟周期
//     .rstn           (sys_rstn         ),
//     .vgaPosX        (vgaPosX      ),
//     .vgaPosY        (vgaPosY      ),
//     .inSpriteViewRamIndex(0),
//     .spriteViewRamIndex(spriteViewRamIndex00),
//     .spriteViewRamDataO(spriteViewRamDataO00),
//     .tileIndex      (tileIndex00    ),
//     .tileDataI      (tileDataI00    ),
//     .IsScanRange    (IsScanRange00    ),
//     .vgaRgbOut      (vgaRgbOut00    )
// );

// tileDraw u_tileDraw01(
//     .clk            (clk_100MHz   ),//用于计算的时钟必须大于VGA的扫描时钟，这样计算过程可以多个时钟周期
//     .rstn           (sys_rstn         ),
//     .vgaPosX        (vgaPosX      ),
//     .vgaPosY        (vgaPosY      ),

//     .inSpriteViewRamIndex(1),
//     .spriteViewRamIndex(spriteViewRamIndex01),
//     .spriteViewRamDataO(spriteViewRamDataO01),
//     .tileIndex      (tileIndex01    ),

//     .tileDataI      (tileDataI01    ),

//     .IsScanRange    (IsScanRange01    ),

//     .vgaRgbOut      (vgaRgbOut01    )
// );

// tileDraw u_tileDraw02(
//     .clk            (clk_100MHz   ),//用于计算的时钟必须大于VGA的扫描时钟，这样计算过程可以多个时钟周期
//     .rstn           (sys_rstn         ),
//     .vgaPosX        (vgaPosX      ),
//     .vgaPosY        (vgaPosY      ),

//     .inSpriteViewRamIndex(2),
//     .spriteViewRamIndex(spriteViewRamIndex02),
//     .spriteViewRamDataO(spriteViewRamDataO02),
//     .tileIndex      (tileIndex02    ),

//     .tileDataI      (tileDataI02    ),

//     .IsScanRange    (IsScanRange02    ),

//     .vgaRgbOut      (vgaRgbOut02    )
// );

// tileDraw u_tileDraw03(
//     .clk            (clk_100MHz   ),//用于计算的时钟必须大于VGA的扫描时钟，这样计算过程可以多个时钟周期
//     .rstn           (sys_rstn         ),
//     .vgaPosX        (vgaPosX      ),
//     .vgaPosY        (vgaPosY      ),
//     .inSpriteViewRamIndex(3),
//     .spriteViewRamIndex(spriteViewRamIndex03),
//     .spriteViewRamDataO(spriteViewRamDataO03),
//     .tileIndex      (tileIndex03    ),
//     .tileDataI      (tileDataI03    ),
//     .IsScanRange    (IsScanRange03    ),
//     .vgaRgbOut      (vgaRgbOut03    )
// );
// tileDraw u_tileDraw04(
//     .clk            (clk_100MHz   ),//用于计算的时钟必须大于VGA的扫描时钟，这样计算过程可以多个时钟周期
//     .rstn           (sys_rstn         ),
//     .vgaPosX        (vgaPosX      ),
//     .vgaPosY        (vgaPosY      ),
//     .inSpriteViewRamIndex(4),
//     .spriteViewRamIndex(spriteViewRamIndex04),
//     .spriteViewRamDataO(spriteViewRamDataO04),
//     .tileIndex      (tileIndex04    ),
//     .tileDataI      (tileDataI04    ),
//     .IsScanRange    (IsScanRange04    ),
//     .vgaRgbOut      (vgaRgbOut04    )
// );
// tileDraw u_tileDraw05(
//     .clk            (clk_100MHz   ),//用于计算的时钟必须大于VGA的扫描时钟，这样计算过程可以多个时钟周期
//     .rstn           (sys_rstn         ),
//     .vgaPosX        (vgaPosX      ),
//     .vgaPosY        (vgaPosY      ),
//     .inSpriteViewRamIndex(5),
//     .spriteViewRamIndex(spriteViewRamIndex05),
//     .spriteViewRamDataO(spriteViewRamDataO05),
//     .tileIndex      (tileIndex05    ),
//     .tileDataI      (tileDataI05    ),
//     .IsScanRange    (IsScanRange05    ),
//     .vgaRgbOut      (vgaRgbOut05    )
// );

// spriteRam u_spriteRam(
//     // .spriteViewRamIndex(spriteViewRamIndex00),   //tile的索引值
//     // .spriteViewRamDataO(spriteViewRamDataO00)
//     .spriteViewRamIndex00(spriteViewRamIndex00),
//     .spriteViewRamIndex01(spriteViewRamIndex01),
//     .spriteViewRamIndex02(spriteViewRamIndex02),
//     .spriteViewRamIndex03(spriteViewRamIndex03),
//     .spriteViewRamIndex04(spriteViewRamIndex04),
//     .spriteViewRamIndex05(spriteViewRamIndex05),
//     // .spriteViewRamIndex00(0),
//     // .spriteViewRamIndex01(1),
//     .spriteViewRamDataO00(spriteViewRamDataO00),
//     .spriteViewRamDataO01(spriteViewRamDataO01),
//     .spriteViewRamDataO02(spriteViewRamDataO02),
//     .spriteViewRamDataO03(spriteViewRamDataO03),
//     .spriteViewRamDataO04(spriteViewRamDataO04),
//     .spriteViewRamDataO05(spriteViewRamDataO05)
// );

// spriteTileRom u_spriteTileRom(
//     // .tileIndex(tileIndex00),   //tile的索引值
//     // .tileDataO(tileDataI00)
//     .tileIndex00(tileIndex00),
//     .tileIndex01(tileIndex01),
//     .tileIndex02(tileIndex02),
//     .tileIndex03(tileIndex03),
//     .tileIndex04(tileIndex04),
//     .tileIndex05(tileIndex05),
//     .tileDataO00(tileDataI00),
//     .tileDataO01(tileDataI01),
//     .tileDataO02(tileDataI02),
//     .tileDataO03(tileDataI03),
//     .tileDataO04(tileDataI04),
//     .tileDataO05(tileDataI05)
// );

//     //颜色的选择，如果重叠
// wire [`RGB_BIT-1:0] vgaRgbOutSel =  IsScanRange00 ? vgaRgbOut00 : (
//                                     IsScanRange01 ? vgaRgbOut01 : (
//                                     IsScanRange02 ? vgaRgbOut02 : (
//                                     IsScanRange03 ? vgaRgbOut03 : (
//                                     IsScanRange04 ? vgaRgbOut04 : (
//                                     IsScanRange05 ? vgaRgbOut05 : 12'h0)))));
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
vga_driver  u_vga_driver
(
    .vga_clk    (vga_clk) ,   //输入工作时钟,频率25MHz
    .rstn     (sys_rstn),   //输入复位信号,低电平有效
    .pixdata(vgaRgbOutSel)    ,   //输入像素点色彩信息
    .pix_x(vgaPosX) ,   //输出VGA有效显示区域像素点X轴坐标
    .pix_y(vgaPosY) ,   //输出VGA有效显示区域像素点Y轴坐标
    .hsync(hsync)       ,   //输出行同步信号
    .vsync(vsync)       ,   //输出场同步信号
    .rgb  (rgb  )           //输出像素点色彩信息
);

endmodule