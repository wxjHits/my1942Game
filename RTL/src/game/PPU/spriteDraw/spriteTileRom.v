/*
    精灵tile的素材库
*/
`include "C:/Users/hp/Desktop/my1942Game/RTL/src/game/PPU/define.v"
module spriteTileRom(
    input   wire clk,
    //from tiltDraw.v
    input   wire    [`SPRITE_TILEROM_ADDRBIT-1:0]  tileIndex00, //tile的索引�??
    input   wire    [`SPRITE_TILEROM_ADDRBIT-1:0]  tileIndex01,
    input   wire    [`SPRITE_TILEROM_ADDRBIT-1:0]  tileIndex02,
    input   wire    [`SPRITE_TILEROM_ADDRBIT-1:0]  tileIndex03,
    input   wire    [`SPRITE_TILEROM_ADDRBIT-1:0]  tileIndex04,
    input   wire    [`SPRITE_TILEROM_ADDRBIT-1:0]  tileIndex05,
    input   wire    [`SPRITE_TILEROM_ADDRBIT-1:0]  tileIndex06,
    input   wire    [`SPRITE_TILEROM_ADDRBIT-1:0]  tileIndex07,

    output  reg     [`SPRITE_TILEDATA_BIT-1:0]     tileDataO00,
    output  reg     [`SPRITE_TILEDATA_BIT-1:0]     tileDataO01,
    output  reg     [`SPRITE_TILEDATA_BIT-1:0]     tileDataO02,
    output  reg     [`SPRITE_TILEDATA_BIT-1:0]     tileDataO03,
    output  reg     [`SPRITE_TILEDATA_BIT-1:0]     tileDataO04,
    output  reg     [`SPRITE_TILEDATA_BIT-1:0]     tileDataO05,
    output  reg     [`SPRITE_TILEDATA_BIT-1:0]     tileDataO06,
    output  reg     [`SPRITE_TILEDATA_BIT-1:0]     tileDataO07
);
    /*****图片素材ROM的初始化*****/
    // (* ram_style="block" *)reg  [`SPRITE_TILEDATA_BIT-1:0] spritemem [0:`SPRITE_TILEROM_DEEPTH-1];
    // initial begin
    //     $readmemh("C:/Users/hp/Desktop/my1942Game/RTL/src/game/PPU/ppuDocTxt/game1942sprite.txt", spritemem);
    // end

    // assign tileDataO00 = spritemem[tileIndex00];
    // assign tileDataO01 = spritemem[tileIndex01];
    // assign tileDataO02 = spritemem[tileIndex02];
    // assign tileDataO03 = spritemem[tileIndex03];
    // assign tileDataO04 = spritemem[tileIndex04];
    // assign tileDataO05 = spritemem[tileIndex05];
    // assign tileDataO06 = spritemem[tileIndex06];
    // assign tileDataO07 = spritemem[tileIndex07];

    (* ram_style="block" *)reg  [`SPRITE_TILEDATA_BIT-1:0] spritemem_0 [0:`SPRITE_TILEROM_DEEPTH-1];
    (* ram_style="block" *)reg  [`SPRITE_TILEDATA_BIT-1:0] spritemem_1 [0:`SPRITE_TILEROM_DEEPTH-1];
    (* ram_style="block" *)reg  [`SPRITE_TILEDATA_BIT-1:0] spritemem_2 [0:`SPRITE_TILEROM_DEEPTH-1];
    (* ram_style="block" *)reg  [`SPRITE_TILEDATA_BIT-1:0] spritemem_3 [0:`SPRITE_TILEROM_DEEPTH-1];
    (* ram_style="block" *)reg  [`SPRITE_TILEDATA_BIT-1:0] spritemem_4 [0:`SPRITE_TILEROM_DEEPTH-1];
    (* ram_style="block" *)reg  [`SPRITE_TILEDATA_BIT-1:0] spritemem_5 [0:`SPRITE_TILEROM_DEEPTH-1];
    (* ram_style="block" *)reg  [`SPRITE_TILEDATA_BIT-1:0] spritemem_6 [0:`SPRITE_TILEROM_DEEPTH-1];
    (* ram_style="block" *)reg  [`SPRITE_TILEDATA_BIT-1:0] spritemem_7 [0:`SPRITE_TILEROM_DEEPTH-1];
    initial begin
        $readmemh("C:/Users/hp/Desktop/my1942Game/RTL/src/game/PPU/ppuDocTxt/game1942sprite.txt", spritemem_0);
        $readmemh("C:/Users/hp/Desktop/my1942Game/RTL/src/game/PPU/ppuDocTxt/game1942sprite.txt", spritemem_1);
        $readmemh("C:/Users/hp/Desktop/my1942Game/RTL/src/game/PPU/ppuDocTxt/game1942sprite.txt", spritemem_2);
        $readmemh("C:/Users/hp/Desktop/my1942Game/RTL/src/game/PPU/ppuDocTxt/game1942sprite.txt", spritemem_3);
        $readmemh("C:/Users/hp/Desktop/my1942Game/RTL/src/game/PPU/ppuDocTxt/game1942sprite.txt", spritemem_4);
        $readmemh("C:/Users/hp/Desktop/my1942Game/RTL/src/game/PPU/ppuDocTxt/game1942sprite.txt", spritemem_5);
        $readmemh("C:/Users/hp/Desktop/my1942Game/RTL/src/game/PPU/ppuDocTxt/game1942sprite.txt", spritemem_6);
        $readmemh("C:/Users/hp/Desktop/my1942Game/RTL/src/game/PPU/ppuDocTxt/game1942sprite.txt", spritemem_7);
    end

    always @(posedge clk) begin
        tileDataO00 <= spritemem_0[tileIndex00];
        tileDataO01 <= spritemem_1[tileIndex01];
        tileDataO02 <= spritemem_2[tileIndex02];
        tileDataO03 <= spritemem_3[tileIndex03];
        tileDataO04 <= spritemem_4[tileIndex04];
        tileDataO05 <= spritemem_5[tileIndex05];
        tileDataO06 <= spritemem_6[tileIndex06];
        tileDataO07 <= spritemem_7[tileIndex07];
    end

endmodule