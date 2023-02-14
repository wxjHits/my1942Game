/*
    精灵tile的素材库
*/
`include "C:/Users/hp/Desktop/my1942Game/RTL/src/game/PPU/define.v"
module spriteTileRom(
    //from tiltDraw.v
    input   wire    [`SPRITE_TILEROM_ADDRBIT-1:0]  tileIndex00, //tile的索引�??
    input   wire    [`SPRITE_TILEROM_ADDRBIT-1:0]  tileIndex01,
    input   wire    [`SPRITE_TILEROM_ADDRBIT-1:0]  tileIndex02,
    input   wire    [`SPRITE_TILEROM_ADDRBIT-1:0]  tileIndex03,
    input   wire    [`SPRITE_TILEROM_ADDRBIT-1:0]  tileIndex04,
    input   wire    [`SPRITE_TILEROM_ADDRBIT-1:0]  tileIndex05,
    input   wire    [`SPRITE_TILEROM_ADDRBIT-1:0]  tileIndex06,
    input   wire    [`SPRITE_TILEROM_ADDRBIT-1:0]  tileIndex07,

    output  wire    [`SPRITE_TILEDATA_BIT-1:0]     tileDataO00,
    output  wire    [`SPRITE_TILEDATA_BIT-1:0]     tileDataO01,
    output  wire    [`SPRITE_TILEDATA_BIT-1:0]     tileDataO02,
    output  wire    [`SPRITE_TILEDATA_BIT-1:0]     tileDataO03,
    output  wire    [`SPRITE_TILEDATA_BIT-1:0]     tileDataO04,
    output  wire    [`SPRITE_TILEDATA_BIT-1:0]     tileDataO05,
    output  wire    [`SPRITE_TILEDATA_BIT-1:0]     tileDataO06,
    output  wire    [`SPRITE_TILEDATA_BIT-1:0]     tileDataO07
);
    /*****图片素材ROM的初始化*****/
    reg  [`SPRITE_TILEDATA_BIT-1:0] spritemem [0:`SPRITE_TILEROM_DEEPTH-1];
    initial begin
	    $readmemh("C:/Users/hp/Desktop/my1942Game/RTL/src/game/PPU/ppuDocTxt/spriteTile.txt", spritemem);
	end

    assign tileDataO00 = spritemem[tileIndex00];
    assign tileDataO01 = spritemem[tileIndex01];
    assign tileDataO02 = spritemem[tileIndex02];
    assign tileDataO03 = spritemem[tileIndex03];
    assign tileDataO04 = spritemem[tileIndex04];
    assign tileDataO05 = spritemem[tileIndex05];
    assign tileDataO06 = spritemem[tileIndex06];
    assign tileDataO07 = spritemem[tileIndex07];
endmodule