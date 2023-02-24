/*
    weixuejing 2023.02.06
    ä¸?ä¸Ştileççťĺść¨Ąĺ?    
*/
`include "define.v"
module tileDraw(
    input wire             clk,//ç¨äşčŽĄçŽçćśéĺżéĄťĺ¤§äşVGAçćŤććśéďźčżć ˇčŽĄçŽčżç¨ĺŻäťĽĺ¤ä¸Şćśéĺ¨ć
    input wire             rstn,

    //from VGA_driver
    input wire [`VGA_POSXY_BIT-1:0] vgaPosX,
    input wire [`VGA_POSXY_BIT-1:0] vgaPosY,

    input wire    [$clog2(`SPRITE_NUM_MAX)-1:0]  inSpriteViewRamIndex,   //SpriteViewRamçç´˘ĺźĺ??  
    //to spriteViewRam.v
    output wire    [$clog2(`SPRITE_NUM_MAX)-1:0]  spriteViewRamIndex,   //SpriteViewRamçç´˘ĺźĺ?źspriteViewRamIndex=inSpriteViewRamIndex
    //from spriteViewRam.v
    input  wire    [4*(`BYTE)-1:0]     spriteViewRamDataO,
    
    //to spriteTileRom.v
    output wire    [`SPRITE_TILEROM_ADDRBIT-1:0]  tileIndex,
    //from spriteTileRom.v çątileIndexç´˘ĺźĺžĺ°
    input wire  [`SPRITE_TILEDATA_BIT-1:0]  tileDataI,

    output wire                             IsScanRange,//ĺ˝ĺtitleçćŤćčĺ?
    
    //to VGA_driver.v
    input wire [`RGB_BIT-1:0] backgroundVgaRgbIn,
    output reg [`RGB_BIT-1:0] vgaRgbOut
);
    assign spriteViewRamIndex = inSpriteViewRamIndex;
//ç˛žçľĺć°č§Łć
    // input wire [`BYTE-1:0] posX,
    // input wire [`BYTE-1:0] posY,
    // input wire [`BYTE-1:0] tileIndex,
    // input wire             hFilp,
    // input wire             vFilp,
    // input wire [1:0]       PaletteChoice,

    wire [`BYTE-1:0] posX = spriteViewRamDataO[4*(`BYTE)-1:3*(`BYTE)];
    wire [`BYTE-1:0] posY = spriteViewRamDataO[3*(`BYTE)-1:2*(`BYTE)];
    assign tileIndex = spriteViewRamDataO[2*(`BYTE)-1:1*(`BYTE)];
    wire             hFilp = spriteViewRamDataO[7];
    wire             vFilp = spriteViewRamDataO[6];
    wire [1:0]       PaletteChoice = spriteViewRamDataO[5:4];

//ç¸ĺŻšäşć¸¸ćĺźĺ§ĺć çšçĺć ?
reg [`VGA_POSXY_BIT-1:0] vgaPosX_r;
reg [`VGA_POSXY_BIT-1:0] vgaPosY_r;
always@(posedge clk)begin //2023.02.22添加，优化了一下时序，显示效果好了许多
    if(~rstn)begin
        vgaPosX_r<=0;
        vgaPosY_r<=0;
    end
    else begin
        vgaPosX_r<=vgaPosX;
        vgaPosY_r<=vgaPosY;
    end
end

reg [`VGA_POSXY_BIT-1:0] gameVgaPosX;
reg [`VGA_POSXY_BIT-1:0] gameVgaPosY;
always@(posedge clk)begin
    if(~rstn)begin
        gameVgaPosX<=0;
        gameVgaPosY<=0;
    end
    else begin
        gameVgaPosX<=vgaPosX_r-`GAME_START_POSX;
        gameVgaPosY<=vgaPosY_r-`GAME_START_POSY;
    end
end

//çĄŽĺŽĺ˝ĺtiltçćŤćčĺ?

assign IsScanRange = (gameVgaPosX>=posX && gameVgaPosX<posX+`TILE_W && gameVgaPosY>=posY && gameVgaPosY<posY+`TILE_H);
//čŽĄçŽĺ˝ĺĺç´ çšĺŻšĺştileDataIçĺŞä¸?ä¸Şbit
reg [`BYTE-1:0]DistX,DistY;
always@(posedge clk)begin
    if(~rstn)begin
        DistX<=0;
        DistY<=0;
    end
    else if(IsScanRange)begin
        case({hFilp,vFilp})
            2'b00:begin//ć­Łĺ¸¸ćžç¤ş
                DistX<=gameVgaPosX-posX;
                DistY<=gameVgaPosY-posY;
            end
            2'b01:begin//ĺˇŚĺłçżťč˝Ź
                DistX<=7-(gameVgaPosX-posX);
                DistY<=gameVgaPosY-posY;
            end
            2'b10:begin//ä¸ä¸çżťč˝Ź
                DistX<=gameVgaPosX-posX;
                DistY<=7-(gameVgaPosY-posY);
            end
            2'b11:begin//ä¸ä¸&ĺˇŚĺłçżťč˝Ź
                DistX<=7-(gameVgaPosX-posX);
                DistY<=7-(gameVgaPosY-posY);
            end
        endcase
    end
end

// reg [`BYTE-1:0]DistX,DistY;
// always@(*)begin
//     if(~rstn)begin
//         DistX=0;
//         DistY=0;
//     end
//     else if(IsScanRange)begin
//         case({hFilp,vFilp})
//             2'b00:begin//ć­Łĺ¸¸ćžç¤ş
//                 DistX=gameVgaPosX-posX;
//                 DistY=gameVgaPosY-posY;
//             end
//             2'b01:begin//ĺˇŚĺłçżťč˝Ź
//                 DistX=7-(gameVgaPosX-posX);
//                 DistY=gameVgaPosY-posY;
//             end
//             2'b10:begin//ä¸ä¸çżťč˝Ź
//                 DistX=gameVgaPosX-posX;
//                 DistY=7-(gameVgaPosY-posY);
//             end
//             2'b11:begin//ä¸ä¸&ĺˇŚĺłçżťč˝Ź
//                 DistX=7-(gameVgaPosX-posX);
//                 DistY=7-(gameVgaPosY-posY);
//             end
//         endcase
//     end
// end

reg [$clog2(`SPRITE_TILEDATA_BIT)-1:0] whichBit;
always@(*)begin
    whichBit = DistX+(`TILE_W)*DistY;
end

//č˛ĺ˝Š
wire  [`RGB_BIT-1:0] PaletteColor00;
wire  [`RGB_BIT-1:0] PaletteColor01;
wire  [`RGB_BIT-1:0] PaletteColor10;
wire  [`RGB_BIT-1:0] PaletteColor11;

//çĄŽĺŽä¸?ä¸Şçšçč˛ĺ˝Šĺ??
wire [1:0]yy={tileDataI[127-whichBit],tileDataI[63-whichBit]};
always@(*)begin
    case({tileDataI[127-whichBit],tileDataI[63-whichBit]})
        2'b00:vgaRgbOut=backgroundVgaRgbIn;
        2'b01:vgaRgbOut=PaletteColor01;
        2'b10:vgaRgbOut=PaletteColor10;
        2'b11:vgaRgbOut=PaletteColor11;
        default:vgaRgbOut=0;
    endcase
end

//č°č˛ćżçéćŠ
palette palette_inst (
    .PaletteChoice(PaletteChoice),
    .PaletteColor00(PaletteColor00),
    .PaletteColor01(PaletteColor01),
    .PaletteColor10(PaletteColor10),
    .PaletteColor11(PaletteColor11)
);
endmodule